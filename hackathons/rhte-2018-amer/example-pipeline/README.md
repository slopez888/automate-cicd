This is an example of how to leverage Ansible and the [Jenkins Pipeline as Code](https://jenkins.io/solutions/pipeline/) concept as part of a Continuous Integration and Continuous Delivery Pipeline.

## Git Server Configuration

As part of the provided lab environment environment, [Gogs](https://gogs.io), an Open Source Git server was deployed. Gogs features a rich user interface for managing Git repositories. It can be accessed in the lab environment by navigating to [http://cicd1.GUID.rhte.opentlc.com:3000](http://cicd1.GUID.rhte.opentlc.com:3000). Credentials for logging in will be provided by your instructors.

### Importing an Existing Repository

Gogs contains the functionality to import existing repositories, called _Migrations_. Import this repository into Gogs by utilizing the following steps.

Once logged in, locate and select the plus (+) icon on navigation bar. Select **New Migration**.

On the configuration page, in the _Clone Address_ field, enter **https://github.com/redhat-cop/automate-cicd**

Next to _Repository Name_, enter **automate-cicd**

Click **Migrate Repository** to import the repository.

Once complete, a new repository called _automate-cicd_ will be created.

## Accessing Jenkins Server

Also included in the provisioned environment is the Jenkins Continuous Integration server. The user interface can be accessed by navigating to [https://cicd1.GUID.rhte.opentlc.com:8443](https://cicd1.GUID.rhte.opentlc.com:8443). Credentials for logging in will be provided by your instructors.

## Creating A Jenkins Pipeline Job

To demonstrate how Jenkins can be used in combination with Ansible, we will create a new [pipeline job](https://jenkins.io/doc/book/pipeline/) that will exercise the [ansible-role-banner](../roles/ansible-role-banner) role. As part of the pipeline, several common steps that are found in typical Ansible based Continuous Integration and Continuous Delivery implementations will be demonstrated:

* Accessing source code from a Version Control System
* Testing a role for [correct syntax](https://ansible-tips-and-tricks.readthedocs.io/en/latest/ansible/commands/#check-for-bad-syntax)
* Executing a playbook/role in [Check Mode](https://docs.ansible.com/ansible/latest/user_guide/playbooks_checkmode.html)
* Executing the playbook against a live instance

After logging in, the first step is to create the pipeline job by clicking on the **New Item** link on the lefthand navigation bar.

Enter **example-pipeline** as the _item name_, select **Pipeline** and then click **OK** to create the pipeline.

Configure the pipeline job by navigating to the _Pipeline_ section and then select the dropdown next to _Definition_ and select **Pipeline Script from SCM**.

Next to _SCM_, select **Git**.

Enter the following _Repository URL_: http://localhost:3000/cicduser1/automate-cicd.git

The logic for the pipeline is contained in a file called _Jenkinsfile_ within the _hackathons/rhte-2018-amer/example-pipeline_ directory.

Enter the following next to _Script Path_ to define the location of the Jenkinsfile: **hackathons/rhte-2018-amer/example-pipeline/Jenkinsfile**

Once complete, click **Save** to apply the changes to the pipeline job. 

Trigger a pipeline build by clicking **Build Now**

Once complete, the set of _stages_ that were performed as part of the pipeline will be shown on the example-pipeline project page.

Assuming the first job was successful, you can find more details about the build by selecting the build number on the lefthand side of the page and then referencing any of the links available on the subsequent page.

## Validate Banner Role was Applied

THe example pipeline executed the [ansible-role-banner](../roles/ansible-role-banner) to set the Message of the Day (MOTD) on the _app1_ machine.

Login to the bastion via SSH to get access to the environment

```
ssh USER@bastion.GUID.rhte.opentlc.com
```

Once logged into the bastion, elevate to the _root_ user.

```
sudo su -
```

Finally, SSH into the _app1_ machine

```
ssh -i ~/.ssh/GUIDkey.pem  ec2-user@app1
```

The customized banner that was configured as part of the role should be displayed validating the successful execution of the Jenkins pipeline.

## Triggering Builds Automatically

Continuous Integration emphasizes that a build occur after each change to a source code repository. The process of obtaining source code from the git repository was manually executed when testing the _example-pipeline_. Now, let's modify the configuration of both our Gogs repository and Jenkins job so that a Jenkins build occurs every time a _push_ occurs in the Git repository.

### Installing the gogs-webhook Plugin

The triggering of the build will occur via a webhook invocation trigger from Gogs and accepted by Jenkins. A Jenkins plugin called [gogs-webhook](https://plugins.jenkins.io/gogs-webhook) enables Jenkins to receive the invocation from Gogs and trigger the appropriate build. Several plugins needed by Jenkins in this lab were installed automatically for you as part of the provisioning. To demonstrate how plugins can be installed in Jenkins, we will add the _gogs-webhook_ plugin.

From the Jenkins homepage, select **Manage Jenkins** on the lefthand side. Then click **Manage Plugins** to enter the plugin manager.

The plugin manager describes the plugins that installed including any that may have updates as well as available plugins eligable for installation.

Select the **Available** tab to view the plugins available in the Jenkins marketplace. 

You will notice a large amount of plugins available for installation. Use the textbox on the top right corner of the page to filter the available results. Enter **gogs-webhook** into the textbox. A single match should appear. Select the checkbox next to the _Gogs plugin_ result and then select **Download now and install after restart**.

Click the **Restart Jenkins when installation is complete and no jobs are running** checkbox which will trigger a reboot of the Jenkins server after the plugin is downloaded. When Jenkins is ready, login again o complete the plugin install.

### Job configuration

Now, configure the _example-pipeline_ job to start a build when triggered by a Gogs webhook.

From the homeapage, select the **example-pipeline** job.

On the lefthand navigation pane, select **Configure**.

In the _Build Triggers_ section, select the **Build when a change is pushed to Gogs** checkbox and then click **Save** to apply the configuration.

With Jenkins properly configured, configure the _automate-cicd_ repository in Gogs.

Navigate to the Gogs server and select the _automate-cicd_ repository. 

Webhooks for a repository can be configured by selecting **Settings** and then **Webhooks** on the lefthand side navigation pane.

Click the **Add Webhooks** button and then select **Gogs**.

The _Payload URL_ refers to the endpoint exposed by the _Gogs Webhook_ plugin in Jenkins. Enter **https://localhost:8443/gogs-webhook/?job=example-pipeline** into the textbox.

Leave the rest of the options to the default values and select **Add Webhook** to configure the new webhook.

Confirm the webhook is configured properly by selecting the edit button represented by the pencil icon next to the URL previously configured. 

Send a test invocation by selecting the **Test Delivery** button to verify the webhook. The result will be available in the _Recent Deliveries_ section. If a green checkmark appears next to the delivery, the test was successful. You can click on the delivery ID to view the request that was sent to Jenkins as well as the response. 

Most importantly, in Jenkins, validate the _example-pipeline_ job was executed as a result of the invocation. Now, when changes are pushed to the repository, the Jenkins job will automatically execute fufilling requirement for achieving Continuous Integration.