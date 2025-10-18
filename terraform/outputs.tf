output "vpc_id" {
  description = "VPC ID"
  value       = aws_vpc.main.id
}

output "backend_public_ip" {
  description = "Backend server public IP"
  value       = aws_instance.backend.public_ip
}

output "backend_instance_id" {
  description = "Backend server instance ID"
  value       = aws_instance.backend.id
}

output "frontend_public_ip" {
  description = "Frontend server public IP"
  value       = aws_instance.frontend.public_ip
}

output "frontend_instance_id" {
  description = "Frontend server instance ID"
  value       = aws_instance.frontend.id
}

output "nagios_public_ip" {
  description = "Nagios server public IP"
  value       = aws_instance.nagios.public_ip
}

output "nagios_instance_id" {
  description = "Nagios server instance ID"
  value       = aws_instance.nagios.id
}

output "ssh_command_backend" {
  description = "SSH command for backend server"
  value       = "ssh -i ~/.ssh/devops_project_key ubuntu@${aws_instance.backend.public_ip}"
}

output "ssh_command_frontend" {
  description = "SSH command for frontend server"
  value       = "ssh -i ~/.ssh/devops_project_key ubuntu@${aws_instance.frontend.public_ip}"
}

output "ssh_command_nagios" {
  description = "SSH command for Nagios server"
  value       = "ssh -i ~/.ssh/devops_project_key ubuntu@${aws_instance.nagios.public_ip}"
}

output "backend_url" {
  description = "Backend API URL"
  value       = "http://${aws_instance.backend.public_ip}:5000"
}

output "frontend_url" {
  description = "Frontend URL"
  value       = "http://${aws_instance.frontend.public_ip}"
}

output "nagios_url" {
  description = "Nagios Web Interface URL"
  value       = "http://${aws_instance.nagios.public_ip}/nagios"
}
