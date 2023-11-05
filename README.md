### tf-aws-ha

# AWS Infrastructure as Code (IaC) with Terraform
This README provides an overview of a Terraform script that helps you set up a basic AWS infrastructure, including a Virtual Private Cloud (VPC), subnets, security groups, and auto-scaling configurations to host an Nginx web server.

## Prerequisites
Before using this Terraform script, ensure that you have the following prerequisites:

Terraform installed on your local machine.
AWS credentials configured with the necessary permissions.
An existing AWS account.

## Script Overview
This Terraform script automates the creation of the following AWS resources:

_***VPC and Subnets:***_ It defines a VPC with two subnets – one public and one private – in different availability zones within the specified region.

_***Internet Gateway:***_ An internet gateway is attached to the VPC to allow public network access.

_***Route Table:***_ A route table is created to route traffic through the internet gateway, ensuring internet connectivity for the public subnet.

_***NAT Gateway:***_ A Network Address Translation (NAT) gateway is set up in the public subnet to allow instances in the private subnet to initiate outbound connections to the internet.

_***Security Group:***_ A security group named "nginx-sg" is created to control inbound traffic to the EC2 instances. It allows incoming traffic on port 80 (HTTP) from anywhere (0.0.0.0/0).

_***Auto Scaling Configuration:***_ This script defines an Auto Scaling Launch Configuration for EC2 instances. It installs Nginx, configures a simple web page, and sets up a health-check endpoint.

_***Auto Scaling Group:***_ An Auto Scaling Group is created to manage the number of instances based on desired capacity, minimum, and maximum capacity settings.

_***Auto Scaling Policy:***_ A scaling policy is defined to trigger scaling based on CPU utilization.

_***CloudWatch Alarm:***_ An alarm is set up to monitor CPU utilization, and it triggers the scaling policy when utilization exceeds a specified threshold.

_***Load Balancer (ALB):***_ An Application Load Balancer (ALB) is created, which balances incoming traffic between the instances in the private subnet.

_***Target Group:***_ A target group is set up to define health checks and routing for the ALB.

_***SSH Key Pair:***_ An SSH key pair is generated for EC2 instance access.

## Usage
Clone this repository to your local machine:

```bash
git clone https://github.com/your-repo/terraform-aws-nginx
cd terraform-aws-nginx
```

Create a terraform.tfvars file in the same directory to provide values for variables defined in the script:

```bash
region = "us-west-2" # Replace with your desired AWS region
ami = "ami-0123456789abcdef0" # Replace with your desired Amazon Machine Image (AMI)
instance_type = "t2.micro" # Replace with your desired EC2 instance type
initial_capacity = 2 # Set the initial number of instances
min_capacity = 2 # Minimum instances
max_capacity = 4 # Maximum instances
cpu_threshold = 80 # Set the CPU utilization threshold for scaling
```

Initialize Terraform and apply the configuration:

```bash
terraform init
terraform apply
```

Review the execution plan and confirm with 'yes' to apply the changes.

## Cleanup
To destroy the resources created by this Terraform script, run the following command:

```bash
terraform destroy
```

Confirm the action with 'yes' when prompted.

## Conclusion

This Terraform script simplifies the process of setting up a basic AWS infrastructure for hosting an Nginx web server with auto-scaling capabilities. Customize the script according to your requirements and use it as a foundation for your AWS IaC projects.

> Additional Resources:

- [Terraform Documentation](https://www.terraform.io/docs/index.html)

- [AWS CLI Configuration](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-files.html)


## License

This project is licensed under the [Apache License 2.0](https://www.apache.org/licenses/LICENSE-2.0) - see the LICENSE file for details.

Please replace `https://github.com/devopshubproject/tf-aws-ha` with the URL of your Git repository if you have one. This README provides a comprehensive guide to your Terraform project and can be extended or modified as needed.



## <font color = "red"> Follow-Me </font>

[![Portfolio](https://img.shields.io/badge/GitHub-100000?style=for-the-badge&logo=github&logoColor=white)](https://github.com/premkumar-palanichamy)

<p align="left">
<a href="https://linkedin.com/in/premkumarpalanichamy" target="blank"><img align="center" src="https://raw.githubusercontent.com/rahuldkjain/github-profile-readme-generator/master/src/images/icons/Social/linked-in-alt.svg" alt="premkumarpalanichamy" height="25" width="25" /></a>
</p>

[![youtube](https://img.shields.io/badge/YouTube-FF0000?style=for-the-badge&logo=youtube&logoColor=white)](https://www.youtube.com/channel/UCJKEn6HeAxRNirDMBwFfi3w)