#!/bin/bash

set -x
cd $(dirname $0)

export JUNIT_FAIL_ON_IGNORE=true
export JUNIT_OUTPUT_DIR="${WORKSPACE:-/tmp}/ansible_junit_logs/$BUILD_NUMBER"
# export JUNIT_TASK_CLASS=true # gets rid of '.yml:<line>'
export JUNIT_TASK_RELATIVE_PATH=$PWD

export TEST_DIRECTORY="${JENKINS_ANSIBLE_DIRECTORY:-examples}"
export TEST_PATTERN="${JENKINS_ANSIBLE_TESTNAME:-test*}"

for playbook in $(find "$TEST_DIRECTORY" -name "$TEST_PATTERN.yml" | sort -n -t /)
do
    ansible-playbook "$@" "$playbook"
done

rc=$?

exit $rc
