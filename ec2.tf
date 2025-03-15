provider "aws" {
  region = "us-east-1"
}


data "aws_ami" "os_image" {
 owners = ["099720109477"]
 most_recent = true
 filter {
  name = "state"
  values = ["available"]
}
filter {
 name = "name"
 values = ["ubuntu/images/hvm-ssd/*amd64*"]
}
}


resource "aws_default_vpc" "default" { }


#resource "aws_key_pair" "myvm-key" {
#  key_name = "myvm-key"
#  public_key = file("../../../../.ssh/id_rsa.pub")
#}


resource "aws_security_group" "myvm-sg" {
 vpc_id = aws_default_vpc.default.id
 
ingress {
  from_port = 22
  to_port = 22
  protocol = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
}

ingress {
    description = "port 80 allow"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "port 8080 allow"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }


  ingress {
    description = "port 443 allow"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

egress {
  from_port = 0
  to_port = 0
  protocol = "-1"
  cidr_blocks = ["0.0.0.0/0"]
}
}

resource "aws_instance" "rocky-vm-test" {
  ami             = data.aws_ami.os_image.id
  #key_name        = aws_key_pair.myvm-key.key_name
  security_groups = [aws_security_group.myvm-sg.name]
  instance_type   = "t3.medium"

  root_block_device {
    volume_size = 15
    volume_type = "gp3"
  }

  user_data = file("user-data.sh")
  tags = {
    Name = "jenkins-server"
  }

}


resource "aws_ebs_volume" "extra_disk" {
  availability_zone = aws_instance.rocky-vm-test.availability_zone
  size             = 10  # Set the size in GB
  type             = "gp3"
}

resource "aws_volume_attachment" "extra_disk_attachment" {
  device_name = "/dev/xvdb"
  volume_id   = aws_ebs_volume.extra_disk.id
  instance_id = aws_instance.rocky-vm-test.id
}
