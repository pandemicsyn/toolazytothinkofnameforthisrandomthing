swiftpkgs:
  pkg.installed:
    - skip_verify: True
    - pkgs:
        - curl
        - gcc
        - memcached
        - rsync
        - sqlite3
        - xfsprogs
        - git-core
        - libffi-dev
        - python-setuptools
        - python-coverage
        - python-dev
        - python-nose
        - python-mock
        - python-simplejson
        - python-xattr
        - python-eventlet
        - python-greenlet
        - python-pastedeploy
        - python-netifaces
        - python-pip
        - python-dnspython

swiftclientsetup:
  git.latest:
    - name: https://github.com/openstack/python-swiftclient.git
    - rev: master
    - target: /root/python-swiftclient
  cmd.wait:
    - name: python setup.py develop
    - cwd: /root/python-swiftclient
    - watch:
       - git: swiftclientsetup

swiftcoresetup:
  git.latest:
    - name: https://github.com/openstack/swift.git
    - rev: master
    - target: /root/swift
  cmd.wait:
    - name: python setup.py develop
    - cwd: /root/swift
    - watch:
       - git: swiftcoresetup

swiftinformantsetup:
  git.latest:
    - name: https://github.com/pandemicsyn/swift-informant.git
    - rev: master
    - target: /root/swift-informant
  cmd.wait:
    - name: python setup.py develop
    - cwd: /root/swift-informant
    - watch:
       - git: swiftinformantsetup

swiftbenchsetup:
  git.latest:
    - name: https://github.com/openstack/swift-bench.git
    - rev: master
    - target: /root/swift-bench
  cmd.wait:
    - name: python setup.py develop
    - cwd: /root/swift-bench
    - watch:
       - git: swiftinformantsetup
/var/cache/swift:
  file.directory:
    - user: root
    - group: root
    - mode: 755
    - makedirs: True
/var/cache/swift2:
  file.directory:
    - user: root
    - group: root
    - mode: 755
    - makedirs: True
/var/cache/swift3:
  file.directory:
    - user: root
    - group: root
    - mode: 755
    - makedirs: True
/var/cache/swift4:
  file.directory:
    - user: root
    - group: root
    - mode: 755
    - makedirs: True
/var/run/swift:
  file.directory:
    - user: root
    - group: root
    - mode: 755
    - makedirs: True


/etc/default/rsync:
  file.managed:
    - source: salt://swift/rsync
    - user: root
    - group: root
    - mode: 644
    - template: jinja

/etc/rsync.conf:
  file.managed:
    - source: salt://swift/rsync.conf
    - user: root
    - group: root
    - mode: 644
    - template: jinja
    - defaults:
        username : "root"

/var/log/swift:
  file.directory:
    - user: root
    - group: adm
    - mode: 775
    - makedirs: True

/etc/rsyslog.conf:
  file.managed:
    - source: salt://swift/rsyslog.conf
    - user: root
    - group: root
    - mode: 644

/etc/rsyslog.d/10-swift.conf:
  file.managed:
    - source: salt://swift/rsync
    - user: root
    - group: root
    - mode: 644

/etc/swift:
  file.recurse:
    - source: salt://swift/swiftconfs
    - template: jinja
    - defaults:
      username: "root"

makedisk:
  cmd.run:
    - name: /usr/bin/truncate -s 5GB /srv/swift-disk

/root/bin:
  file.recurse:
    - source: salt://swift/bin
    - template: jinja
    - file_mode: 775
    - defaults:
      username: "root"

/root/.bashrc:
  file.append:
    - text:
        - export SWIFT_TEST_CONFIG_FILE=/etc/swift/test.conf
        - export PATH=${PATH}:$HOME/bin

/etc/fstab:
  file.append:
    - text:
        - /srv/swift-disk       /mnt/sdb1    xfs loop,noatime,nodiratime,nobarrier,logbufs=8 0 0

resetenv:
  cmd.run:
    - name: /bin/bash /root/bin/resetswift

resetrings:
  cmd.run:
    - name: /bin/bash /root/bin/remakerings

/srv/1:
  file.symlink:
    - target: /mnt/sdb1/1
    - user: root
    - group: root
    - mode: 777
/srv/2:
  file.symlink:
    - target: /mnt/sdb1/2
    - user: root
    - group: root
    - mode: 777
/srv/3:
  file.symlink:
    - target: /mnt/sdb1/3
    - user: root
    - group: root
    - mode: 777
/srv/4:
  file.symlink:
    - target: /mnt/sdb1/4
    - user: root
    - group: root
    - mode: 777

startmain:
  cmd.run:
    - name: /bin/bash /root/bin/startmain

testly:
  cmd.run:
    - name: swift -A http://127.0.0.1:8080/auth/v1.0 -U test:tester -K testing stat
