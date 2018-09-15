[Molecule](http://molecule.readthedocs.io/en/latest/) is a framework to implement automated tests for Ansible playbooks and roles.

In this folder you can find two different Ansible roles, both configured to run Molecule:
- ansible-role-banner
  - This role installs a simple message of the day (MOTD) in a RHEL/CentOS server.
- ansible-role-httpd
  - This is the same [Apache httpd installation role for the Hackathon](hackathons/rhte-2018-emea/roles/ansible-role-httpd/README.md) with the addditional Molecule configuration.

Each role have a **molecule** directory with the following components:
  - **molecule/docker:** Name of the Docker scenario, which will execute a complete set of tests using a Docker driver.
  - **molecule/vagrant:** Name of the Vagrant scenario, which will execute a complete set of tests using a Vagrant+libvirt driver.
  - **molecule/common/prepare.yml**: A pplyabook tha will be executed firsti in order to setup the test server.
  - **molecule/tests**: [Testinfra](https://testinfra.readthedocs.io/en/latest/) tests written in Python to be executed on servers after the role execution.

The Hackathon Jenkins server is prepared to run Molecule, you can review the installation guide [here](https://molecule.readthedocs.io/en/stable/installation.html).

In order to run molecule an check an Ansible role run the following commands in the role directory:
  - **molecule test:** Executes the complete set of tests defined in the scenario.
  - **molecule syntax:** Only executes syntax checks on the role
  - **molecule verify:** Only executes tests on servers

In this example the `ansible-role-banner` passes all tests and installs, but ansible-role-httpd does not.

It could be a nice exercise to try fix `ansible-role-httpd`. Run Molecule and check output. You may need to review the role, the tests and the Docker image used.
