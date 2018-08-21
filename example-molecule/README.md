[Molecule](http://molecule.readthedocs.io/en/latest/) is a framework to implement automated tests.
- Components:
  - **molecule/default:** Name of the default scenario, which will execute the complete set of tests
  - **molecule/default/molecule.yml:** Configuration file. It includes the number of servers to deploy and the provider where to deploy them.
  - **molecule/default/tests/:** Tests to be executed on servers after the role execution.


- Ansible Integration:
Copy this folder to the root directory of an ansible role to integrate molecule with that role.

- Examples:
  - **molecule test:** Executes the complete set of tests defined in the scenario.
  - **molecule syntax:** Only executes syntax checks on the role
  - **molecule verify:** Only executes tests on servers

```
$ molecule test
--> Validating schema /home/isanchez/ws/nacho/automate-cicd/ansible-role-banner/molecule/default/molecule.yml.
Validation completed successfully.
--> Test matrix

└── default
    ├── lint
    ├── destroy
    ├── dependency
    ├── syntax
    ├── create
    ├── prepare
    ├── converge
    ├── idempotence
    ├── side_effect
    ├── verify
    └── destroy

--> Scenario: 'default'
--> Action: 'lint'
--> Executing Yamllint on files found in /home/isanchez/ws/nacho/automate-cicd/ansible-role-banner/...
Lint completed successfully.
--> Executing Flake8 on files found in /home/isanchez/ws/nacho/automate-cicd/ansible-role-banner/molecule/default/../tests/...
Lint completed successfully.
--> Executing Ansible Lint on /home/isanchez/ws/nacho/automate-cicd/ansible-role-banner/molecule/common/playbook.yml...
Lint completed successfully.
--> Scenario: 'default'
--> Action: 'destroy'

    PLAY [Destroy] *****************************************************************

    TASK [Destroy molecule instance(s)] ********************************************
    ok: [localhost] => (item=None)
    ok: [localhost]

    TASK [Populate instance config] ************************************************
    ok: [localhost]

    TASK [Dump instance config] ****************************************************
    skipping: [localhost]

    PLAY RECAP *********************************************************************
    localhost                  : ok=2    changed=0    unreachable=0    failed=0


--> Scenario: 'default'
--> Action: 'dependency'
Skipping, missing the requirements file.
--> Scenario: 'default'
--> Action: 'syntax'

    playbook: /home/isanchez/ws/nacho/automate-cicd/ansible-role-banner/molecule/common/playbook.yml

--> Scenario: 'default'
--> Action: 'create'

    PLAY [Create] ******************************************************************

    TASK [Create molecule instance(s)] *********************************************
    changed: [localhost] => (item=None)
    changed: [localhost]

    TASK [Populate instance config dict] *******************************************
    ok: [localhost] => (item=None)
    ok: [localhost]

    TASK [Convert instance config dict to a list] **********************************
    ok: [localhost]

    TASK [Dump instance config] ****************************************************
    changed: [localhost]

    PLAY RECAP *********************************************************************
    localhost                  : ok=4    changed=2    unreachable=0    failed=0


--> Scenario: 'default'
--> Action: 'prepare'

    PLAY [Prepare] *****************************************************************

    TASK [Gathering Facts] *********************************************************
    ok: [rhel7]

    TASK [Ensure required packages are installed] **********************************
    ok: [rhel7] => (item=libselinux-python)

    PLAY RECAP *********************************************************************
    rhel7                      : ok=2    changed=0    unreachable=0    failed=0


--> Scenario: 'default'
--> Action: 'converge'

    PLAY [Converge] ****************************************************************

    TASK [Gathering Facts] *********************************************************
    ok: [rhel7]

    TASK [ansible-role-banner : Ensure Post-Login Message of the Day file is correct] ***
    changed: [rhel7]

    PLAY RECAP *********************************************************************
    rhel7                      : ok=2    changed=1    unreachable=0    failed=0


--> Scenario: 'default'
--> Action: 'idempotence'
Idempotence completed successfully.
--> Scenario: 'default'
--> Action: 'side_effect'
Skipping, side effect playbook not configured.
--> Scenario: 'default'
--> Action: 'verify'
--> Executing Testinfra tests found in /home/isanchez/ws/nacho/automate-cicd/ansible-role-banner/molecule/default/../tests/...
    ============================= test session starts ==============================
    platform linux2 -- Python 2.7.15, pytest-3.6.2, py-1.5.4, pluggy-0.6.0
    rootdir: /home/isanchez/ws/nacho/automate-cicd/ansible-role-banner/molecule, inifile:
    plugins: testinfra-1.12.0
collected 1 item                                                               

    ../tests/test_default.py .                                               [100%]

    =========================== 1 passed in 2.36 seconds ===========================
Verifier completed successfully.
--> Scenario: 'default'
--> Action: 'destroy'

    PLAY [Destroy] *****************************************************************

    TASK [Destroy molecule instance(s)] ********************************************
    changed: [localhost] => (item=None)
    changed: [localhost]

    TASK [Populate instance config] ************************************************
    ok: [localhost]

    TASK [Dump instance config] ****************************************************
    changed: [localhost]

    PLAY RECAP *********************************************************************
    localhost                  : ok=3    changed=2    unreachable=0    failed=0

```

- Scenarios:
  - **default**: Created to deploy instances on a vagrant over libvirtd. Boxes will be obtained from vagrant.

- Preparation:
  - **prepare.yml**: Will be executed by default, it will configure instances to be Ansible compliant and ready for action.

When using default scenario, following tests will be executed:

    ├── lint          Yaml validator on role
    ├── destroy       Destroy testing servers
    ├── dependency    requirements.yml execution
    ├── syntax        Syntax checks
    ├── create        Create testing servers
    ├── prepare       Execute preparing playbooks (molecule/default/prepare.yml)
    ├── converge      Execute role on servers
    ├── idempotence   Check role idempotency on servers
    ├── side_effect   Check side effects on role
    ├── verify        Execute tests from molecule/default/tests/* on servers
    └── destroy       Delete testing servers
