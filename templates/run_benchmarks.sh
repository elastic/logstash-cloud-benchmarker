#!/bin/bash

ES={{ groups['tag_aws_autoscaling_groupName_avc_estest_elasticsearch_asg'][0] }}
ESURL=http://$ES:9200
DURATION=1800
WARMUP=60

export LS_HEAP_SIZE=4g

function kill_ls {
  killall -15 java
  sleep 2
  killall -9 java
}

function clear_es {
  echo "Deleting all logstash indices on $ESURL"
  curl -s -XDELETE $ESURL/logstash-*
  curl -s -XPUT 'localhost:9200/_template/logstash_template' -d '
  {
    "template" : "logstash-*",
    "settings" : {"number_of_replicas" : 0 }
  }'
  echo ""
}

function clear_benchmarks {
  echo "Clearing old benchmarks"
  rm -rf results/
  mkdir -p results/benchmarks

  rm -rf logs/
  mkdir -p logs/benchmarks
}

function record_results {
  echo "Will record results to $1"
  curl -s "$ESURL/logstash-*/_count" > results/$1.results
  echo ""
}

function sleep_kill {
  echo "Will wait $WARMUP secs for startup"
  sleep $WARMUP

  echo "Resetting the DB prior to count"
  clear_es

  echo "Will wait $DURATION secs to count"
  sleep $DURATION

  kill_ls
}

function run_test {
  kill_ls

  echo "Will run test $1"
  clear_es

  echo "Removing old sincedb files"
  rm -rfv ~/.sincedb*

  sleep_kill &
  echo "Starting logstash"
  bin/logstash -w 2 -f $1 >logs/$1 2>logs/$1.err

  echo "Checking count"
  record_results $1

  process_results
}

function process_results {
  print_results > results/summary & # In case this dies on weird input
  echo
  echo "---------------"
  echo "*** RESULTS ***"
  cat results/summary | sort
  echo "---------------"
  echo
}

function run_benchmarks {
  benchmark_files=benchmarks/*
  for bf in $benchmark_files
  do
    run_test $bf
  done
}

function print_result {
  count=`jq .count $1`
  rate=$(($count / $DURATION))
  echo "$1: $rate events/sec . ($count total events)"
}

function print_results {
  result_files=results/benchmarks/*.results
  for rs in $result_files
  do
    print_result $rs
  done
}

clear_benchmarks

if [ $# -eq 0 ]
  then
    run_benchmarks
  else
    for bf in "$@"
    do
      run_test $1
    done
fi
