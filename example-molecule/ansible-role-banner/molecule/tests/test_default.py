def test_files(host):
    f = host.file('/etc/motd')
    assert f.exists
    assert f.user == 'root'
    assert f.group == 'root'
    assert f.mode == 0644
    assert f.md5sum == '58f62f1060075bab19139547f74e85fa'
