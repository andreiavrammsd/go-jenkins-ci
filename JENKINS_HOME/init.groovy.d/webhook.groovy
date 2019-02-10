import jenkins.model.*
import jenkins.model.Jenkins

// Jobs templates are created disabled so they won't try to add GitHub webhook
// (hook will be added when creating a new job from a template)

def instance = Jenkins.getInstance()

def job = instance.getItemByFullName("Go GitHub Pull Request")

if (job.disabled) {
    job.disabled = false
    job.save()
}
