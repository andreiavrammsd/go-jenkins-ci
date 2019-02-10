import jenkins.model.*
import jenkins.model.Jenkins
import jenkins.security.s2m.AdminWhitelistRule
import hudson.security.csrf.DefaultCrumbIssuer

def instance = Jenkins.instance

instance.injector.getInstance(AdminWhitelistRule.class)
    .setMasterKillSwitch(false);

if (instance.getCrumbIssuer() == null) {
    instance.setCrumbIssuer(new DefaultCrumbIssuer(true))
}

instance.save()
