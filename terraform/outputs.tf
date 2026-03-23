output "instance_public_ip" {
  description = "Public IP address of the EC2 instance"
  value       = aws_instance.app_server.public_ip
}

output "instance_private_ip" {
  description = "Private IP address of the EC2 instance"
  value       = aws_instance.app_server.private_ip
}

output "instance_id" {
  description = "ID of the EC2 instance"
  value       = aws_instance.app_server.id
}

output "ssh_private_key" {
  description = "SSH private key for connecting to the instance"
  value       = tls_private_key.app.private_key_pem
  sensitive   = true
}

output "ssh_command" {
  description = "SSH command to connect to the instance"
  value       = "ssh -i /tmp/ec2_key ubuntu@${aws_instance.app_server.public_ip}"
}
