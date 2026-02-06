IMAGE=devops-service-check

build:
	docker build -t $(IMAGE) .

test-local:
	./scripts/check_service.sh -s sshd --dry-run

test-docker:
	@docker run --rm $(IMAGE) -s sleep --dry-run; \
	CODE=$$?; \
	echo "Exit code was: $$CODE"; \
	test "$$CODE" -eq 1

ci:
	docker build -t $(IMAGE) .
	docker run --rm -e SERVICE=sleep -e DRY_RUN=true $(IMAGE) || test $$? -eq 1
