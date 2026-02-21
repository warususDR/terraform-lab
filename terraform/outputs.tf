output "web_server_ssh" {
  value = "ssh -i ~/.ssh/tf-lab-key ec2-user@${aws_instance.web.public_ip}"
}

output "app_server_ssh" {
  value = "ssh -i ~/.ssh/tf-lab-key ec2-user@${aws_instance.app.public_ip}"
}

output "web_url" {
  value = "http://${aws_route53_record.web.name}"
}