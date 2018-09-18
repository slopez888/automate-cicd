# Jenkins and Ansible Tower Integration

## Playbook integration pipeline

## Application deployment pipeline

### Ansible Tower

- Create appserver and db groups in the Acme inventory and add app1 and appdb1 hosts to them respectively.

- Clone the automate-cicd project and create a new public repository in your Gogs instance with its root in the path /hackathons/rhte-2018-emea/tower-plugin-jenkins/playbooks/ (this is due to https://github.com/ansible/awx/issues/106)

- Create a new project pointing to the repository you created in Gogs and belonging to the Acme organization.

- Create a install_wildfly job template using:
  - The Acme inventory
  - The project you created in the previous step
  - The install_wildfly playbook
  - The Acme credential
  - No Extra Variables are required for this job template (default values from the playbook and roles will be used).

- Create a deploy_war job template using:
  - The Acme inventory
  - The project you created in the previous step
  - The deploy_war playbook
  - The Acme credential
  - An integer survey parameter named jenkins_build.
  - The following extra var, where GUID has to be the value of your environment:

artifact_url: "https://cicd1.GUID.rhte.opentlc.com:8443/job/deploy-hibernate-quickstart/{{ jenkins_build }}/artifact/target/hibernate.war"


### Jenkins

- Login as administrator (admin/r3dh4t1!).
- Go to Manage Jenkins / Global Tool Configuration
- Create a JDK instance named jdk8 and with the following JAVA_HOME (no need to install a new one):

/usr/lib/jvm/java-1.8.0-openjdk

- Create a Maven installation named Maven 3.5.4 installing for Apache that same version.

- Go to Manage Jenkins / Configure System

- In the Maven Project Configuration, add the label maven.

- Create a Pipeline with the provided Jenkinsfile (either modify it on the git repo or copy/paste its contents and edit it to fit your environment configuration).

- In its first execution, Maven will "download the Internet". This won't happen again in subsequent executions, as dependencies are stored in the local .m2 repository.
