#!/bin/bash
clear
echo -e "\033[1;36mCreate Containers\033[0m"

user=$(id | awk '{print $1}' | sed 's/.*(//;s/)$//')

sudo docker run \
-d \
-it \
--restart=always \
--name $user-kspray-deployer-container \
--tmpfs /tmp \
--tmpfs /run \
--tmpfs /run/lock \
-v /sys/fs/cgroup:/sys/fs/cgroup:ro \
nileshc85/kubespraymaster:22.04

echo -e "\033[1;36mCopy IP and HOST Files in Container\033[0m"

for spawn in $( sudo docker ps | grep -i $user | grep -i kspray | awk {'print $1'} ) ; \
do sudo docker cp /tmp/$user/textfiles/test4.txt $spawn:/ip.txt ; done

for spawn in $( sudo docker ps | grep -i $user | grep -i kspray | awk {'print $1'} ) ; \
do sudo docker cp /tmp/$user/textfiles/test2.txt $spawn:/hostentry.txt ; done

echo -e "\033[1;36mGet Inside of Container\033[0m"
for spawn in $( sudo docker ps | grep -i $user | grep -i kspray | awk {'print $1'} ) ; \
do sudo docker exec -it -u root $spawn bash ; done