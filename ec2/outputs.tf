

output "security_group_id" {
  value = aws_security_group.ec2.id
}

output "autoscaling_group_name" {
  value = aws_autoscaling_group.web.name
}