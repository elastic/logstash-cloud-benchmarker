# logstash-es-output-benchmarker

You'll need a valid .boto

To use this run `setup.sh`, then run `run_remote_benchmarks.sh`.

You may need to `ssh-add mykey.pem` using your aws key. You'll also want to set
this key in the vars of spawn.yml.

To shut down the cluster run `shutdown.sh`