//network.tf
resource "aws_vpc" "myvpc" {
  cidr_block = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support = true
}

//subnets.tf
resource "aws_subnet" "subnet-uno" {
  cidr_block = "${cidrsubnet(aws_vpc.myvpc.cidr_block, 3, 1)}"
  vpc_id = "${aws_vpc.myvpc.id}"
  availability_zone = "us-east-1a"
}

//security.tf
resource "aws_security_group" "ingress-all-test" {
name = "allow-all-sg"
vpc_id = "${aws_vpc.myvpc.id}"
ingress {
    cidr_blocks = [
      "0.0.0.0/0"
    ]
from_port = 22
    to_port = 22
    protocol = "tcp"
  }
ingress {
    cidr_blocks = [
      "0.0.0.0/0"
    ]
from_port = 8080
    to_port = 8080
    protocol = "tcp"
  }
// Terraform removes the default rule
  egress {
   from_port = 0
   to_port = 0
   protocol = "-1"
   cidr_blocks = ["0.0.0.0/0"]
 }
}
//servers.tf
resource "aws_instance" "jenkins-instance" {
  ami = "${var.ami-id}"
  instance_type = "t2.micro"
  key_name = "${aws_key_pair.ssh_key.key_name}"
  security_groups = ["${aws_security_group.ingress-all-test.id}"]
  subnet_id = "${aws_subnet.subnet-uno.id}"
  user_data = <<-EOF
 #!/bin/bash
sudo hostnamectl set-hostname Jenkins
sudo apt update
sudo apt install default-jdk -y
java -version
sudo apt install maven -y
mvn --version
curl -fsSL https://pkg.jenkins.io/debian/jenkins.io-2023.key | sudo tee   /usr/share/keyrings/jenkins-keyring.asc > /dev/null
echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc]   https://pkg.jenkins.io/debian binary/ | sudo tee   /etc/apt/sources.list.d/jenkins.list > /dev/null
sudo apt update
sudo apt install jenkins -y
EOF
}

resource "aws_eip" "ip-jenkins-eip" {
  instance = "${aws_instance.jenkins-instance.id}"
  #vpc      = true
}

//gateways.tf
resource "aws_internet_gateway" "myIGW" {
  vpc_id = "${aws_vpc.myvpc.id}"
}

//subnets.tf
resource "aws_route_table" "myRT" {
  vpc_id = "${aws_vpc.myvpc.id}"
route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.myIGW.id}"
  }
}
resource "aws_route_table_association" "subnet-association" {
  subnet_id      = "${aws_subnet.subnet-uno.id}"
  route_table_id = "${aws_route_table.myRT.id}"
}