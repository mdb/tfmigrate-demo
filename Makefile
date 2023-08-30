tfenv:
	TFENV_ARCH=amd64 tfenv install v$(shell cat project-one/.terraform-version)
	TFENV_ARCH=amd64 tfenv install v$(shell cat project-two/.terraform-version)
.PHONY: tfenv

up: tfenv
	docker-compose up \
		--detach \
		--build

down:
	docker-compose down \
		--remove-orphans
.PHONY: down

bootstrap:
	# create tfmigrator-demo S3 TF state bucket in localstack
	cd bootstrap \
		&& terraform init \
		&& terraform plan \
		&& terraform apply \
			-auto-approve
.PHONY: bootstrap

apply-one:
	cd project-one \
		&& terraform init \
		&& terraform plan \
		&& terraform apply \
			-auto-approve
.PHONY: apply-one

apply-two:
	cd project-two \
		&& terraform init \
		&& terraform plan \
		&& terraform apply \
			-auto-approve
.PHONY: apply-two

apply: bootstrap apply-one apply-two
.PHONY: apply

curl-state-bucket:
	curl http://localhost.localstack.cloud:4566/tfmigrate-demo
.PHONY: state-bucket

curl-one-state:
	curl http://localhost.localstack.cloud:4566/tfmigrate-demo/project-one/terraform.tfstate
.PHONY: project-one-state

curl-two-state:
	curl http://localhost.localstack.cloud:4566/tfmigrate-demo/project-two/terraform.tfstate
.PHONY: project-two-state

move-bar-to-project-two:
	cp .new-project-one-main.tf project-one/main.tf
	cp .new-project-two-main.tf project-two/main.tf
.PHONY: move-bar-to-project-two

tfmigrate-plan:
	tfmigrate plan
.PHONY: tfmigrate-plan

tfmigrate-apply:
	tfmigrate apply
.PHONY: tfmigrate-apply

tfmigrate-history:
	curl http://localhost.localstack.cloud:4566/tfmigrate-demo/tfmigrate/history.json
.PHONY: tfmigrate-history

clean:
	rm *.txt || true
	rm -rf bootstrap/.terraform || true
	rm -rf project-one/.terraform || true
	rm -rf project-two/.terraform || true
