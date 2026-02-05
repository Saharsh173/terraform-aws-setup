variable "public_subnet" {
  description = "These are public subnets for internet facing"
  type = list(string)
  default = [ "public-subnet-1","public-subnet-2" ]
}
variable "availability_zones" {
  description = "Available AZs"
  type = list(string)
  default = [ "us-east-1a","us-east-1b" ]
}

variable "cidr_block" {
  description = "cidr blcks for subnets"
  type = list(string)
  default = [ "10.0.0.0/24","10.0.1.0/24" ]

}
variable "private_subnet" {
  description = "These are private subnets in which instances will be deployed"
  type = list(string)
  default = [ "private-subnet-1","private-subnet-2" ]
  }

variable "private_cidr_block" {
  description = "cidr for private subntes"
  type = list(string)
  default = [ "10.0.3.0/24","10.0.4.0/24" ]
}

variable "egress_rule" {
  type = list(object({
    from_port = number
    to_port= number
    protocol= string
    cidr_blocks=list(string)

  }))
  default = [ {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = [ "0.0.0.0/0" ]
  } ]
}