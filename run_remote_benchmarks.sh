#!/bin/sh -ex
# Provision instances

export ANSIBLE_HOST_KEY_CHECKING=False

# Provision services on top of instances
ansible-playbook -u ubuntu -i ec2.py --private-key ~/.ssh/andrewvc.pem provision.yml --tags benchmarking

ls_host=`python ec2.py --list | jq -r .tag_Role_avc_test_logstash[0]`
ssh ubuntu@$ls_host "sh -c 'cd /mnt/logstash/logstash*/ && nohup ./run_benchmarks.sh 2>&1 1>last_run.out & sleep 2 && cd /mnt/logstash/logstash*/ && tail -F last_run.out'"
