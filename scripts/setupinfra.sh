#!/bin/bash

clear

read -p "Enter MasterNode Count: " infra
read -p "Enter WorkerNode Count: " cmpt

read -p "Enter Master Memory Size: " mem_infra
read -p "Enter Worker Memory Size: " mem_cmpt

echo -e "\033[1;36mCreating Directories\033[0m"
user=$(id | awk '{print $1}' | sed 's/.*(//;s/)$//')

sudo rm -fr /tmp/$user
sudo rm -fr /openstack/images/jemmy
sudo mkdir -p /openstack/images/jemmy
mkdir -p /tmp/$user/textfiles




echo -e "\033[1;36mUDownload Ubuntu Image\033[0m"
cd /openstack/images/jemmy
if ! ls -al jammy-server-cloudimg-amd64.qcow2 ; then
      echo "Downloading Ubuntu Image" ; \
      sudo rsync -aivh --progress /tmp/jammy-server-cloudimg-amd64.qcow2 /openstack/images/jemmy/  > /dev/null
 else 
      echo "Server Image already exist."
fi


echo -e "\033[1;36mSpawning K8S  $infra ** Master Nodes **\033[0m"

cd /openstack/images/jemmy
user=$(id | awk '{print $1}' | sed 's/.*(//;s/)$//')
i=0
j=0
for img in `seq 1 $infra`; \
    do sudo qemu-img create \
    -f qcow2 \
    -F qcow2 \
    -o backing_file=/openstack/images/jemmy/jammy-server-cloudimg-amd64.qcow2 \
    /openstack/images/jemmy/$user-kspray-master-$((j++)).qcow2 ; \
    done > /dev/null
i=0
j=0


cmd_infra() {
sudo virt-install --name $user-kspray-master-$((i++))  \
--memory $mem_infra \
--vcpus 6 \
--disk /openstack/images/jemmy/$user-kspray-master-$((j++)).qcow2,bus=sata \
--import \
--os-variant ubuntu20.04 \
--network network:external \
--network bridge=providerbr0,model=virtio \
--network bridge=vlanbr0,model=virtio \
--network bridge=provisionbr0,model=virtio \
--noautoconsole \
--vnc \
--cpu SandyBridge,+vmx
}

for a in `seq 1 $infra`; do cmd_infra ; done 



echo -e "\033[1;36mSpawning K8S  $cmpt ** Worker Nodes **\033[0m"

cd /openstack/images/jemmy
user=$(id | awk '{print $1}' | sed 's/.*(//;s/)$//')
i=0
j=0
for img in `seq 1 $cmpt`; \
    do sudo qemu-img create \
    -f qcow2 \
    -F qcow2 \
    -o backing_file=/openstack/images/jemmy/jammy-server-cloudimg-amd64.qcow2 \
    /openstack/images/jemmy/$user-kspray-worker-$((j++)).qcow2 ; \
    done > /dev/null
i=0
j=0



cmd_cmpt() {
sudo virt-install --name $user-kspray-worker-$((i++))  \
--memory $mem_cmpt \
--vcpus 6 \
--disk /openstack/images/jemmy/$user-kspray-worker-$((j++)).qcow2,bus=sata \
--import \
--os-variant ubuntu20.04 \
--network network:external \
--network bridge=providerbr0,model=virtio \
--network bridge=vlanbr0,model=virtio \
--network bridge=provisionbr0,model=virtio \
--noautoconsole \
--vnc \
--cpu SandyBridge,+vmx
}

for a in `seq 1 $cmpt`; do cmd_cmpt ; done

clear

sudo virsh list --all | grep -i $user | grep -i kspray 

echo -e "\033[1;36mWait for 100 Second\033[0m"


# 1. Paste the `progress` function in your bash script.
function progress () {
    s=0.5;
    f=0.25;
    echo -ne "\r\n";
    while true; do
           sleep $f && s=`echo ${s} + ${f} + ${f} | bc` && echo -ne "\r\t[             ] Elapsed: ${s} secs." \
        && sleep $f && s=`echo ${s} + ${f} + ${f} | bc` && echo -ne "\r\t[>            ] Elapsed: ${s} secs." \
        && sleep $f && s=`echo ${s} + ${f} + ${f} | bc` && echo -ne "\r\t[-->          ] Elapsed: ${s} secs." \
        && sleep $f && s=`echo ${s} + ${f} + ${f} | bc` && echo -ne "\r\t[--->         ] Elapsed: ${s} secs." \
        && sleep $f && s=`echo ${s} + ${f} + ${f} | bc` && echo -ne "\r\t[---->        ] Elapsed: ${s} secs." \
        && sleep $f && s=`echo ${s} + ${f} + ${f} | bc` && echo -ne "\r\t[----->       ] Elapsed: ${s} secs." \
        && sleep $f && s=`echo ${s} + ${f} + ${f} | bc` && echo -ne "\r\t[------>      ] Elapsed: ${s} secs." \
        && sleep $f && s=`echo ${s} + ${f} + ${f} | bc` && echo -ne "\r\t[------->     ] Elapsed: ${s} secs." \
        && sleep $f && s=`echo ${s} + ${f} + ${f} | bc` && echo -ne "\r\t[-------->    ] Elapsed: ${s} secs." \
        && sleep $f && s=`echo ${s} + ${f} + ${f} | bc` && echo -ne "\r\t[--------->   ] Elapsed: ${s} secs." \
        && sleep $f && s=`echo ${s} + ${f} + ${f} | bc` && echo -ne "\r\t[---------->  ] Elapsed: ${s} secs." \
        && sleep $f && s=`echo ${s} + ${f} + ${f} | bc` && echo -ne "\r\t[-----------> ] Elapsed: ${s} secs.";
           sleep $f && s=`echo ${s} + ${f} + ${f} | bc` && echo -ne "\r\t[------------>] Elapsed: ${s} secs.";
    done;
}

# 2. Then, somewhere in your script, wrap any long running process call as follows:
while true; do progress; done &
    sleep 50; # or, whatever
kill $!; trap 'kill $!' SIGTERM




user=$(id | awk '{print $1}' | sed 's/.*(//;s/)$//')
for i in $(sudo virsh list --all | grep -i $user| grep -i ksp | awk {'print $2'}); \
do echo $i ;  \
sudo virsh domifaddr $i | egrep -i 192 | awk {'print $4'} ; \
done > /tmp/$user/textfiles/test.txt

sed 'N;s/\n/ /' /tmp/$user/textfiles/test.txt > /tmp/$user/textfiles/test1.txt
cat /tmp/$user/textfiles/test1.txt | cut -d '/' -f1  > /tmp/$user/textfiles/test2.txt
cat /tmp/$user/textfiles/test2.txt | awk {'print $1'} > /tmp/$user/textfiles/test5.txt

sed 'N;s/\n/ /'  /tmp/$user/textfiles/test.txt  > /tmp/$user/textfiles/test1.txt ; cat /tmp/$user/textfiles/test1.txt | awk {'print $2'} > /tmp/$user/textfiles/test3.txt ; cat /tmp/$user/textfiles/test3.txt | cut -d '/' -f1 > /tmp/$user/textfiles/test4.txt


clear

echo -e "\033[1;36mHostname+IP\033[0m"
cat /tmp/$user/textfiles/test2.txt
echo -e "\033[1;36mHostname\033[0m"
cat /tmp/$user/textfiles/test5.txt
echo -e "\033[1;36mIP\033[0m"
cat /tmp/$user/textfiles/test4.txt
