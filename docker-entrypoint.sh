#!/bin/bash
set -e

if [ "$1" = 'test' ]; then
    shift
    echo "Running test with args : $@"
    /srv/var/jmeter/non-functional-tests/scripts/perf_jmeter.sh --perf-test "$@"
elif [ "$1" = 'version' ]; then
    shift
    echo "$@"
    /srv/var/jmeter/non-functional-tests/scripts/perf_jmeter.sh --version
elif [ "$1" = 'help' ]; then
    shift
    echo "$@"
    /srv/var/jmeter/non-functional-tests/scripts/perf_jmeter.sh --help
elif [ "$1" = 'shell' ]; then
    shift
    echo "$@"
    /bin/bash
else
    echo $@
    /srv/var/jmeter/non-functional-tests/scripts/perf_jmeter.sh --help
fi
