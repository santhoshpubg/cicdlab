variable "ami-id" {
    default = "ami-0fc5d935ebf8bc3bc"
  
}

variable "hostname" {
    default = "jenkins"
}
resource "aws_key_pair" "ssh_key" {
  key_name   = "ssh_key"
  public_key = file("/Users/admin/tf-pro/CICD-Project/aws-key.pub")
}
