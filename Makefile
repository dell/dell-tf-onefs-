ifeq ($(TARGET_TEST_DIR),)
TARGET_DIR := examples
else
TARGET_DIR := TARGET_TEST_DIR
endif

validate:


init:
	cd $(TARGET_DIR); terraform init \
		-input=false \
		-force-copy \
		-lock=true \
		-upgrade \
		-verify-plugins=true 
		
plan: init
	cd $(TARGET_DIR); terraform plan \
		-lock=true \
		-input=false \
		-refresh=true

plan-destroy: init
	cd $(TARGET_DIR); terraform plan \
		-input=false \
		-refresh=true \
		-destroy

apply: plan
	cd $(TARGET_DIR); terraform apply \
		-lock=true \
		-input=false \
		-refresh=true

destroy: init
	cd $(TARGET_DIR); terraform destroy \
		-lock=true \
		-input=false \
		-refresh=true

format: init
	cd $(TARGET_DIR); terraform fmt \
		-write=true \
		-recursive

