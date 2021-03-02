# We need a cluster in which to put our service.
resource "aws_ecs_cluster" "ecs-cluster" {
  name = "${var.project_name_hyphenated}-ecs"
}

# Log groups hold logs from our app.
resource "aws_cloudwatch_log_group" "log-group" {
  name = "/ecs/${var.project_name_hyphenated}"
}

# The main service.
resource "aws_ecs_service" "ecs-service" {
  name            = "${var.project_name_hyphenated}-ecs-service"
  task_definition = aws_ecs_task_definition.ecs-task.arn
  cluster         = aws_ecs_cluster.ecs-cluster.id

  # Platform version 1.4.0 needed for EFS mount point support on Fargate - apparently the "LATEST" version tag is still mapped to 1.3.0...
  platform_version = "1.4.0"
  launch_type      = "FARGATE"

  desired_count = 1

  # If your service's tasks take a while to start and respond to Elastic Load Balancing health checks,
  # you can specify a health check grace period of up to 7,200 seconds. This grace period can prevent
  # the service scheduler from marking tasks as unhealthy and stopping them before they have time to come up.
  # https://docs.aws.amazon.com/AmazonECS/latest/developerguide/service-create-loadbalancer-rolling.html
  health_check_grace_period_seconds = var.container_health_check_grace_period_seconds

  load_balancer {
    target_group_arn = aws_lb_target_group.ecs-alb-tg.arn
    container_name   = var.project_name_hyphenated
    container_port   = var.container_port
  }

  network_configuration {
    assign_public_ip = false

    security_groups = [
      var.security_group_ids.egress,
      var.security_group_ids.http,
      var.security_group_ids.nfs,
    ]

    subnets = [
      var.subnet_ids.ecs-subnet-private
    ]
  }

  depends_on = [
    aws_alb.ecs-alb,
    aws_lb_target_group.ecs-alb-tg
  ]
}

# The task definition for our app.
resource "aws_ecs_task_definition" "ecs-task" {
  family = var.project_name_hyphenated

  container_definitions = <<EOF
  [
    {
      "name": "${var.project_name_hyphenated}",
      "image": "${var.docker_image}:${var.docker_image_version}",
      "portMappings": [
        {
          "containerPort": ${var.container_port}
        }
      ],
      "mountPoints": [
          {
              "containerPath": "/config",
              "sourceVolume": "efs-config"
          }
      ],
      ${var.container_env_vars_config}
      "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
          "awslogs-region": "${var.region}",
          "awslogs-group": "/ecs/${var.project_name_hyphenated}",
          "awslogs-stream-prefix": "ecs"
        }
      }
    }
  ]

EOF

  volume {
    name = "efs-config"
    efs_volume_configuration {
      file_system_id = var.efs_filesystem_id
      root_directory = "/config"
    }
  }

  execution_role_arn = aws_iam_role.ecs-task-execution-role.arn

  # These are the minimum values for Fargate containers.
  cpu                      = 1024
  memory                   = 2048
  requires_compatibilities = ["FARGATE"]

  # This is required for Fargate containers (more on this later).
  network_mode = "awsvpc"
}

# This is the role under which ECS will execute our task. This role becomes more important
# as we add integrations with other AWS services later on.

# The assume_role_policy field works with the following aws_iam_policy_document to allow
# ECS tasks to assume this role we're creating.
resource "aws_iam_role" "ecs-task-execution-role" {
  name               = "${var.project_name_hyphenated}-ecs-task-execution-role"
  assume_role_policy = data.aws_iam_policy_document.ecs-task-assume-role.json

  lifecycle {
    ignore_changes = [
      assume_role_policy
    ]
  }
}

data "aws_iam_policy_document" "ecs-task-assume-role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

# Normally we'd prefer not to hardcode an ARN in our Terraform, but since this is an AWS-managed
# policy, it's okay.
data "aws_iam_policy" "ecs-task-execution-role" {
  arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# Attach the above policy to the execution role.
resource "aws_iam_role_policy_attachment" "ecs-task-execution-role" {
  role       = aws_iam_role.ecs-task-execution-role.name
  policy_arn = data.aws_iam_policy.ecs-task-execution-role.arn
}

resource "aws_alb" "ecs-alb" {
  name               = "${var.project_name_hyphenated}-ecs-alb"
  internal           = false
  load_balancer_type = "application"

  subnets = [
    var.subnet_ids.ecs-subnet-public-one,
    var.subnet_ids.ecs-subnet-public-two,
  ]

  security_groups = [
    var.security_group_ids.egress,
    var.security_group_ids.http,
  ]
}

resource "aws_alb_listener" "ecs-alb-listener-http" {
  load_balancer_arn = aws_alb.ecs-alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

resource "aws_alb_listener" "ecs-alb-listener-https" {
  load_balancer_arn = aws_alb.ecs-alb.arn
  port              = "443"
  protocol          = "HTTPS"
  certificate_arn   = var.acm_cert_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.ecs-alb-tg.arn
  }
}

resource "aws_lb_target_group" "ecs-alb-tg" {
  name        = "${var.project_name_hyphenated}-ecs-alb-tg"
  port        = var.container_port
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = var.vpc_id

  health_check {
    enabled = true
    path    = "/health"
  }

  depends_on = [aws_alb.ecs-alb]
}

resource "aws_route53_record" "ecs-lb-subdomain-dns" {
  zone_id = var.route53_zone_id
  name    = "ecs.${var.domain}"
  type    = "CNAME"
  ttl     = "5"
  records = [aws_alb.ecs-alb.dns_name]
}

resource "aws_route53_record" "ecs-lb-primary-dns" {
  zone_id = var.route53_zone_id
  name    = var.domain
  type    = "A"

  alias {
    name                   = aws_alb.ecs-alb.dns_name
    zone_id                = aws_alb.ecs-alb.zone_id
    evaluate_target_health = true
  }
}
