resource "local_file" "baz" {
  content  = "Hi"
  filename = "${path.module}/../baz.txt"
}
