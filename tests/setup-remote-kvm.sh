#!/usr/bin/env bash
set +x

user=$1
host=$2
port=$3
snap=$4
kvm_user=test
home=~

if [ $# -lt 4 ]; then
    echo "Invalid number of arguments provided"
    echo "Run as ./$0 user host kvm_ssh_port snap_file"
    exit 1
fi

ssh $user@$host "if [ -d image ]; then rm -rf image; fi"
scp -r ../spread/image/ $user@$host:~/
scp -r kvm-exec.sh $user@$host:~/image/
ssh $user@$host "apt update"
ssh $user@$host "apt -y install qemu-kvm socat ubuntu-image kpartx"
ssh $user@$host "cd image; ./create-image.sh"
ssh $user@$host "cd image; ./kvm-exec.sh stop"
ssh $user@$host "cd image; ./kvm-exec.sh start >/dev/null"
sleep 120
ssh-keygen -f "$home/.ssh/known_hosts" -R [$host]:$port
./remote-install-snap.sh $kvm_user $host $port $4
./run-tests.sh $kvm_user $host $port true
