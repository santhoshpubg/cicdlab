output "Public-IP" {
  value = aws_eip.ip-jenkins-eip
}

output "VPC-id" {
    value = aws_vpc.myvpc
  
}