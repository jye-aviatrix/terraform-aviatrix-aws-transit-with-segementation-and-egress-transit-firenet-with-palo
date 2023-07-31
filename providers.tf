terraform {
  required_providers {
    aviatrix = {
      source  = "AviatrixSystems/aviatrix"
      version = "~>3.1.0"
    }
    aws = {
      source = "hashicorp/aws"
    }
  }
}

# Configure Aviatrix provider
provider "aviatrix" {
}



# Configure the AWS Provider
provider "aws" {
  region = "us-east-2"
}