SHELL=/bin/bash

.PHONY: up logs destroy reset restart confirm

include .env

up: confirm
	@echo $(JENKINS_USER) > /tmp/jenkins-secrets-jenkins-user
	@echo $(JENKINS_PASS) > /tmp/jenkins-secrets-jenkins-pass
	@echo $(GITHUB_USERNAME) > /tmp/jenkins-secrets-github-user
	@echo $(GITHUB_ACCESS_TOKEN) > /tmp/jenkins-secrets-github-access-token

	docker-compose up -d

logs:
	docker-compose logs -f

destroy: confirm
	docker-compose down --rmi local -v

reset: confirm destroy up

restart: confirm
	docker-compose restart

confirm:
	@echo -n "Are you sure? [y/N] " && read ans && [ $${ans:-N} == y ]
