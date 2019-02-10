import com.cloudbees.plugins.credentials.impl.*;
import com.cloudbees.plugins.credentials.*;
import com.cloudbees.plugins.credentials.domains.*;
import org.jenkinsci.plugins.plaincredentials.impl.*
import hudson.util.Secret

def githubUser = new File("/run/secrets/github-user").text.trim()
def githuAccessToken = new File("/run/secrets/github-access-token").text.trim()

// Username and access token
Credentials c = (Credentials) new UsernamePasswordCredentialsImpl(
    CredentialsScope.GLOBAL,
    "github-user-access-token",
    "GitHub access by username and access token",
    githubUser,
    githuAccessToken
)

SystemCredentialsProvider.getInstance().getStore().addCredentials(Domain.global(), c)

// Secret text
Credentials secretText = (Credentials) new StringCredentialsImpl(
    CredentialsScope.GLOBAL,
    "github-secret",
    "GitHub access by secret",
    Secret.fromString(githuAccessToken)
)

SystemCredentialsProvider.getInstance().getStore().addCredentials(Domain.global(), secretText)
