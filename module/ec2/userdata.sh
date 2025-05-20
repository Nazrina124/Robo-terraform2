#!/bin/bash

pip3.11 install ansible hvac 2>&1 | tee -a /opt/userdata.log
ansible-pull -i localhost, -U https://github.com/Nazrina124/Ansible-Robo2 main.yml -e env=${env} -e role_name=${role_name} -e vault_token=${vault_token} 2>&1 | tee -a /opt/userdata.log

