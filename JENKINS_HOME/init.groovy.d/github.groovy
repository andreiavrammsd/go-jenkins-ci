import org.jenkinsci.plugins.github.config.GitHubPluginConfig
import org.jenkinsci.plugins.github.config.GitHubServerConfig

def github = jenkins.model.Jenkins.instance.getExtensionList(GitHubPluginConfig.class)[0]

def c = new GitHubServerConfig("github-secret")
c.setName("GitHub server")
c.setManageHooks(true)

github.setConfigs([
    c,
])
github.save()
