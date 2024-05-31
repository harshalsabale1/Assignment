# Terraform Configuration Documentation

# Purpose

The Terraform configuration automates the deployment and management of infrastructure resources on a cloud provider AWS.


### Steps

1. **Create S3 Bucket**: Create S3 Bucket on AWS through CLI for Store Terraform.tfstae file store on Remote Backend E.g - javapp555.

2. **Download AWS CLI**:        Download AWS CLI and Install it.

          https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html
   
3. **Create AWS Access and Secret Key**: Create AWS credentials Access and Secret Key.


4. **AWS Configure Using Access and Secret Key**: Using Command
  
         aws configure
   
5. **Import Terraform Configuration in VS Code**: Import terraform Configuration files into VS code for creating infrastructures.


6. **Enter Ec2 directory**: Enter in Ec2 Module for Executing Terraform Command.

       cd ./Ec2_Modules
   
7. **Terraform Initialization**: Run **terraform init** to initialize the Terraform working directory.

        terraform init --var-file=terraform.tfvars
   
8. **Plan**: Run **terraform plan** to preview the changes Terraform will make to the infrastructures.

        terraform plan --var-file=terraform.tfvars
    
9. **Validate**: Run **terraform validate** to preview infrastructures working fine.

        terraform validate --var-file=terraform.tfvars
    
10. **Apply**: Run **terraform apply** to apply the Terraform configuration and provision the infrastructures.

        terraform apply --var-file=terraform.tfvars
   
11. **Verification**: Verify that the resources have been provisioned successfully by checking the cloud provider's console or using **Terraform outputs**.
    
12. **Management**: Use Terraform commands **terraform destroy, terraform refresh** to manage the infrastructures lifecycle as needed.

         terraform destroy
         terraform import 
         terraform refresh 



## Directory Structure

```
terraform/
├── main.tf
├── terraform.tfvars
├── varibles.tf
terraform/Ec2_Modules
├── main.tf
├── variables.tf
├── outputs.tf
├── backend.tf
├── scripts/
│   └── userdata.sh
└── README.md
```

- **main.tf**: Contains the main Terraform configuration defining resources.
- **variables.tf**: Defines input variables used in the configuration.
- **outputs.tf**: Defines output values to be displayed after resource provisioning.
- **scripts/**: Directory containing scripts used for resource setup or configuration.
- **README.md**: Documentation providing an overview of the Terraform configuration and usage instructions.


## Setting Up a Private Network, Provisioning Remote Machines, and Configuring Application and Database

This guide outlines the steps to set up a private network on AWS, provision remote machines (EC2 instances), and configure a web application and PostgreSQL database on those instances.

### 1. Setting Up a Private Network

#### Prerequisites:
- An AWS account with appropriate permissions to create VPCs, subnets, and EC2 instances.

#### Steps:
1. **Create a Virtual Private Cloud (VPC)**:
   - Define the CIDR block for the VPC.


2. **Create Subnets**:
   - Divide the VPC CIDR block into smaller subnets.
   - Allocate these subnets to different availability zones.

3. **Configure Route Tables**:
   - Associate the subnets with route tables.
   - Define routing rules for traffic within the VPC.

### 2. Provisioning Remote Machines

#### Prerequisites:
- Access to the AWS console or AWS CLI.


#### Steps:
1. **Define Infrastructure as Code**:
   - Write Terraform configuration files (*.tf) to define VPC, subnets, security groups, and EC2 instances.

2. **Initialize Terraform**:
   - Run `terraform init` to initialize Terraform in the project directory.

3. **Plan and Apply**:
   - Run `terraform plan` to preview the changes.
   - Run `terraform apply` to create the infrastructure on AWS.

### 3. Configuring Application and Database

#### Prerequisites:
- Access to EC2 instances via SSH.
- Knowledge of the application and database setup requirements.

#### Steps:
1. **Configure Web Application**:
   - SSH into the EC2 instance designated for the web application.

2. **Configure PostgreSQL Database**:
   - SSH into the EC2 instance designated for the PostgreSQL database.
   - Install PostgreSQL and required libraries.
   - Create the necessary databases, users, and permissions.

3. **Ensure Connectivity**:
   - Ensure the web application can connect to the PostgreSQL database using the appropriate connection string.

### Conclusion

Following these steps, you'll have a secure private network on AWS with remote EC2 instances provisioned and configured for hosting your web application and PostgreSQL database.
