#!/bin/sh
# Provision instances

export ANSIBLE_HOST_KEY_CHECKING=False

ansible-playbook -i "localhost," --extra-vars="number_es_instances=3 number_ls_instances=1" spawn.yml

echo "Wait for all the servers to spin up inside ASGs, then press enter to continue"
read continue

# Provision services on top of instances
ansible-playbook -u ubuntu -i ec2.py --private-key ~/.ssh/andrewvc.pem provision.yml --skip-tags benchmarking

echo "You may now execute ./run_remote_benchmarks.sh"
