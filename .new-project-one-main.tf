# This is a project-one/main.tf that reflects migration.hcl migration.
# Copying this file to project-one/main.tf is necessary for tfmigrate plan to
# succeed.
resource "local_file" "foo" {
  content  = "Hi"
  filename = "${path.module}/../foo.txt"
}
