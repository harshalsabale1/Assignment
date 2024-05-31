terraform {
  backend "s3" {
    bucket = "javapp555"
    key    = "terraform.tfstate"
    region = "us-east-1"
  }
}
