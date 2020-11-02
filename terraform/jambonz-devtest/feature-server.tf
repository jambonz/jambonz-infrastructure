# create an SNS notification topic
resource "aws_sns_topic" "jambonz_sns_topic" {
#  name = "${var.prefix}-fs-lifecycle-events"
}

resource "aws_iam_role" "jambonz_sns_publish" {
  name = "${var.prefix}_sns_publish"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": [
          "autoscaling.amazonaws.com"
        ]
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_policy" "allow_jambonz_sns_publish" {
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "sns:Publish"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "sns_publish_policy_attachment" {
    role = aws_iam_role.jambonz_sns_publish.name
    policy_arn = aws_iam_policy.allow_jambonz_sns_publish.arn
}

# select the most recent jambonz AMIs
data "aws_ami" "jambonz-feature-server" {
  most_recent      = true
  name_regex       = "^jambonz-feature-server"
  owners           = ["376029039784"]
}

# create a launch configuration
resource "aws_launch_configuration" "jambonz-feature-server" {
  image_id                    = data.aws_ami.jambonz-feature-server.id
  instance_type               = var.ec2_instance_type_fs
  associate_public_ip_address = true
  security_groups             = [aws_security_group.allow_jambonz_feature_server.id]
  key_name                    = var.key_name
  user_data                 = templatefile("${path.module}/feature-server.ecosystem.config.js.tmpl", {
    VPC_CIDR                = var.vpc_cidr_block
    JAMBONES_SBC_SIP_IPS    = join(",", var.jambonz_sbc_sip_rtp_private_ips)
    JAMBONES_MYSQL_HOST     = aws_rds_cluster.jambonz.endpoint
    JAMBONES_MYSQL_USER     = aws_rds_cluster.jambonz.master_username
    JAMBONES_MYSQL_PASSWORD = aws_rds_cluster.jambonz.master_password
    JAMBONES_REDIS_HOST     = aws_elasticache_cluster.jambonz.cache_nodes.0.address
    AWS_ACCESS_KEY_ID       = var.aws_access_key_id_runtime
    AWS_SECRET_ACCESS_KEY   = var.aws_secret_access_key_runtime
    AWS_REGION              = var.region
    AWS_SNS_TOPIC_ARN       = aws_sns_topic.jambonz_sns_topic.arn
    GCP_CREDENTIALS         = file("${path.module}/credentials/gcp.json")
    MONITORING_SERVER_IP    = aws_instance.jambonz-monitoring-server.private_ip
  })

  lifecycle {
    create_before_destroy = true
  }

  depends_on = [aws_instance.jambonz-monitoring-server]

}

# create a placement group to spread feature server instances
resource "aws_placement_group" "jambonz-feature-server" {
  name = "${var.prefix}-feature-server"
  strategy = "spread"
}

# create an autoscaling group
resource "aws_autoscaling_group" "jambonz-feature-server" {
  min_size                = 1
  max_size                = 2
  desired_capacity        = 1
  force_delete            = true
  placement_group         = aws_placement_group.jambonz-feature-server.id
  launch_configuration    = aws_launch_configuration.jambonz-feature-server.name
  termination_policies    = ["OldestInstance"]
  vpc_zone_identifier     = local.my_subnet_ids
  
  tag {
    key                 = "Name"
    value               = "${var.prefix}-feature-server"
    propagate_at_launch = true
  }

  lifecycle {
    create_before_destroy = true
  }

  depends_on = [aws_sns_topic.jambonz_sns_topic]

}

# create lifecycle hooks
resource "aws_autoscaling_lifecycle_hook" "jambonz-scale-in" {
  name                   = "jambonz-scale-in"
  autoscaling_group_name = aws_autoscaling_group.jambonz-feature-server.name
  default_result         = "CONTINUE"
  heartbeat_timeout      = 900
  lifecycle_transition   = "autoscaling:EC2_INSTANCE_TERMINATING"
  notification_target_arn = aws_sns_topic.jambonz_sns_topic.arn
  role_arn                = aws_iam_role.jambonz_sns_publish.arn
}