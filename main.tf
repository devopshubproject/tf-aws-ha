# Define your AWS provider configuration
provider "aws" {
  region = var.region
}

# Create a VPC, subnets, and security group
resource "aws_vpc" "vpc" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_subnet" "pub_subnet" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-west-2a"
  map_public_ip_on_launch = true
}

resource "aws_subnet" "pvt_subnet" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "us-west-2b"
}

resource "aws_internet_gatewat" "igw" {
  vpc_id = aws_vpc.vpc.id
}

resource "aws_route_table" "rt" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
}

resource "aws_route_table_association" "public" {
  subnet_id = aws_subnet.pub_subnet.id
  route_table_id = aws_route_table.rt.id
}

resource "aws_nat_gateway" "nat" {
  allocation_id = "eipalloc-xxxxxxxxx"
  subnet_id = aws_subnet.pub_subnet.id
}

resource "aws_security_group" "sg" {
  name        = "nginx-sg"
  description = "Security group for the EC2 instance"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Create an Auto Scaling Launch Configuration
resource "aws_launch_configuration" "nginx_lc" {
  name_prefix   = "nginx-launch-config-"
  image_id      = var.ami
  instance_type = var.instance_type
  key_name      = aws_key_pair.ssh.key_name
  user_data     = <<-EOF
    #!/bin/bash
    sudo apt update
    sudo apt install nginx -y
    private_ip=$(curl -s http://169.254.169.254/latest/meta-data/local-ipv4)
    echo "<h1>Private IP Address: $private_ip</h1>" | sudo tee /var/www/html/index.html
    echo "Healthy" | sudo tee /var/www/html/health-check
    echo "location /health-check { return 200; }" | sudo tee -a /etc/nginx/sites-available/default
    sudo service nginx start
    EOF

  security_groups             = [aws_security_group.sg.id]
  associate_public_ip_address = false
}

# Create an Auto Scaling Group
resource "aws_autoscaling_group" "nginx_asg" {
  name                      = "nginx-asg"
  launch_configuration      = aws_launch_configuration.nginx_lc.name
  vpc_zone_identifier       = [aws_subnet.pvt_subnet.id]
  desired_capacity          = var.initial_capacity # Set the initial number of instances
  min_size                  = var.min_capacity     # Minimum instances
  max_size                  = var.max_capacity     # Maximum instances
  health_check_grace_period = 300
  health_check_type         = "EC2"

  tag {
    key                 = "Name"
    value               = "nginx-server"
    propagate_at_launch = true
  }
}

# Create an Auto Scaling Policy
resource "aws_autoscaling_policy" "nginx_sp" {
  name                   = "cpu-sp"
  policy_type            = "SimpleScaling"
  scaling_adjustment     = 1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = aws_autoscaling_group.nginx_asg.name

  # step_adjustment {
  #   metric_interval_lower_bound = 0
  #   scaling_adjustment          = 1
  # }

  # estimated_instance_warmup = 300
}

# Create a CloudWatch Alarm for CPU utilization
resource "aws_cloudwatch_metric_alarm" "nginx_cpu_alarm" {
  alarm_name          = "nginx-cpu-alarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 60
  statistic           = "Average"
  threshold           = var.cpu_threshold
  alarm_description   = "Scale up if CPU usage is high"
  alarm_actions       = [aws_autoscaling_policy.nginx_sp.arn]
  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.nginx_asg.name
  }
}

resource "aws_lb" "alb" {
  name                       = "ngnix-alb"
  internal                   = false
  load_balancer_type         = "application"
  subnets                    = [aws_subnet.pub_subnet.id, aws_subnet.pvt_subnet.id]
  enable_deletion_protection = false
}

resource "aws_lb_target_group" "tg" {
  name     = "ngnix-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.vpc.id

  health_check {
    path = "/health-check"
  }
}

resource "aws_lb_listener" "listener" {
  load_balancer_arn = aws_lb.alb.arn
  port              = 80
  protocol          = "HTTP"

  # default_action {
  #   type = "fixed-response"

  #   fixed_response {
  #     content_type = "text/plain"
  #     message_body = "Healthy"
  #     status_code  = "200"
  #   }
  # }

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg.arn
  }
}

##################################################
# Ssh Keygen
##################################################

resource "tls_private_key" "pvt_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

##################################################
# Key Pair
##################################################

resource "aws_key_pair" "ssh" {
  key_name   = "loginkey"
  public_key = tls_private_key.pvt_key.public_key_openssh
}
