VERSION := $(shell ./prepare_version.sh)

ifeq ($(TARGET_TEST_DIR),)
TARGET_DIR := examples
else
TARGET_DIR := TARGET_TEST_DIR
endif

show-version:
	@echo -n $(VERSION)

validate:


init:
	cd $(TARGET_DIR); terraform init 
		-input=false \
		-force-copy \
		-lock=true 
		
plan: workspaceselect
	cd $(TARGET_DIR); terraform plan \
		-lock=true \
		-input=false \
		-refresh=true

plan-destroy: init
	cd $(TARGET_DIR); terraform plan \
		-input=false \
		-refresh=true \
		-destroy

workspaceinit: init
	cd $(TARGET_DIR); terraform workspace new $(WORKSPACE_ID)

workspaceselect: workspaceinit
	cd $(TARGET_DIR); terraform workspace select $(WORKSPACE_ID)

apply: plan
	cd $(TARGET_DIR); terraform apply \
		-lock=true \
		-input=false \
		-auto-approve

destroy: workspaceselect
	cd $(TARGET_DIR); terraform destroy \
		-lock=true \
		-input=false \
		-refresh=true

format: init
	cd $(TARGET_DIR); terraform fmt \
		-write=true \
		-recursive

package:
	mkdir -p output
	mkdir -p dist
	cp main.tf output/main.tf
	cp variables.tf output/main.tf
	cp machineid.template.json output/machineid.template.json
	cp docs/* output/
	cp -r examples output/examples
	cd output ; zip  ../dist/onefs_azure_vsa_${VERSION}.zip *


