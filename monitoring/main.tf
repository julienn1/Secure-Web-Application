# CloudWatch Alarm for EC2 CPU Utilization
resource "aws_cloudwatch_metric_alarm" "ec2_cpu_high" {
  alarm_name          = "ec2-cpu-high"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "60"
  statistic           = "Average"
  threshold           = "80"
  alarm_description   = "This metric monitors ec2 cpu utilization"
  alarm_actions       = [] # Add SNS topic ARNs for notifications
  dimensions = {
    AutoScalingGroupName = var.ec2_autoscaling_group_name
  }
}

# CloudWatch Alarm for RDS CPU Utilization
resource "aws_cloudwatch_metric_alarm" "rds_cpu_high" {
  alarm_name          = "rds-cpu-high"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/RDS"
  period              = "60"
  statistic           = "Average"
  threshold           = "80"
  alarm_description   = "This metric monitors rds cpu utilization"
  alarm_actions       = [] # Add SNS topic ARNs for notifications
  dimensions = {
    DBInstanceIdentifier = var.rds_db_instance_identifier
  }
}

# CloudTrail
resource "aws_cloudtrail" "trail" {
  name           = "my-cloudtrail"
  s3_bucket_name = var.cloudtrail_bucket_name
  is_multi_region_trail = true
  include_global_service_events = true
}