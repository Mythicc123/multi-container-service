terraform {
  backend "s3" {
    bucket  = "blue-green-tfstate-255445075474"
    key     = "multi-container-service/terraform.tfstate"
    region  = "ap-southeast-2"
    encrypt = true
  }
}
