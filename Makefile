IMAGE_NAME = bookkeeper
CONTAINER_NAME = bookkeeper-container
TERRAFORM_DIR = ./terraform

.PHONY: build run rebuild clean logs deploy deploy-ecr deploy-infra tf-init tf-plan tf-apply tf-destroy

# Docker commands
build:
	docker build -t $(IMAGE_NAME) .

run:
	docker run -d --name $(CONTAINER_NAME) --env-file .env -p 8080:8080 $(IMAGE_NAME)

rebuild: clean build run

clean:
	docker stop $(CONTAINER_NAME) 2>/dev/null || true
	docker rm $(CONTAINER_NAME) 2>/dev/null || true

logs:
	docker logs -f $(CONTAINER_NAME)

# Terraform commands
tf-init:
	cd $(TERRAFORM_DIR) && terraform init

tf-plan:
	cd $(TERRAFORM_DIR) && terraform plan

tf-apply:
	cd $(TERRAFORM_DIR) && terraform apply

tf-destroy:
	cd $(TERRAFORM_DIR) && terraform destroy

# Deployment commands
deploy:
	./deploy-full.sh

deploy-ecr:
	cd $(TERRAFORM_DIR) && terraform apply \
		-target=aws_ecr_repository.my_strands_agent \
		-target=aws_ecr_lifecycle_policy.my_strands_agent_policy \
		-target=random_id.suffix \
		-target=awscc_ecr_repository.agent_runtime \
		-auto-approve

deploy-infra:
	cd $(TERRAFORM_DIR) && terraform apply -auto-approve