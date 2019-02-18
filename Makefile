SHELL=/bin/bash

.PHONY: up logs destroy reset restart confirm

include .env

ifndef TZ
  TZ=`date +"%Z"`
endif

up: confirm
	@mkdir -p /secrets
	@echo $(JENKINS_USERNAME) > /secrets/jenkins-secrets-jenkins-username
	@echo $(JENKINS_PASSWORD) > /secrets/jenkins-secrets-jenkins-password
	@echo $(GITHUB_USERNAME) > /secrets/jenkins-secrets-github-username
	@echo $(GITHUB_ACCESS_TOKEN) > /secrets/jenkins-secrets-github-access-token

	@TZ=$(TZ) docker-compose up -d

logs:
	docker-compose logs -f

destroy: confirm
	docker-compose down --rmi local -v

reset: confirm destroy up

restart: confirm
	docker-compose restart

confirm:
	@echo -en "\nAre you sure? [y/N] " && read ans && [ $${ans:-N} == y ]
