terraform {
  backend "s3" {
    bucket = "javapp555"
    key    = "terraform.tfstate"
    region = "ap-south-1"
  }
}
