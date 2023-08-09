tfmigrate {
  migration_dir = "."

  history {
    storage "s3" {
      bucket                      = "tfmigrate-demo"
      key                         = "tfmigrate/history.json"
      region                      = "us-east-1"
      endpoint                    = "http://localhost.localstack.cloud:4566"
      force_path_style            = true
      skip_credentials_validation = true
      skip_metadata_api_check     = true
      access_key                  = "fake"
      secret_key                  = "fake"
    }
  }
}
