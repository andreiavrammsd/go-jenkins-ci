import jenkins.model.*

def instance = Jenkins.getInstance()

def globalNodeProperties = instance.getGlobalNodeProperties()
def envVarsNodePropertyList = globalNodeProperties.getAll(hudson.slaves.EnvironmentVariablesNodeProperty.class)

def newEnvVarsNodeProperty = null
def envVars = null

if (envVarsNodePropertyList == null || envVarsNodePropertyList.size() == 0) {
  newEnvVarsNodeProperty = new hudson.slaves.EnvironmentVariablesNodeProperty();
  globalNodeProperties.add(newEnvVarsNodeProperty)
  envVars = newEnvVarsNodeProperty.getEnvVars()
} else {
  envVars = envVarsNodePropertyList.get(0).getEnvVars()
}

def env = System.getenv()
def save = false

if (!envVars.containsKey("GOLANGCI_LINT_VERSION")) {
  envVars.put("GOLANGCI_LINT_VERSION", env.GOLANGCI_LINT_VERSION)
  save = true
}

if (!envVars.containsKey("GOLANGCI_LINT_PATH")) {
  envVars.put("GOLANGCI_LINT_PATH", "\$JENKINS_HOME/tools/golangci-lint")
  save = true
}

if (!envVars.containsKey("GO_CONSISTENT_PATH")) {
  envVars.put("GO_CONSISTENT_PATH", "\$JENKINS_HOME/tools/go-consistent")
  save = true
}

if (!envVars.containsKey("PATH")) {
  envVars.put("PATH", "\$PATH:\$GOLANGCI_LINT_PATH:\$GO_CONSISTENT_PATH:\$JENKINS_HOME/go/bin")
  save = true
}

if (save) {
  instance.save()
}
