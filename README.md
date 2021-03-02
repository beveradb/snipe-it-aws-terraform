# snipe-it-aws-terraform
Terraform module to help you self-host Snipe IT (open-source asset tracking web app) on AWS

I developed this for the sole purpose of running Snipe IT myself on AWS, with:
- RDS (Aurora Serverless) for the primary database
- EFS for the config/uploads data storage
- ECS to run the snipe PHP codebase in a container, using the image [published by linuxserver](https://docs.linuxserver.io/images/docker-snipe-it)
- Route53 to create entries for a primary domain, which is assumed to be used solely for this Snipe IT install. In my case, I used a [free .tk domain name from Freenom](https://www.freenom.com/en/index.html) and set up hosted zone in Route53 manually to get the nameserver values to set in the Freenom control panel.
- ACM for SSL certificate on the primary domain
- SES for outbound emails (e.g. password reset, reports, etc.)
- EC2 for an _optional_ debug/test instance - I used this to check/tweak database values by connecting to the instance over SSH, then to the RDS DB using the mysql client, and mounted the EFS config/data volume to check/tweak uploads too.

Since this was created specifically for my use case, it may not all be useful to you - I did end up with a fully functional Snipe install running on my target domain, but it's likely still rough around the edges and would need more thought and work to make it robust enough for at-scale production use!

For example, no real consideration has been given in this module to scalability (to handle greater traffic) or disaster recovery (e.g. gracefully recovering on failure).
If you use this for anything in production, please consider these! e.g. distribute load over containers in several availability zones, ensure automated backups are set up for the RDS DB and EFS filesystem, etc.!

Good luck, and feel free to reach out to me directly if you have any questions! :)
