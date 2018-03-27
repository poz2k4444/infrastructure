#!/bin/sh
# Script: /usr/local/bin/wrapper.sh
#command="$SSH_ORIGINAL_COMMAND"; shift
set $SSH_ORIGINAL_COMMAND
command="$1"; shift
case "$command" in
    "uname")
        /home/helpcenter-deploy/bin/own-uname
        ;;
    *)
        echo "Sorry. Only these commands are available to you:"
        echo "uname"
        exit 1
        ;;
esac
