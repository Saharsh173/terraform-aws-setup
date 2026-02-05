resource "aws_launch_template" "template-scaling" {
  image_id = "ami-0ad50334604831820"
  instance_type = "t2.micro"
  vpc_security_group_ids = [aws_security_group.ssh-access.id]
  key_name      = "redhatlogin"

}

resource "aws_autoscaling_group" "asg" {
  desired_capacity = 2
  min_size = 1
  max_size = 2
  target_group_arns = [aws_lb_target_group.app_tg.arn]
  vpc_zone_identifier = aws_subnet.private-subnets[*].id
  launch_template {
    id=aws_launch_template.template-scaling.id
  }
}

resource "aws_security_group" "ssh-access" {
  vpc_id = aws_vpc.demo-vpc.id
  ingress {
    from_port = 22
    to_port = 22
    security_groups = [aws_security_group.bastion-ssh.id]
    protocol = "tcp"

  }
  ingress {
    from_port   = 8000
    to_port     = 8000
    protocol    = "tcp"
    security_groups = [ aws_security_group.alb_sg.id ]
  }
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    security_groups = [ aws_security_group.alb_sg.id ]
  }

  # Allow all outbound traffic
  dynamic "egress" {
    for_each = var.egress_rule
    content {
      from_port = egress.value.from_port
      to_port = egress.value.to_port
      protocol = egress.value.protocol
      cidr_blocks = egress.value.cidr_blocks
    }
  }
}
