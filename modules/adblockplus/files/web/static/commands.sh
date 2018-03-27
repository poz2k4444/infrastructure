#!/bin/sh
# Script: /usr/local/bin/wrapper.sh
#command="$SSH_ORIGINAL_COMMAND"; shift
set $SSH_ORIGINAL_COMMAND
command="$1"; shift
case "$command" in
    "deploy")
        /home/helpcenter-deploy/bin/deploy "$@"
        ;;
    *)
        echo "Sorry. Only these commands are available to you:"
        echo "deploy"
        exit 1
        ;;
esac
