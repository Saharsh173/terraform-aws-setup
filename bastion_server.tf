resource "aws_instance" "bastion-host" {
 ami = "ami-0ad50334604831820"
 instance_type = "t2.micro"
 subnet_id = aws_subnet.public-subnets[0].id
 vpc_security_group_ids = [ aws_security_group.bastion-ssh.id  ]
 key_name = "redhatlogin"
  
}

resource "aws_security_group" "bastion-ssh" {
    vpc_id = aws_vpc.demo-vpc.id
  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
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
