import jenkins.model.*
import org.jenkinsci.plugins.golang.*
import hudson.model.*
import hudson.tools.*

GolangBuildWrapper.DescriptorImpl descriptor = Jenkins.instance
    .getDescriptorByType(org.jenkinsci.plugins.golang.GolangBuildWrapper.DescriptorImpl.class)

if (descriptor.getInstallations().length == 0) {
    def env = System.getenv()

    installer = new ZipExtractionInstaller(
      null,
      "https://dl.google.com/go/go" + env.GO_VERSION + ".linux-amd64.tar.gz",
      "go"
    )
    installerProps = new InstallSourceProperty([installer])
    installation = new GolangInstallation(env.GO_VERSION, null, [installerProps])

    descriptor.setInstallations(installation)
}
