terraform {
  backend "s3" {
    bucket = "microservices-statefile"
    key    = "ec2.tfstate"
    region = "us-east-1"
  }
}