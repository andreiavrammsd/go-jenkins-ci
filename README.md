# Go Jenkins CI

### Work in progress

Automated setup of continuous integration for Go projects hosted on Github with [Jenkins](https://jenkins.io/) and [GolangCI-Lint](https://github.com/golangci/golangci-lint).

- Runs unit tests and code quality tools
- Automatically sets up webhooks on Github
- Can be configured for non Go projects

It includes job templates for:
- Pull requests
- Branch push

## Requirements
* make
* Docker
* Docker compose
* Github [personal access token](https://github.com/settings/tokens) with scopes:
  * repo
  * admin:repo_hook

## Install

Copy [.env.dist](.env.dist) to .env and fill in each variable.

```
make
```

See [Makefile](./Makefile) for more options.
