variable "region" {
  description = "The AWS region in which to deploy resources."
  type        = string
  default     = "us-west-2" # Change to your desired region
}

variable "instance_type" {
  description = "The EC2 instance type for the NGINX instances."
  type        = string
  default     = "t2.micro" # Change to your desired instance type
}

variable "ami" {
  description = "The ami for the NGINX instances."
  type        = string
  default     = "t2.micro" # Change to your desired instance ami
}

variable "initial_capacity" {
  description = "The initial number of NGINX instances to launch."
  type        = number
  default     = 2
}

variable "min_capacity" {
  description = "The minimum number of NGINX instances in the Auto Scaling Group."
  type        = number
  default     = 2
}

variable "max_capacity" {
  description = "The maximum number of NGINX instances in the Auto Scaling Group."
  type        = number
  default     = 5
}

variable "cpu_threshold" {
  description = "The CPU utilization threshold to trigger scaling."
  type        = number
  default     = 75
}
