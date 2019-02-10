import jenkins.model.*
import org.jenkinsci.plugins.ghprb.*

def GhprbTrigger.DescriptorImpl descriptor = Jenkins.instance
    .getDescriptorByType(org.jenkinsci.plugins.ghprb.GhprbTrigger.DescriptorImpl.class)

def String id = 'github-auth-user-token'
def exists = false

for (GhprbGitHubAuth auth : descriptor.getGithubAuth()) {
    if (auth.getId().equals(id)) {
        exists = true
        break
    }
}

if (!exists) {
    def List<GhprbGitHubAuth> githubAuths = descriptor.getGithubAuth()

    def String serverAPIUrl = 'https://api.github.com'
    def String jenkinsUrl = null
    def String credentialsId = 'github-user-access-token'
    def String description = 'Github main connection'
    def String secret = null
    githubAuths.add(new GhprbGitHubAuth(serverAPIUrl, jenkinsUrl, credentialsId, description, id, secret))

    def githubUser = new File("/run/secrets/github-user").text.trim()

    descriptor.manageWebhooks = true
    descriptor.useComments = true
    descriptor.adminlist = githubUser
    descriptor.requestForTestingPhrase = ''
    descriptor.cron = ''

    descriptor.save()
}
