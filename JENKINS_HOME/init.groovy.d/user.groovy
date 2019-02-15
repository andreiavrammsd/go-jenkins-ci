import jenkins.model.*
import hudson.security.*
import org.acegisecurity.userdetails.UsernameNotFoundException


def hudsonRealm = new HudsonPrivateSecurityRealm(false)
def user = new File("/run/secrets/jenkins-username").text.trim()

try {
    hudsonRealm.loadUserByUsername(user)
} catch (UsernameNotFoundException e) {
    def instance = Jenkins.getInstance()

    def pass = new File("/run/secrets/jenkins-password").text.trim()

    hudsonRealm.createAccount(user, pass)

    instance.setSecurityRealm(hudsonRealm)

    def strategy = new GlobalMatrixAuthorizationStrategy()
    strategy.add(Jenkins.ADMINISTER, user)
    instance.setAuthorizationStrategy(strategy)

    instance.save()
}
