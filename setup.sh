#!/usr/bin/env bash

export PATH="$PATH:~/.local/bin"

progname=`basename $0`
connection_type="local"

usage() {
    echo "Usage:"
    echo "    $progname -c <ssh|local> -p <playbook> -t <hostname>"
    echo ""
    echo "Options:"
    echo "    -c    Ansible connection type, default: local - (ssh|local)"
    echo "    -h    Show this help listing"
    echo "    -p    The playbook to play"
    echo "    -t    Target system host address"
}

while getopts c:h:p:t: flag; do
    case "${flag}" in
	c) connection_type=${OPTARG};;
	h) usage;;
        p) playbook=${OPTARG};;
	t) hostname=${OPTARG};;
	*) usage && exit 1
    esac
done

if [ -z $connection_type ]; then
    echo "Required argument: -t <ssh|local>"
    usage && exit 1
fi

if [ -z $playbook ]; then
    echo "Required argument: -p <playbook>"
    usage && exit 1
fi

if [ -z $hostname ]; then
    echo "Required argument: -t <hostname>"
    usage && exit 1
fi

if [ ! -f $playbook ]; then
    echo "ERROR: No such playbook: $playbook"
    exit 1
fi

echo "=============="
echo "HOSTNAME: $hostname"
echo "CONNECTION_TYPE: $connection_type"
echo "PLAYBOOK: $playbook"
echo "=============="

if ! ansible-playbook --help &> /dev/null; then
    python3 -m pip install --user ansible
fi

mkdir -p ~/.ansible/
echo "$hostname ansible_connection=$connection_type" > ~/.ansible/hosts

ansible-playbook $playbook -i ~/.ansible/hosts
