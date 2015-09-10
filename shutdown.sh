#!/bin/sh
# Provision instances

export ANSIBLE_HOST_KEY_CHECKING=False

ansible-playbook -i "localhost," --extra-vars="number_es_instances=0 number_ls_instances=0" spawn.yml
