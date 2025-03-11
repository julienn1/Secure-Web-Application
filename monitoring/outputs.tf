output "ec2_cpu_alarm_arn" {
  value = aws_cloudwatch_metric_alarm.ec2_cpu_high.arn
}

output "rds_cpu_alarm_arn" {
  value = aws_cloudwatch_metric_alarm.rds_cpu_high.arn
}

output "cloudtrail_arn" {
  value = aws_cloudtrail.trail.arn
}