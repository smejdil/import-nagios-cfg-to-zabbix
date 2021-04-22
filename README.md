## Import Nagios hosts.cfg to Zabbix

Easy shell script for make ansible tasks.yml from Nagios hosts.cfg and import Zabbix host groups and hosts using Ansible

* Tested on FreeBSD 13 with Zabbix 5.0 LTS

### Packages FreeBSD

- Package - py37-pip-20.3.4                Tool for installing and managing Python packages
- Package - py37-ansible-2.9.7             Radically simple IT automation

### How it works

Ansible use collections https://galaxy.ansible.com/community/zabbix and by
Zabbix API import host groups and hosts to Zabbix monitoring system.

- Python package - zabbix-api 0.5.4

### Install FreeBSD

```console
cd /usr/ports/devel/py-pip && make install clean
cd /usr/ports/sysutils/ansible && make install clean

pip install zabbix-api
```

### Install ansible collection zabbix

```console
ansible-galaxy collection install -r requirements.yml
Process install dependency map
Starting collection install process
Installing 'community.zabbix:1.3.0' to '/root/.ansible/collections/ansible_collections/community/zabbix'
```

### Make and run playbook
```console
export ZABBIX_USER=zabbix_admin_user
export ZABBIX_PASSWORD=*******************

./import-zabbix-hostgroups.sh
./import-zabbix-hosts.sh
```

### To do

- Test on other OS
- Test Zabbix 5.2