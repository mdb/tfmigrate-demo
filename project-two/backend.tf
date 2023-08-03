terraform {
  required_version = "1.4.6"

  backend "s3" {
    bucket                      = "tfmigrate-demo"
    key                         = "project-two/terraform.tfstate"
    region                      = "us-east-1"
    endpoint                    = "http://s3.localhost.localstack.cloud:4566"
    skip_credentials_validation = true
    skip_metadata_api_check     = true
    access_key                  = "fake"
    secret_key                  = "fake"
    force_path_style            = true
  }
}
