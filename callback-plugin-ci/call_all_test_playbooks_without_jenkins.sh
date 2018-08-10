#!/bin/bash

SELF="$(dirname $0)"
cd "$SELF"

export BUILD_NUMBER=$(date '+%Y-%m-%dT%H-%M-%S')
TEST_DIRECTORY="examples"
TEST_PATTERN="test*"
LOG_DIRECTORY=/tmp/ansible-junit-logs
export JUNIT_TASK_RELATIVE_PATH=$PWD

function Usage() {
    cat <<EOF
$0 [--help|-h] [options...] [ansible-playbook arguments, e.g. --limit]
  Options:
    --build BUILD_NUMBER                # default '$BUILD_NUMBER'
    --pattern TEST_PATTERN              # default '$TEST_PATTERN'
    --test-directory TEST_DIRECTORY     # default '$TEST_DIRECTORY'
    --log-directory LOG_DIRECTORY       # default '$LOG_DIRECTORY'
    --report-directory REPORT_DIRECTORY # default '$REPORT_DIRECTORY'
EOF
}

declare TMP_ARGS=($@)
while [[ ${#TMP_ARGS} -gt 0 ]]; do
    arg="${TMP_ARGS[0]}"
    # shift
    TMP_ARGS=("${TMP_ARGS[@]:1}")

    case "$arg" in
        --help|-h)
	    Usage
            exit 0
        ;;
        --build)
            BUILD_NUMBER="${TMP_ARGS[0]}"
            TMP_ARGS=("${TMP_ARGS[@]:1}")
        ;;
        --pattern)
            TEST_PATTERN="${TMP_ARGS[0]}"
            TMP_ARGS=("${TMP_ARGS[@]:1}")
        ;;
        --test-directory)
            TEST_DIRECTORY="${TMP_ARGS[0]}"
            TMP_ARGS=("${TMP_ARGS[@]:1}")
        ;;
        --log-directory)
            LOG_DIRECTORY="${TMP_ARGS[0]}"
            TMP_ARGS=("${TMP_ARGS[@]:1}")
        ;;
        --report-directory)
            REPORT_DIRECTORY="${TMP_ARGS[0]}"
            TMP_ARGS=("${TMP_ARGS[@]:1}")
        ;;
        *)
            ARGS+=("$arg")
        ;;
    esac
done

export JUNIT_FAIL_ON_IGNORE=true
export JUNIT_OUTPUT_DIR="$LOG_DIRECTORY/$BUILD_NUMBER"


set -x

for playbook in $(find "$TEST_DIRECTORY" -name "$TEST_PATTERN.yml" | sort -n -t /)
do
    ansible-playbook "${ARGS[@]}" "$playbook"
    local_rc=$?
    if [[ $local_rc -ne 0 ]]; then
        rc=1
    fi
done


exit $rc
