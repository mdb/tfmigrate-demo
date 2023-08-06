# tfmigrate-demo

A demo showing how [tfmigrate](https://github.com/minamijoyo/tfmigrate) can be
used to codify and automate the migration of Terraform resources between root module
project configurations, each using different S3 remote states.

The demo also shows how `tfmigrate` enables teams to codify state migrations as HCL,
subjecting the migrations to code review and CI/CD, similar to other Terraform
changes codified as HCL.

See [Using tfmigrate to Codify and Automate Terraform State Operations](https://mikeball.info/blog/using-tfmigrate-to-codify-and-automate-terraform-state-operations/)
as the corresponding blog post.

Overview:

* `bootstrap` is a minimal Terraform project that creates a [localstack](https://localstack.cloud/)
  `tfmigrate-demo` S3 bucket for use hosting `project-one` and `project-two`'s
   Terraform remote states
* `project-one` is a minimal Terraform 0.13.7 project that creates `foo.txt` and
  `bar.txt` files and uses `s3://tfmigrate-demo/project-one/terraform.tfstate` as
  its remote state backend.
* `project-two` is a minimal Terraform 1.4.6 project that creates a `baz.txt` file
  and uses `s3://tfmigrate-demo/project-two/terraform.tfstate` as its remote state
  backend.
* `project-one` and `project-two` each feature a `.terraform-version` file. This
  ensures [tfenv](https://github.com/tfutils/tfenv) selects the proper Terraform
  for use in each project.
* `migration.hcl` is a [tfmigrate](https://github.com/minamijoyo/tfmigrate) migration that orchestrates the migration
  of `local_file.bar` from management in `project-one` to management in `project-two`.
  `tfmigrate` enables teams to codify migrations as HCL, subjecting the
  migrations to code review and CI/CD, alongside terraform HCL configurations.

See [PR 2](https://github.com/mdb/tfmigrate-demo/pull/2) for an example GitHub
Actions workflow that fails its `tfmigrate plan` step. See [PR 3](https://github.com/mdb/tfmigrate-demo/pull/3) for an example
GitHub Actions workflow that successfully performs a `tfmigrate apply`.

See `.github/workflows/pr.yaml` for the GitHub Actions workflow configuration.

## More detailed problem statement

How can we codify and automate the migration of a Terraform-managed
resource from one root module project configuration to a different root module
project configuration, each using different S3 remote states?

And what if each root module project uses a different version of Terraform?

Solution: use [tfmigrate](https://github.com/minamijoyo/tfmigrate) in concert
with [tfenv](https://github.com/tfutils/tfenv).

## See the demo in GitHub Actions

The workflow described in "Try the demo for yourself" (below) is automated and demoed in [GitHub Actions](https://github.com/mdb/tfmigrate-demo/actions).

[PR 2](https://github.com/mdb/tfmigrate-demo/pull/2) triggers an example GitHub
Actions workflow that fails its `tfmigrate plan` step: https://github.com/mdb/tfmigrate-demo/actions/runs/5776326609/job/15655320734

[PR 3](https://github.com/mdb/tfmigrate-demo/pull/3) triggers an example GitHub
Actions workflow that successfully performs a `tfmigrate apply` step: https://github.com/mdb/tfmigrate-demo/actions/runs/5776333280/job/15655332928

See `.github/workflows/pr.yaml` for the GitHub Actions workflow configuration.

## Try the demo yourself locally

### Install dependencies

```
brew install tfmigrate
```

```
brew install tfenv
```

The demo also assumes [Docker](https://www.docker.com/) is installed and running.

### Bootstrap `localstack` environment

Run `localstack` to simulate AWS APIs locally:

```
make up
```

Create a `localstack` `tfmigrate-demo` S3 bucket. This will be used to host
`project-one` and `project-two`'s Terraform remote state files.

```
make bootstrap
```

### `terraform apply` `project-one`

Initially, `apply`-ing `project-one` results in the creation of 2 files in the
`tfmigrate-demo` root using Terraform 0.13.7:

1. `foo.txt` (its Terraform state resource address is `local_file.foo`)
2. `bar.txt` (its Terraform state resource address is `local_file.bar`)

```
make apply-one
```

### `terraform apply` `project-two`

Initially, `apply`-ing `project-two` results in the creation of 1 file in the
`tfmigrate-demo` root using Terraform 1.4.6:

1. `baz.txt` (its Terraform state resource address is `local_file.baz`)

```
make apply-two
```

### Use `tfmigrate` to migrate `local_file.bar`

Next, use [tfmigrate](https://github.com/minamijoyo/tfmigrate) to `plan` the
migration of `local_file.bar` from `project-one`'s Terraform state to
`project-two`'s Terraform state using the migration instructions codified in
`migration.hcl`, which move `local_file.bar` from `project-one` to
`project-two`.

Note that `tfmigrate plan` will "dry run" the migration using a local, dummy
copy of each project's remote state and will performs a `terraform plan`,
erroring if the migration results in any unexpected plan changes.

Also note that `tfmigrate` automatically uses the correct `terraform` CLI version
required by each project, as each project's `.terraform-version` file triggers
`tfenv` to ensure the correct version is used.

Initially, observe that `tfmigrate plan migration.hcl` fails, as we haven't
yet moved `local_file.bar`'s recource declaration HCL from `project-one` to
`project-two.`

```
tfmigrate plan migration.hcl
2023/08/02 14:07:17 [INFO] [runner] load migration file: migration.hcl
2023/08/02 14:07:17 [INFO] [migrator] multi start state migrator plan
2023/08/02 14:07:18 [INFO] [migrator@project-one] terraform version: 0.13.7
2023/08/02 14:07:18 [INFO] [migrator@project-one] initialize work dir
2023/08/02 14:07:20 [INFO] [migrator@project-one] get the current remote state
2023/08/02 14:07:22 [INFO] [migrator@project-one] override backend to local
2023/08/02 14:07:22 [INFO] [executor@project-one] create an override file
2023/08/02 14:07:22 [INFO] [migrator@project-one] creating local workspace folder in: project-one/terraform.tfstate.d/default
2023/08/02 14:07:22 [INFO] [executor@project-one] switch backend to local
2023/08/02 14:07:23 [INFO] [migrator@project-two] terraform version: 1.4.6
2023/08/02 14:07:23 [INFO] [migrator@project-two] initialize work dir
2023/08/02 14:07:26 [INFO] [migrator@project-two] get the current remote state
2023/08/02 14:07:27 [INFO] [migrator@project-two] override backend to local
2023/08/02 14:07:27 [INFO] [executor@project-two] create an override file
2023/08/02 14:07:27 [INFO] [migrator@project-two] creating local workspace folder in: project-two/terraform.tfstate.d/default
2023/08/02 14:07:27 [INFO] [executor@project-two] switch backend to local
2023/08/02 14:07:28 [INFO] [migrator] compute new states (project-one => project-two)
2023/08/02 14:07:28 [INFO] [migrator@project-one] check diffs
2023/08/02 14:07:29 [INFO] [migrator@project-two] check diffs
2023/08/02 14:07:30 [ERROR] [migrator@project-two] unexpected diffs
2023/08/02 14:07:30 [INFO] [executor@project-two] remove the override file
2023/08/02 14:07:30 [INFO] [executor@project-two] remove the workspace state folder
2023/08/02 14:07:30 [INFO] [executor@project-two] switch back to remote
2023/08/02 14:07:32 [INFO] [executor@project-one] remove the override file
2023/08/02 14:07:32 [INFO] [executor@project-one] remove the workspace state folder
2023/08/02 14:07:32 [INFO] [executor@project-one] switch back to remote
terraform plan command returns unexpected diffs: failed to run command (exited 2): terraform plan -state=/var/folders/46/sz1dzp417x7fk46kb3jv8cn00000gp/T/tmp170371809 -out=/var/folders/46/sz1dzp417x7fk46kb3jv8cn00000gp/T/tfplan2614290330 -input=false -no-
color -detailed-exitcode
stdout:
local_file.baz: Refreshing state... [id=5fc5caaa8d04abb85be16b17953cd1a6e3ed549b]
local_file.bar: Refreshing state... [id=4bf3e335199107182c6f7638efaad377acc7f452]

Terraform used the selected providers to generate the following execution
plan. Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # local_file.bar will be created
  + resource "local_file" "bar" {
      + content              = "Hi!"
      + content_base64sha256 = (known after apply)
      + content_base64sha512 = (known after apply)
      + content_md5          = (known after apply)
      + content_sha1         = (known after apply)
      + content_sha256       = (known after apply)
      + content_sha512       = (known after apply)
      + directory_permission = "0777"
      + file_permission      = "0777"
      + filename             = "./../bar.txt"
      + id                   = (known after apply)
    }

Plan: 1 to add, 0 to change, 0 to destroy.

─────────────────────────────────────────────────────────────────────────────

Saved the plan to: /var/folders/46/sz1dzp417x7fk46kb3jv8cn00000gp/T/tfplan2614290330

To perform exactly these actions, run the following command to apply:
    terraform apply "/var/folders/46/sz1dzp417x7fk46kb3jv8cn00000gp/T/tfplan2614290330"

stderr:
```

Next, remove the `local_file.bar` declaration from `project-one/main.tf` and add
it to `project-two/main.tf`, such that each project configuration reflects the
desired migration end state:

```hcl
resource "local_file" "bar" {
  content  = "Hi"
  filename = "${path.module}/../bar.txt"
}
```

Re-run `tfmigrate plan migration.hcl`; now it's successful:

```
$ tfmigrate plan migration.hcl
2023/08/02 14:39:19 [INFO] [runner] load migration file: migration.hcl
2023/08/02 14:39:19 [INFO] [migrator] multi start state migrator plan
2023/08/02 14:39:20 [INFO] [migrator@project-one] terraform version: 0.13.7
2023/08/02 14:39:20 [INFO] [migrator@project-one] initialize work dir
2023/08/02 14:39:23 [INFO] [migrator@project-one] get the current remote state
2023/08/02 14:39:24 [INFO] [migrator@project-one] override backend to local
2023/08/02 14:39:24 [INFO] [executor@project-one] create an override file
2023/08/02 14:39:24 [INFO] [migrator@project-one] creating local workspace folder in: project-one/terraform.tfstate.d/default
2023/08/02 14:39:24 [INFO] [executor@project-one] switch backend to local
2023/08/02 14:39:25 [INFO] [migrator@project-two] terraform version: 1.4.6
2023/08/02 14:39:25 [INFO] [migrator@project-two] initialize work dir
2023/08/02 14:39:28 [INFO] [migrator@project-two] get the current remote state
2023/08/02 14:39:30 [INFO] [migrator@project-two] override backend to local
2023/08/02 14:39:30 [INFO] [executor@project-two] create an override file
2023/08/02 14:39:30 [INFO] [migrator@project-two] creating local workspace folder in: project-two/terraform.tfstate.d/default
2023/08/02 14:39:30 [INFO] [executor@project-two] switch backend to local
2023/08/02 14:39:30 [INFO] [migrator] compute new states (project-one => project-two)
2023/08/02 14:39:30 [INFO] [migrator@project-one] check diffs
2023/08/02 14:39:31 [INFO] [migrator@project-two] check diffs
2023/08/02 14:39:32 [INFO] [executor@project-two] remove the override file
2023/08/02 14:39:32 [INFO] [executor@project-two] remove the workspace state folder
2023/08/02 14:39:32 [INFO] [executor@project-two] switch back to remote
2023/08/02 14:39:34 [INFO] [executor@project-one] remove the override file
2023/08/02 14:39:34 [INFO] [executor@project-one] remove the workspace state folder
2023/08/02 14:39:34 [INFO] [executor@project-one] switch back to remote
2023/08/02 14:39:36 [INFO] [migrator] multi state migrator plan success!
```

Finally, to perform the migration, `apply` the `migration.hcl`:

```
tfmigrate apply migration.hcl
$ AWS_PROFILE=superadmin tfmigrate apply migration.hcl
2023/08/02 14:41:20 [INFO] [runner] load migration file: migration.hcl
2023/08/02 14:41:20 [INFO] [migrator] start multi state migrator plan phase for apply
2023/08/02 14:41:20 [INFO] [migrator@project-one] terraform version: 0.13.7
2023/08/02 14:41:20 [INFO] [migrator@project-one] initialize work dir
2023/08/02 14:41:23 [INFO] [migrator@project-one] get the current remote state
2023/08/02 14:41:25 [INFO] [migrator@project-one] override backend to local
2023/08/02 14:41:25 [INFO] [executor@project-one] create an override file
2023/08/02 14:41:25 [INFO] [migrator@project-one] creating local workspace folder in: project-one/terraform.tfstate.d/default
2023/08/02 14:41:25 [INFO] [executor@project-one] switch backend to local
2023/08/02 14:41:25 [INFO] [migrator@project-two] terraform version: 1.4.6
2023/08/02 14:41:25 [INFO] [migrator@project-two] initialize work dir
2023/08/02 14:41:28 [INFO] [migrator@project-two] get the current remote state
2023/08/02 14:41:30 [INFO] [migrator@project-two] override backend to local
2023/08/02 14:41:30 [INFO] [executor@project-two] create an override file
2023/08/02 14:41:30 [INFO] [migrator@project-two] creating local workspace folder in: project-two/terraform.tfstate.d/default
2023/08/02 14:41:30 [INFO] [executor@project-two] switch backend to local
2023/08/02 14:41:31 [INFO] [migrator] compute new states (project-one => project-two)
2023/08/02 14:41:31 [INFO] [migrator@project-one] check diffs
2023/08/02 14:41:32 [INFO] [migrator@project-two] check diffs
2023/08/02 14:41:32 [INFO] [executor@project-two] remove the override file
2023/08/02 14:41:32 [INFO] [executor@project-two] remove the workspace state folder
2023/08/02 14:41:32 [INFO] [executor@project-two] switch back to remote
2023/08/02 14:41:35 [INFO] [executor@project-one] remove the override file
2023/08/02 14:41:35 [INFO] [executor@project-one] remove the workspace state folder
2023/08/02 14:41:35 [INFO] [executor@project-one] switch back to remote
2023/08/02 14:41:38 [INFO] [migrator] start multi state migrator apply phase
2023/08/02 14:41:38 [INFO] [migrator@project-two] push the new state to remote
2023/08/02 14:41:40 [INFO] [migrator@project-one] push the new state to remote
2023/08/02 14:41:42 [INFO] [migrator] multi state migrator apply success!
```

### Verify `project-one` and `project-two` have no outstanding Terraform plan diffs

Terraform plan and apply `project-one`; observe there are `No changes. Infrastructure is up-to-date`:

```
make apply-one
```

Terraform plan and apply `project-two`; observe there are `No changes. Infrastructure is up-to-date`:

```
make apply-two
```

### Tear down `localstack` mock AWS environment

```
make down
```
