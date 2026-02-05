
# ------------------------------------------------------------------------------

resource "aws_security_group" "alb_sg" {
  name        = "alb-sg"
  description = "Allow HTTP from the Internet"
  vpc_id      = aws_vpc.demo-vpc.id

  # Inbound: Allow HTTP from ANYWHERE (The Internet)
  ingress {
    from_port   = 8000
    to_port     = 8000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [ "0.0.0.0/0" ]
  }

  # Outbound: Allow ALB to talk to your private instances
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# ------------------------------------------------------------------------------
# 3. The Load Balancer Resource
# ------------------------------------------------------------------------------
resource "aws_lb" "app_lb" {
  name               = "my-app-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]

  # Attach BOTH Public Subnets
  subnets = aws_subnet.public-subnets[*].id
}

# ------------------------------------------------------------------------------
# 4. Target Group (The "List" of backend instances)
# ------------------------------------------------------------------------------
resource "aws_lb_target_group" "app_tg" {
  name     = "app-target-group"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.demo-vpc.id

  # Health Check: The ALB checks this to know if instances are alive
  health_check {
    path                = "/"     # Checks the root index.html
    matcher             = "200"   # Expects a 200 OK response
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}

# ------------------------------------------------------------------------------
# 5. Listener (Connects the ALB to the Target Group)
# ------------------------------------------------------------------------------
/*resource "aws_lb_listener" "front_end" {
  load_balancer_arn = aws_lb.app_lb.arn
  port              = "8000"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app_tg.arn
  }
}
*/
resource "aws_lb_listener" "front_end1" {
  load_balancer_arn = aws_lb.app_lb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app_tg.arn
  }
 
}

