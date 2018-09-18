# Jenkins and Ansible Tower Integration

This scenario focuses in showcasing the integration between Jenkins and Ansible Tower, while demonstrating the testing capabilities of the Molecule tool. Its aim is to create two different pipelines for a related purpose:

- A **playbook integration pipeline** that performs CI on the playbooks used to provision the required runtime for a certain application. A container managed by Molecule is created to perform tests.

- The **application deployment pipeline** that builds an artifact out of the source code and deploys it in a dynamically provisioned runtime using the playbook managed in the previous pipeline.

## Playbook integration pipeline

Setting up this pipeline is fairly easy, as it doesn't require any particular Jenkins configuration. Creating the pipeline using the provided jenkinsfile-role file under the jenkins directory should be enough to have it up and running.

The Molecule configuration file is available under the molecule directory inside the install_wildfly role directory.

## Application deployment pipeline

This pipeline uses, trough Ansible Tower Job Templates invoked by the Jenkins Tower Plugin, the install_wildfly and deploy_war playbooks (based mainly in the roles with the same name) to provision a Wildfly runtime environment in which to deploy an application to be built. Stages are:

- **Build**: Downloads the application source code and performs a Maven build. Once the build is done, the resulting artifact gets archived for later use.

- **Provision**: Creates and configures a Wildfly environment suitable to deploy the application. This environment includes a standalone installation of Wildfly (available in the *app1* host) and a PostgreSQL database (installed in the *appdb1* host). It also performs all the datasource configurations required for the application to run.

- **Deploy**: Deploys the previously built artifact into the Wildfly instance.

### Jenkins

It is convenient to perform this configuration in first place, as the first application build will take some time while Maven downloads the application dependencies. After everything has been set, launch the build. It will fail in the provision stage, as the Ansible Tower Job Templates are not available yet, but the build stage will perform all the downloads while you configure the Tower Instance.

- Login as administrator (admin/r3dh4t1!).

- Go to Manage Jenkins / Global Tool Configuration

- Create a JDK instance named jdk8 and with the following JAVA_HOME (no need to install a new one):

```
/usr/lib/jvm/java-1.8.0-openjdk
```

- Create a Maven installation named Maven 3.5.4 installing for Apache that same version.

- Go to Manage Jenkins / Configure System

- In the Maven Project Configuration, add the label maven.

- In the Ansible Tower configuration, add the parameters to point to the provided Tower installation (https://tower1.GUID.rhte.opentlc.com). You will have to add a new credential to access Tower (admin/r3dh4t1!).

- Create a Pipeline with the provided Jenkinsfile (either modify it on the git repo or copy/paste its contents and edit it to fit your environment configuration).

- In its first execution, Maven will "download the Internet". This won't happen again in subsequent executions, as dependencies are stored in the local .m2 repository.

### Ansible Tower

In this section, two job templates using the provided playbooks are created. Once everything has been set, the Jenkins pipeline should complete successfully.

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

```
artifact_url: "https://cicd1.GUID.rhte.opentlc.com:8443/job/deploy-hibernate-quickstart/{{ jenkins_build }}/artifact/target/hibernate.war"
```

### Application

The provided source code (available in the applications folder) is a slight modification of the hibernate quickstart application available in the Wildfly quickstarts repository (https://github.com/wildfly/quickstart). The only change included for this lab is the removal of the packaged datasource configuration file to force the use of the one configured by the provisioning stage of the pipeline.

Once the pipeline has successfully finished, the hibernate application should be available in:

```
http://app1.GUID.rhte.opentlc.com:8080/hibernate
```
