# Terraform Configuration Documentation

# Purpose

The Terraform configuration automates the deployment and management of infrastructure resources on a cloud provider AWS.


### Steps

1. **Download AWS CLI**:        Download AWS CLI and Install it.

          https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html
   
2. **Create AWS Access and Secret Key**: Create AWS credentials Access and Secret Key.


3. **AWS Configure Using Access and Secret Key**: Using Command
  
         aws configure
   
4. **Import Terraform Configuration in VS Code**: Import terraform Configuration files into VS code for creating infrastructures.

5. **Terraform Initialization**: Run **terraform init** to initialize the Terraform working directory.

        terraform init
   
6. **Plan**: Run **terraform plan** to preview the changes Terraform will make to the infrastructures.

        terraform plan
    
7. **Validate**: Run **terraform validate** to preview infrastructures working fine.

        terraform validate
    
8. **Apply**: Run **terraform apply** to apply the Terraform configuration and provision the infrastructures.

        terraform apply
   
9. **Verification**: Verify that the resources have been provisioned successfully by checking the cloud provider's console or using **Terraform outputs**.
    
10. **Management**: Use Terraform commands **terraform destroy, terraform refresh** to manage the infrastructures lifecycle as needed.

         terraform destroy
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


## Conclusion

The Terraform configuration simplifies infrastructure management by automating the provisioning and deployment of resources. By following the provided guidelines and documentation, users can efficiently deploy and maintain infrastructure in a consistent and reproducible manner.


