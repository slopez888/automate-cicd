[Molecule](http://molecule.readthedocs.io/en/latest/) is a framework to implement automated tests for Ansible playbooks and roles.

In this repository you can find two Ansible role configured to run Molecule:
- [ansible-role-banner](../roles/ansible-role-banner)
- [ansible-role-httpd](../roles/ansible-role-httpd)


These roles have a **molecule** directory with the following components:
  - **molecule/docker:** Name of the Docker scenario, which will execute a complete set of tests using a Docker driver.
  - **molecule/vagrant:** Name of the Vagrant scenario, which will execute a complete set of tests using a Vagrant+libvirt driver.
  - **molecule/common/prepare.yml**: A playbook that will be executed first in order to setup the test server.
  - **molecule/tests**: [Testinfra](https://testinfra.readthedocs.io/en/latest/) tests written in Python to be executed on servers after the role execution.

The Hackathon Jenkins server host (cicd1.*GUID*.internal) is prepared to run Molecule. You can `git clone` this repo into this host to test both roles.

In order to run Molecule for an Ansible role run the following commands in the role directory:
  - **molecule test -s docker:** Executes the complete set of tests defined in the scenario.
  - **molecule syntax -s docker:** Only executes syntax checks on the role
  - **molecule verify -s docker:** Only executes tests on servers

Although it is not necessary for this environment, you can review the Molecule installation guide [here](https://molecule.readthedocs.io/en/stable/installation.html).
