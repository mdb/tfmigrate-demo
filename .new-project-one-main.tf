resource "local_file" "foo" {
  content  = "Hi"
  filename = "${path.module}/../foo.txt"
}
