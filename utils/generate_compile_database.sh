#!/bin/bash

PROJECT_PATH="`dirname \"$0\"`"                    # relative path
PROJECT_PATH="`(cd \"$PROJECT_PATH\" && pwd)`"      # absolute path

if [ "$#" -eq 1 ]; then
    PROJECT_PATH="`(cd \"$1\" && pwd)`"            # absolute path
fi

(
cd $PROJECT_PATH
compdb -p "${PROJECT_PATH}/build" list > compile_commands.json
)
