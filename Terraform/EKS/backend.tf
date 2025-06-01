terraform {
  backend "s3" {
    bucket = "microservices-statefile"
    key    = "eks.tfstate"
    region = "us-east-1"
  }
}