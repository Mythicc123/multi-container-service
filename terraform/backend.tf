terraform {
  backend "s3" {
    bucket         = "mythicc-multi-container-tf-state"
    key            = "prod/terraform.tfstate"
    region         = "ap-southeast-2"
    dynamodb_table = "mythicc-multi-container-tf-locks"
    encrypt        = true
  }
}

