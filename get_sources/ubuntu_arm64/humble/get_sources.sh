#!/bin/bash

if [[ $# -ne 1 ]]; then
    echo "Illegal number of parameters. Required to specify path."
    exit 1
fi


THIS_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
WORKSPACE_DIR_PATH="$1"

# Download sources
REPOS_FILE_PATH="$THIS_DIR/ros2.repos"

cd $WORKSPACE_DIR_PATH
vcs import src < $REPOS_FILE_PATH
