# Terraform AWS Infrastructure Setup


This project provides Terraform code for creating a basic AWS infrastructure. It provisions a Virtual Private Cloud (VPC) with one public and one private subnet, a route table, and a Linux EC2 instance in the private subnet. The infrastructure is designed to follow best practices and is organized into reusable modules.


## Features


- *VPC*: Creates a VPC with a specified CIDR block.
- *Subnets*: Provisions one public and one private subnet.
- *Route Table*: Associates the public subnet with an internet gateway.
- *EC2 Instance*: Deploys a Linux-based EC2 instance in the private subnet.
- *Security Group*: If you want add customised block with rules and use.


## Project Structure


project-root/ ├── main.tf                  # Main Terraform file calling modules ├── variables.tf             # Input variables for the project ├── outputs.tf               # Outputs from the project ├── .gitlab-ci.yml           # CI/CD pipeline configuration for GitLab ├── modules/                 # Directory for reusable modules │   ├── vpc/                 # Module for VPC │   ├── subnet/              # Module for subnets (public & private) │   ├── route_table/         # Module for route table │   └── ec2_instance/        # Module for EC2 instance in private subnet └── README.md                # Project documentation


## Prerequisites


- *AWS Account*: Required to provision resources.
- *Terraform*: [Download and install Terraform](https://www.terraform.io/downloads.html).
- *GitLab*: For CI/CD and Git repository management.
- *AWS_SECRETS*:
  - AWS_ACCESS_KEY_ID: AWS access key ID.
  - AWS_SECRET_ACCESS_KEY: AWS secret access key.
  - Stored in TF workspace variables as sensitive or you can make use of Gitlab CI?CD variables.
- *GitLab CI/CD Variables*:
  - AWS_ACCESS_KEY_ID: AWS access key ID.
  - AWS_SECRET_ACCESS_KEY: AWS secret access key.
  - Add these under GitLab project *Settings* > *CI / CD* > *Variables*.


## How to Use


1. *Clone the Repository*
   ```bash
   git clone <repository-url>
   cd <repository-directory>


2. Set Up Terraform Cloud/Enterprise (TFE) Workspace


Configure a workspace in Terraform Cloud or Enterprise for remote state management.


Connect the GitLab repository to this workspace for CI/CD pipeline integration.




3. Configure Variables


Modify variables.tf as needed for your AWS region, CIDR blocks, AMI ID, and instance type.


Alternatively, provide them as environment variables in the .gitlab-ci.yml file.




4. Run with GitLab CI/CD


Commit changes to your repository and push them to trigger the pipeline in GitLab.


GitLab CI/CD will:


Initialize Terraform (terraform init)


Plan the infrastructure (terraform plan)


Optionally apply the infrastructure (terraform apply) with manual approval.






## Terraform Commands (Local Setup)


For users who prefer local setup without GitLab CI/CD, follow these steps:


1. Initialize Terraform


terraform init



2. Plan the Infrastructure


terraform plan -var-file="path/to/your.tfvars"



3. Apply the Infrastructure


terraform apply -var-file="path/to/your.tfvars" -auto-approve




## CI/CD Workflow Overview


The GitLab CI/CD pipeline automates deployment using .gitlab-ci.yml with three main stages:


init: Initializes Terraform configuration.


plan: Creates an execution plan for review.


apply: Manually applies the plan with approval.



## Security & Best Practices


Modular Design: Each resource (VPC, subnets, route table, and EC2) is structured as a module for reuse.


Credentials Management: AWS credentials are managed securely via script to store in TF workspace or you can make use of GitLab CI/CD environment variables..



## Troubleshooting


## Common Errors: Ensure that your AWS credentials and region are correctly configured.


State Management: If you encounter state issues, verify the TFE workspace settings or run terraform refresh locally.



Additional Information


AMI ID: Ensure that the AMI ID specified is available in your chosen AWS region.


Costs: Be aware of AWS costs associated with running these resources.



For further customization, refer to the Terraform documentation.