migration "multi_state" "mv_local_file_bar" {
  from_dir = "project-one"
  to_dir   = "project-two"

  actions = [
    "mv local_file.bar local_file.bar",
  ]
}
