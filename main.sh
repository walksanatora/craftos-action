#!/bin/bash
echo "Welcome to The CraftOS CI"
echo "CC root: $1"
echo "timeout: $2"
echo "args:    $3"
if [ -n "${GITHUB_WORKSPACE}" ]; then
    cd "$GITHUB_WORKSPACE"
    LD_LIBRARY_PATH=/usr/local/lib timeout "$2"s craftos --headless -d ./"$1" --args "$3"
    if [ $? -eq "124" ]; then
        echo "CC runner exited, timed out"
        exit 1
    else
        echo "CC runner did not timeout"
    fi
else
    echo "Not running in GH actions"
fi
bash
exit 0