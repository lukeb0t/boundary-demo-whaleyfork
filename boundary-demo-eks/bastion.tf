#Create EC2 bastion security group
module "bastion-sec-group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "5.1.0"

  name        = "bastion-sec-group"
  description = "Allow SSH access and from bastion"
  vpc_id      = module.boundary-eks-vpc.vpc_id

  ingress_cidr_blocks = ["0.0.0.0/0"]
  ingress_rules       = ["ssh-tcp"]

  egress_cidr_blocks = ["0.0.0.0/0"]
  egress_rules       = ["ssh-tcp", "https-443-tcp", "http-80-tcp", "kubernetes-api-tcp"]
}

module "bastion" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "5.3.1"

  name = "boundary-demo-bastion"

  ami           = data.aws_ami.aws_linux_hvm2.id
  instance_type = "t3.micro"

  key_name               = data.aws_key_pair.aws_key_name.key_name
  monitoring             = true
  subnet_id              = module.boundary-eks-vpc.public_subnets[0]
  vpc_security_group_ids = [module.bastion-sec-group.security_group_id]
}