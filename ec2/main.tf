data "aws_ami" "ami" {
  most_recent = true
  name_regex   = "Centos-8-DevOps-Practice"
  owners = ["973714476881"]  
  
}




resource "aws_instance" "ec2" {
    ami                    = data.aws_ami.ami.image_id
    instance_type          = var.instance_type
    vpc_security_group_ids = [aws_security_group.sg_id]
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
            "git clone https://github.com/shivacharan999/roboshop-shell.git",
            "cd roboshop-shell",
            "sudo bash ${var.component}.sh"
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

output "sg_id" {

    value = aws_security_group.allow_tls.id
}

resource "aws_route53_record" "record" {
  zone_id = "Z050249122YGPFCQEASIN"
  name    = "${var.component}-dev.devsig90.online"
  type    = "A"
  ttl     = 300
  records = [aws_instance.private_ip]
}




variable "component" {}
variable "instance_type" {}

variable "env" {
    default = "dev"
}


