Install Wildfly Standalone
==========================

This role installs a standalone instance of Wildfly in a Red Hat host in a fashion that allows several instances running in parallel in the same host. The instance managed by this role will be declared as a systemd service.

Requirements
------------

This role uses the unarchive module to decompress the EAP binaries ZIP file, therefore **this module requires the unzip command to be installed in all target hosts**.

Role Variables
--------------

- instance_name: Name of the Wildfly instance to be created. Will be used to create dedicated directories under the base binaries and logs ones. It will be also used for the service name (wildfly-{{ instance_name }}).
- wildfly_user: OS user to be used to execute all Wildfly processes. This user will own all Wildfly related paths as well.
- wildfly_group: OS group to own all Wildfly related paths.
- wildfly_bin_path: Base path for binaries.
- wildfly_logs_path: Base path for logs.
- wildfly_binaries_url: URL to download the Wildfly binaries from.
- java_version: Java version to install.
- wildfly_http_management_port: Wildfly management port.
- wildfly_http_port: Wildfly HTTP port.
- wildfly_https_port: Wildfly HTTPS port.
- wildfly_ajp_port: Wildfly AJP port.



Dependencies
------------

None

Example Playbook
----------------

    - hosts: servers
      become: true
      gather_facts: false
      roles:
        - install_wildfly_standalone

License
-------

BSD

Author Information
------------------

rromannissen
