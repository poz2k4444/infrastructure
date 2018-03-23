#!/bin/sh
# Script: /usr/local/bin/wrapper.sh

case "$SSH_ORIGINAL_COMMAND" in
    "ps")
        ps -ef
        ;;
    "vmstat")
        vmstat 1 100
        ;;
    "cups stop")
        /etc/init.d/cupsys stop
        ;;
    "cups start")
        /etc/init.d/cupsys start
        ;;
    *)
        echo "Sorry. Only these commands are available to you:"
        echo "ps, vmstat, cupsys stop, cupsys start"
        exit 1
        ;;
esac
