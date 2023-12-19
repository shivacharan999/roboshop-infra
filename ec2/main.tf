data "aws_ami" "ami" {
  most_recent = true  
  name_regex   = "devops-practice-ansible"
  owners = ["290972336566"] 
  
}




resource "aws_instance" "ec2" {
    ami                    = data.aws_ami.ami.image_id
    instance_type          = var.instance_type
    vpc_security_group_ids = [aws_security_group.sg.id]
    tags = {
        Name = var.component
    }

}

resource "null_resource" "provisioner" {
     provisioner "remote-exec" {

        connection {
            host = aws_instance.ec2.public_ip
            user = "centos"
            password = "DevOps321"
        }

        inline = [
           "ansible-pull -i localhost, -U https://github.com/shivacharan999/roboshop-ansible.git roboshop.yml -r role_mame= ${var.component}"
        ]
}

}


resource "aws_security_group" "sg" {
  name        = "${var.component}-${var.env}-sg"
  description = "Allow TLS inbound traffic"

  ingress {
    description      = "ALL"
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]

  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    
  }

  tags = {
    Name = "${var.component}-${var.env}-sg"
  }
}


resource "aws_route53_record" "record" {
  zone_id = "Z050249122YGPFCQEASIN"
  name    = "${var.component}-dev.devsig90.online"
  type    = "A"
  ttl     = 300
  records = [aws_instance.ec2.private_ip]
}




variable "component" {}
variable "instance_type" {}

variable "env" {
    default = "dev"
}


