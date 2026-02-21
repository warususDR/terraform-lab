# Terraform learning task

## Overview
This repository contains a Terraform configuration for automating the deployment and management of cloud infrastructure across AWS and Cloudflare. The project demonstrates the core principles ofIaC by provisioning scalable compute resources, configuring network access controls, and managing DNS delegation.

## Architecture
The configuration provisions the following resources:
* **Compute (AWS EC2):** Two `t3.micro` instances (`web_server` and `app_server`) running Amazon Linux 2023.
* **Network Security (AWS Security Groups):** * A public-facing security group for the `web_server` allowing inbound HTTP, HTTPS, and SSH traffic.
  * A restricted security group for the `app_server` restricting port 8080 traffic exclusively to requests originating from the `web_server`'s security group.
* **DNS Management (Cloudflare & AWS Route 53):** * Creation of an AWS Route 53 Hosted Zone for a designated subdomain.
  * Automated NS record delegation in Cloudflare to route traffic to the AWS environment.
  * Automated A-record mapping for both instances.

## Prerequisites
To execute this configuration, the following tools and credentials are required:
* [Terraform](https://www.terraform.io/downloads.html)
* [AWS CLI](https://aws.amazon.com/cli/) configured with appropriate IAM credentials or any other method (vault etc.)
* A Cloudflare API Token with `Edit zone DNS` permissions
* A generated RSA SSH key pair located at `~/.ssh/tf-lab-key` (or a custom path defined in variables)

## Usage Instructions

### 1. Configuration
Create a `terraform.tfvars` file in the root directory and populate it with your environment-specific variables:

```hcl
domain_name          = "example.com"
cloudflare_zone_id   = "your_cloudflare_zone_id"
cloudflare_api_token = "your_cloudflare_api_token"
aws_region           = "your_preferred_region"
```

### 2. Initialization
Initialize the Terraform working directory to download the required AWS and Cloudflare providers:
```bash
terraform init
```

### 3. Execution
Review the execution plan to verify the resources that will be created:
```bash
terraform plan
```
Apply the configuration to provision the infrastructure:
```bash
terraform apply -auto-approve
```

### 4. Verification
Upon successful application, Terraform will output the SSH connection strings and the public URL for the web server. Use the provided commands to access the instances and verify the security group routing rules (e.g., verifying that the app server is inaccessible on port 8080 from the public internet).

### 5. Cleanup
To prevent ongoing charges for AWS resources, destroy the infrastructure when it is no longer needed:
```bash
terraform destroy -auto-approve
```
