output "vpc_id" {
  description = "The ID of the VPC created for TechCorp"
  value       = aws_vpc.techcorp_vpc.id
}

output "bastion_public_ip" {
  description = "Public IP of the Bastion host"
  value       = aws_eip.bastion_eip.public_ip
}

output "alb_dns_name" {
  description = "DNS name of the Application Load Balancer"
  value       = aws_lb.app_lb.dns_name
}

output "web_server_private_ips" {
  description = "Private IPs of all web servers"
  value       = [
    aws_instance.web_1.private_ip,
    aws_instance.web_2.private_ip
  ]
}

output "db_private_ip" {
  description = "Private IP of the database server"
  value       = aws_instance.db.private_ip
}