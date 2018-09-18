import pytest


@pytest.mark.parametrize(
    'package', [
        'java-1.8.0-openjdk.x86_64',
        'java-1.8.0-openjdk-devel.x86_64'
        ]
    )
def test_packages(host, package):
    pkg = host.package(package)
    assert pkg.is_installed


def test_log_dir(host):
    dir = host.file('/var/log/wildfly/default')
    assert dir.exists
    assert dir.is_directory


def test_service(host):
    srv = host.service('wildfly-default')
    assert srv.is_running
    assert srv.is_enabled


def test_open_ports(host):
    s = host.socket("tcp://8080")
    assert s.is_listening
