# This is a project-two/main.tf that reflects migration.hcl migration.
# Copying this file to project-two/main.tf is necessary for tfmigrate plan to
# succeed.
resource "local_file" "baz" {
  content  = "Hi"
  filename = "${path.module}/../baz.txt"
}

resource "local_file" "bar" {
  content  = "Hi"
  filename = "${path.module}/../bar.txt"
}
