resource "local_file" "baz" {
  content  = "Hi"
  filename = "${path.module}/../baz.txt"
}

resource "local_file" "bar" {
  content  = "Hi"
  filename = "${path.module}/../bar.txt"
}
