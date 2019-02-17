# Go Jenkins CI

### Work in progress

Automated setup of continuous integration for Go projects hosted on GitHub with [Jenkins](https://jenkins.io/) and [GolangCI-Lint](https://github.com/golangci/golangci-lint).

- Runs unit tests and code quality tools
- Automatically sets up webhooks on GitHub
- Can also be configured for non Go projects

Includes:
- Pull request job template
- Branch push job template
- Various [plugins](JENKINS_HOME/plugins.txt) for simple or advanced jobs management
- Automatic backups to local path or remote repository

## Requirements
* Tools (see [install script](./setup/requirements.sh)):
    * make
    * Docker
    * Docker compose

* GitHub [personal access token](https://github.com/settings/tokens) with scopes:
  * repo
  * write:repo_hook

## Install

First, clone/download repository.

#### Manually

* Copy [.env.dist](.env.dist) to .env and fill in each variable.

    `JENKINS_USERNAME` The username you are going to log in with

    `JENKINS_PASSWORD` The password you are going to log in with

    `JENKINS_URL` The URL which you'll use to access Jenkins

    `JENKINS_PORT` The port number Jenkins container will run on

    `GITHUB_USERNAME` The username of your GitHub account

    `GITHUB_ACCESS_TOKEN` The personal access token generated from your GitHub account

    `GO_VERSION` Default version of Go

    `GOLANGCI_LINT_VERSION` Default version of GolangCI-Lint

* Then run:
```
sudo make
```

See [Makefile](./Makefile) for more options.

#### Interactive

```
./setup/install.sh
```

## Add job

* Create a new job with `Copy from` option and search for the [template](JENKINS_HOME/jobs) you need
* Enable it by unchecking `General -> Disable this project`
* Configure it (see below)
* Saving it will create the required webhooks

## Configure

#### Go
* `Manage Jenkins -> Global Tool Configuration -> Go -> Go installations` (http://jenkinsurl/configureTools/)
  * Add a new version: `Add installer -> Extract *.zip/*.tar.gz` (similar to default installed version)
  * Check versions on [Downloads page](https://golang.org/dl/)
* Use a Go version for a job (from the job Configure page: http://jenkinsurl/job/jobname/configure)
  * `Build Environment -> Set up Go programming language tools -> Go version`
* Plugin: [Golang](https://plugins.jenkins.io/golang)

#### GolangCI-Lint
* `Manage Jenkins -> Configure System -> Global properties -> Environment variables -> GOLANGCI_LINT_VERSION -> Value`
* Check versions on [Releases page](https://github.com/golangci/golangci-lint/releases)
* Use in a job (from the job Configure page: http://jenkinsurl/job/jobname/configure)
  * `Build -> Add build step -> Execute shell: GO111MODULE=on golangci-lint-run`
  * Before the tool [runs](JENKINS_HOME/tools/golangci-lint/golangci-lint-run) it [installs](JENKINS_HOME/tools/golangci-lint/golangci-lint-install) the configured version (if not already installed)
  * It uses a [default config](JENKINS_HOME/tools/golangci-lint/.golangci.yml) which can be overwritten by placing a [config file](https://github.com/golangci/golangci-lint#config-file) in the root of your repository

#### go-consistent
* A tool to check [source code consistency](https://github.com/Quasilyte/go-consistent).
* Not added by default to job templates, it can be added as an `Execute shell` build step to a job as `go-consistent-run`.
* If used, it will install the tool automatically and update it on each run (it has no releases for now).

#### Pull request trigger
* Configured as a build trigger (from the job Configure page: http://jenkinsurl/job/jobname/configure)
  * `Source Code Management -> Repository URL`
  * `Build Triggers -> GitHub Pull Request Builder`
* Global configuration
  * `Manage Jenkins -> GitHub Pull Request Builder -> GitHub Auth`
* Security
  * The [Go GitHub Pull Request job template](JENKINS_HOME/jobs/Go GitHub Pull Request/config.xml) is configured with the `Build every pull request automatically without asking` option which
  will trigger the job for any user submitting a pull request. Disable it if it's not safe for you.
    * From the from the job Configure page: `Build Triggers -> GitHub Pull Request Builder -> Advanced -> Build every pull request automatically without asking (Dangerous!).`
* Result
  * The build result will be published as a comment on the PR page
  * This can be disabled from the job Configure page
    * `Build Triggers -> GitHub Pull Request Builder -> Trigger Setup -> Comment File`
* Plugin: [GitHub Pull Request Builder](https://plugins.jenkins.io/ghprb)

#### Branch push trigger
* Configured as a build trigger (from the job Configure page: http://jenkinsurl/job/jobname/configure)
  * `General -> GitHub project -> Project url (repository url)`
  * `Source Code Management -> Repository URL`
  * `Build Triggers -> GitHub hook trigger for GITScm polling`
  * `Build Triggers -> Poll SCM`
* Global configuration
  * `Manage Jenkins -> GitHub -> GitHub Servers`
* Plugin: [GitHub Pull Request Builder](https://plugins.jenkins.io/github)

#### Workspace cleanup
* Workspace data (repository used in job) is always deleted after job is finished
* Configure from the job Configure page: `Post-build Actions -> Delete workspace when build is done`
* Plugin: [Workspace Cleanup](https://plugins.jenkins.io/ws-cleanup)

#### Authorization (http://jenkinsurl/configureSecurity/)
* Configure who has access to Jenkins
  * `Manage Jenkins -> Configure Global Security -> Enable security -> Access Control -> Authorization -> Matrix-based security`
* Plugin: [Matrix Authorization Strategy](https://plugins.jenkins.io/matrix-auth)

#### Backup
* To local path
 * `Manage Jenkins -> ThinBackup`
 * Plugin: [Matrix Authorization Strategy](https://plugins.jenkins.io/matrix-auth)
* To remote repository
 * See [`Backup` job](./JENKINS_HOME/jobs/Backup/config.xml)
    * Requires an existing GitHub repository
    * Enable job by unchecking `General -> Disable this project`
    * Set the repository url: `Source Code Management -> Repository URL` 
    * Set the build schedule: `Build Triggers -> Build periodically -> Schedule` 
    * Customize the process: `Build -> Execute shell` 
    * Configure repository push: `Post-build Actions -> Git Publisher`
    * The process is simple: every day, some important parts of the environment are pushed to the specified repository.

## Server

The server you want to run Jenkins on can be automatically configured with basic security options. 
* A machine with a private SSH key file inside is required
* A non-root user will be created with SSH access based on the provided key
* Password authentication will be disabled
* Root user authentication will be disabled
* Firewall will be set up with Jenkins and SSH ports open

See [server setup script](./setup/server.sh).

## Development/Testing

To fully test on localhost you need a tunnel for GitHub to access your machine.
You can use tools like [serveo](http://serveo.net/) and [ngrok](https://ngrok.com/). 
