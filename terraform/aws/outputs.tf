# Show EC2 Instance ID
output "instance_id" {
  description = "The ID of the EC2 instance"
  value       = aws_instance.app.id
}


# Ready-to-use App URL
output "app_url" {
  description = "URL to access your React app"
  value       = "http://${aws_instance.app.public_ip}"
}

# SSH connection helper
output "ssh_command" {
  description = "Command to SSH into the EC2 instance"
  value       = var.use_keypair ? "ssh -i ${var.public_key_path} ubuntu@${aws_instance.app.public_ip}" : "Use AWS SSM Session Manager (no SSH key used)"
}

