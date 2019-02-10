import jenkins.model.Jenkins
import hudson.model.ListView

def instance = Jenkins.getInstance()

def viewName = 'Templates'

if (instance.getView(viewName) == null) {
    instance.addView(new ListView(viewName))

    def templatesView = hudson.model.Hudson.instance.getView(viewName)
    templatesView.doAddJobToView("Go GitHub Pull Request")
    templatesView.doAddJobToView("Go GitHub Branch")

    instance.save()
}
