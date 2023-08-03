tfenv:
	TFENV_ARCH=amd64 tfenv install v$(shell cat project-one/.terraform-version)
	TFENV_ARCH=amd64 tfenv install v$(shell cat project-two/.terraform-version)
.PHONY: tfenv

up: tfenv
	docker-compose up \
		--detach \
		--build
.PHONY: up

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

plan-migration:
	tfmigrate plan migration.hcl
.PHONY: plan-migration

apply-migration:
	tfmigrate plan migration.hcl
.PHONY: apply-migration

clean:
	rm *.txt || true
	rm -rf project-one/.terraform || true
	rm -rf project-two/.terraform || true
