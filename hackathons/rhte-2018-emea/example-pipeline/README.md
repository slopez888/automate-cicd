This is an example of how to leverage Ansible and the [Jenkins Pipeline as Code](https://jenkins.io/solutions/pipeline/) concept as part of a Continuous Integration and Continuous Delivery Pipeline.

## Accessing Jenkins Server

As part of the provisioning of the lab, a Jenkins Continuous Integration server was deployed. The user interface can be accessed by navigating to [https://cicd1.GUID.rhte.opentlc.com:8443](https://cicd1.GUID.rhte.opentlc.com:8443). Credentials for logging in will be provided by your instructors.

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

Enter the following _Repository URL_: https://github.com/redhat-cop/automate-cicd.git

The logic for the pipeline is contained in a file called _Jenkinsfile_ within the _hackathons/rhte-2018-emea/example-pipeline_ directory.

Enter the following next to _Script Path_ to define the location of the Jenkinsfile: hackathons/rhte-2018-emea/example-pipeline/Jenkinsfile

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
