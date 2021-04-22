#!/usr/bin/env bash
#
# Create tasks*.yml for import Zabbix hosts by Ansible
#
# Lukas Maly <Iam@LukasMaly.NET> 22.4.2021
#

# Create easy import file
egrep "(host_name|address|hostgroups)" nagios/hosts.cfg | awk 'BEGIN {FS=FS = ",[ \t]*|[ \t]+"}{print $3}' > nagios_hosts.txt

# Check dir tasks
if [[ -d tasks ]]
then
    echo "Directory tasks exists on your filesystem."
    rm -rf ./tasks/*.yml
else
    mkdir tasks
fi

# Check generated file
if [[ -f "import-hosts.yml" ]]
then
    echo "File import-hosts.yml exists on your filesystem."
    rm -rf import-hosts.yml
fi

# Generated task for import
while read -r HOST_NAME; do
    read -r ADDRESS
    read -r HOSTGROUPS
    echo "Create task for $HOST_NAME"

cat << xYMLx >> tasks/$HOST_NAME.yml
---
- name: Create $HOST_NAME $ or update
  zabbix_host:
    server_url: "{{ server_url }}"
    login_user: "{{ lookup('env','ZABBIX_USER') }}"
    login_password: "{{ lookup('env','ZABBIX_PASSWORD') }}"
    host_name: $HOST_NAME
    visible_name: $HOST_NAME
    host_groups:
     - $HOSTGROUPS
    link_templates:
     - ICMP Ping
    status: enabled
    state: present
    inventory_mode: automatic
    interfaces:
      - type: 1
        main: 1
        useip: 1
        ip: $ADDRESS
        port: "10050"
xYMLx
done < nagios_hosts.txt

# Create new ansible playbook with included tasks
echo "Create anslibe playbook for import hosts"
cat << xYMLx >> import-hosts.yml
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
echo "    - include_tasks: tasks/$y" >> import-hosts.yml
done

# Run ansible playbook for import all zabbix hosts
ansible-playbook import-hosts.yml

# EOF
