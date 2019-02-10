import jenkins.model.Jenkins
import jenkins.model.JenkinsLocationConfiguration

env = System.getenv()

params = [
  url: env.JENKINS_URL
]

location = JenkinsLocationConfiguration.get()

if (location.getUrl() == null) {
  location.setUrl(params.url)
  location.save()
}
