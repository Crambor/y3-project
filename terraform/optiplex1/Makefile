plan:
	source $(PWD)/.env && terraform plan -var-file secrets.tfvars

apply:
	source $(PWD)/.env && terraform apply -var-file secrets.tfvars

destroy:
	source $(PWD)/.env && terraform destroy -var-file secrets.tfvars
