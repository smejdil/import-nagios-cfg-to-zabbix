#!/usr/bin/env bash
#
# Create tasks*.yml for import Zabbix hostgroups by Ansible
#
# Lukas Maly <Iam@LukasMaly.NET> 22.4.2021
#

# Create easy import file
egrep "(hostgroups)" nagios/hosts.cfg | awk 'BEGIN {FS=FS = ",[ \t]*|[ \t]+"}{print $3}' | sort | uniq > nagios_hostgroups.txt

# Check dir tasks
if [[ -d tasks ]]
then
    echo "Directory tasks exists on your filesystem."
    rm -rf ./tasks/*.yml
else
    mkdir tasks
fi

# Check generated file
if [[ -f "import-hostgroups.yml" ]]
then
    echo "File import-hostgroups.yml exists on your filesystem."
    rm -rf import-hostgroups.yml
fi

# Create yml task files for templates
for g in `cat nagios_hostgroups.txt`; do 
echo "Create task for $g"
cat << xYMLx >> tasks/$g.yml
---
- name: Create host groups $g
  zabbix_group:
    server_url: "{{ server_url }}"
    login_user: "{{ lookup('env','ZABBIX_USER') }}"
    login_password: "{{ lookup('env','ZABBIX_PASSWORD') }}"
    state: present
    host_groups:
      - $g
xYMLx
done

# Create new ansible playbook with included tasks
echo "Create anslibe playbook for import hostgroups"
cat << xYMLx >> import-hostgroups.yml
---
- name: Using Zabbix collection
  hosts: localhost
  collections:
    - community.zabbix

  vars_files:
    - vars/vars.yml

  tasks:
xYMLx

# Add included tasks to end of file
for y in `ls -1 ./tasks/`; do 
echo "    - include_tasks: tasks/$y" >> import-hostgroups.yml
done

# Run ansible playbook for import all zabbix host groups
ansible-playbook import-hostgroups.yml

# EOF
