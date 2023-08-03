resource "local_file" "foo" {
  content  = "Hi"
  filename = "${path.module}/../foo.txt"
}

resource "local_file" "bar" {
  content  = "Hi"
  filename = "${path.module}/../bar.txt"
}
