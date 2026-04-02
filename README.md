# TechCorp AWS Web Application Terraform Project

## Project Overview

This Terraform project demonstrates the deployment of a scalable, secure, and highly available web application infrastructure on AWS. It is designed for educational purposes, showing cloud infrastructure automation using Terraform.

**What's in the infrastructure?**

- VPC with public and private subnets across two availability zones
- Bastion host for secure administrative SSH access
- Two private web servers running Apache
- A Database server (PostgreSQL) in a private subnet
- An Application Load Balancer (ALB) with health checks
- Security groups for controlled access
- Dynamic HTML page showing server details (hostname, private IP, OS, architecture, instance ID)

**Key points:**

- ALB distributes traffic to web servers.
- Bastion host is the only SSH entry point from the internet.
- Private subnets do not allow direct internet access. The NAT gateways handle outbound traffic.

## Prerequisites

Before deploying, you need:

1. `Terraform >= 1.4` installed on your machine
2. `AWS CLI` configured with credentials that have permissions to create EC2, VPC, ALB, NAT, and security groups
3. `SSH key pair` in AWS (used for Bastion and EC2 instances)

## File Structure
```
month-one-assessment/
├── main.tf                     # All resource definitions
├── variables.tf                # Variable declarations
├── outputs.tf                  # Terraform output definitions
├── terraform.tfvars.example    # Example variable values
├── user_data/
│   ├── web_server_setup.sh     # Apache installation + custom HTML
│   └── db_server_setup.sh      # PostgreSQL installation
└── README.md                   # This file
```

## Variables
1. `region` - AWS region to deploy the resources
2. `key_name` - Name of your AWS EC2 key pair
3. `instance_type_bastion` - EC2 type for Bastion host (default: t3.micro)
4. `instance_type_web` - EC2 type for web servers (default: t3.micro)
5. `instance_type_db` - EC2 type for DB server (default: t3.small)
6. `my_ip` - Your public IP for SSH access to the bastion host (CIDR format, e.g., 203.0.113.25/32)

## Deployment Steps

### Step 1: Initialize Terraform
    terraform init
Installs necessary providers and prepares Terraform for deployment.

### Step 2: Review Terraform Plan
    terraform plan
- Shows all resources that will be created.
- Ensures outputs and resources are correct.

### Step 3: Apply Terraform Configuration
    terraform apply
- Confirm by typing yes.
- Wait a few minutes while resources are created.

Terraform will output VPC ID, Bastion public IP, ALB DNS, and server private IPs.

## Outputs
After terraform apply, you’ll see:

1. `vpc_id` - The VPC ID
2. `bastion_public_ip` - For SSH access
3. `alb_dns_name` - Browser access
4. `web_server_private_ips` - Internal web server IPs
5. `db_private_ip` - Internal DB server IP

## Accessing the Infrastructure

### Bastion Host
SSH into the bastion host using your private key:

    ssh -i path/to/key.pem ec2-user@<bastion_public_ip>

### Web Servers
From the bastion host, SSH to web servers (agent forwarding recommended):

    ssh ec2-user@<web_private_ip>

### Website
1. Open the ALB DNS name in a browser:
2. You will see a dynamic HTML page showing:
    - Hostname
    - Private IP
    - OS & version
    - Architecture
    - Instance ID
    - Deployment timestamp

## Testing & Verification
- Check that all EC2 instances are running in the AWS console.
- Verify ALB health checks are passing (status “healthy”).
- Access ALB DNS name in a browser; the page should load.
- SSH into web servers via bastion and check Apache is running:

        sudo systemctl status httpd

- SSH into DB server via bastion and verify PostgreSQL:

        psql --version

## Troubleshooting (Errors I came accross when building this)
- `502 Bad Gateway` - Check ALB target group health. Ensure Apache is installed and user data ran successfully.
- `Cannot SSH to web servers` - Ensure agent forwarding is enabled or key is copied correctly.
- `HTML page missing server info` - Ensure `user_data/web_server_setup.sh` uses unquoted EOF for variable substitution.

## Cleanup
To destroy all AWS resources and prevent charges:

    terraform destroy

**Confirm with yes**.

**Double-check AWS console to ensure no EC2, ALB, NAT, or EIP is left running**.

## Notes
1. User data scripts handle Apache and PostgreSQL installation automatically.
2. Dynamic HTML page uses Bash commands to fetch server info.
3. Architecture is scalable and highly available across two AZs.
4. Security groups ensure only authorized access to resources.