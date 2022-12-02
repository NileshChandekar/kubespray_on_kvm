#### kubespray_on_kvm

![iameg](https://github.com/NileshChandekar/kubespray_on_kvm/blob/main/images/featuredImage_hu3bced1e920add2777bea4e2136b2d62b_53357_700x350_fill_q95_box_smart1_2.png)

Creating an HA cluster using Kubespray and understanding how the control plane’s components behave
---

* Kubespray is a composition of Ansible playbooks, inventory, provisioning tools, and domain knowledge for generic OS/Kubernetes clusters configuration management tasks.

Pre-requisites ### On baremetal node.
---

* install KVM 
* Install Docker
* Install Tmux. 

Assumptions
---

* This documentation guides you in setting up a cluster with ``1`` MasterNode and ``2`` WorkerNode.
* We don't have to config anything on the K8S nodes now, Everything will be pushed via **container** aka **deployer node**
* We have 1 network attached to all the Master and Worker nodes [eth0] ip [192.168.122.0/24 - eth0]

|Role|FQDN|
|----|----|
|Deployer Node|Container|

```
5b10b9a79814   ubuntu:22.04                               "bash"                   3 hours ago    Up 3 hours              kspray-deployer-kube
```

|Role|FQDN|eth0|OS|RAM|CPU|
|----|----|----|----|----|----|
|Master|kube-kspray-master-0|192.168.122.59|Ubuntu 22.04|12G|6|
|Worker|kube-kspray-worker-0|192.168.122.19|Ubuntu 22.04|16G|6|
|Worker|kube-kspray-worker-1|192.168.122.39|Ubuntu 22.04|16G|6|


### Infrastructure Setup: 

|Role|
|----|
|Baremetal Node|


* On your Physical Machine aka **Baremetal** node: Logged in with your **$username** example **kube**
* Download the script, that will helpful to 
     * Customize the image : https://github.com/NileshChandekar/imagecustomization/blob/main/imagecustomize.sh
     * Create Infra Nodes  : https://github.com/NileshChandekar/kubespray_on_kvm/blob/main/scripts/setupinfra.sh

|Customize the image|
|----|

* Download the image in ``/tmp``
* Edit the script and provide the path of the image. 
```
declare LIBVIRT_BASE_DIRECTORY=/tmp
declare LIBVIRT_BASE_UBUNTU_QCOW2=jammy-server-cloudimg-amd64.qcow2
```
|Create Infra Nodes|
|----|

* Run the script: 

```
kube@baremetal:~$  bash  setup_infra.sh
```

* If this run(s) then you will have output something like: 

```
kube-kspray-master-0 192.168.122.59
kube-kspray-worker-0 192.168.122.19
kube-kspray-worker-1 192.168.122.39
```

```
192.168.122.59
192.168.122.19
192.168.122.39
```

Container Creation: 
---

|Role|
|----|
|Baremetal Node|

* **Container** aka **deployer node** is prebuild with Recommended requirements and dependencies. like:-
     * python3-pip
     * ansible 2.12
     * python3-virtualenv      
* Container is build using a virtual environment. 
* Download the script, that will help you to create container. 
```
wget https://github.com/NileshChandekar/kubespray_on_kvm/blob/main/scripts/cc.sh
```

* Run the script command:
 
```
kube@baremetal:~$  bash  cc.sh
```

* At this moment you will have output something like: 

```
Create Containers
95a6095f3e6a5ba595b6a70c542f156ae716e4aa05d66b199dc2afdcc917a324
Copy IP and HOST Files in Container
Get Inside of Container
root@5b10b9a79814:~#
```

### Container Configuration: 

|Role|FQDN|
|----|----|
|Deployer Node|**Inside Container**|

* Download the script, Inside the Container. 

```
https://github.com/NileshChandekar/openstack-ansible-deploy/blob/main/script/in.sh
```

* Run the script command: 

```
root@5b10b9a79814:/# bash in.sh
```

### Activate **virtual environemnt** : 

* Command:

```
root@5b10b9a79814:/#  source /root/myenv/bin/activate
```

* Output: **Your Prompt will Change** 

```
(myenv) root@5b10b9a79814:~# 
```

* If the above is true, then we should have below output:

* Command: 

```
(venv) root@5b10b9a79814:/# ansible --version
```

* Output:

```
(myenv) root@5b10b9a79814:~# ansible --version
ansible [core 2.12.5]
  config file = None
  configured module search path = ['/root/.ansible/plugins/modules', '/usr/share/ansible/plugins/modules']
  ansible python module location = /root/myenv/lib/python3.10/site-packages/ansible
  ansible collection location = /root/.ansible/collections:/usr/share/ansible/collections
  executable location = /root/myenv/bin/ansible
  python version = 3.10.6 (main, Nov  2 2022, 18:53:38) [GCC 11.3.0]
  jinja version = 2.11.3
  libyaml = True
(myenv) root@5b10b9a79814:~# 
```

### Test pingtest , remember we already copyied **ip.txt** file while creating container. 

```
(myenv) root@5b10b9a79814:~# ansible -i /ip.txt -m ping all
192.168.122.19 | SUCCESS => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python3"
    },
    "changed": false,
    "ping": "pong"
}
192.168.122.59 | SUCCESS => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python3"
    },
    "changed": false,
    "ping": "pong"
}
192.168.122.39 | SUCCESS => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python3"
    },
    "changed": false,
    "ping": "pong"
}
(myenv) root@5b10b9a79814:~# 
```

### Now your Infra is ready, we can go for the kubespray deployment now. 


### Kubernetes Configuration: 

|Role|FQDN|
|----|----|
|Deployer Node|**Container**|

```
(myenv) root@5b10b9a79814:~# pwd
/root
(myenv) root@5b10b9a79814:~# 
(myenv) root@5b10b9a79814:~# ls -lhrt 
total 43M
drwxr-xr-x  4 root root 4.0K Dec  2 11:06 myenv
drwxr-xr-x 15 root root 4.0K Dec  2 11:15 kubespray
(myenv) root@5b10b9a79814:~# 
```

*Container is already build with kubespray git repository. 

```
(myenv) root@5b10b9a79814:~/kubespray# git branch -vva
* master                         b9fe3010 [origin/master] add-check-for-resolv-to-avoid-coredns-crash (#9502)
  remotes/origin/HEAD            -> origin/master
  remotes/origin/floryut-patch-1 3314f95b Fix README version for cni/flannel
  remotes/origin/master          b9fe3010 add-check-for-resolv-to-avoid-coredns-crash (#9502)
  remotes/origin/pre-commit-hook 2187882e fix contrib/<file>.md errors identified by markdownlint
  remotes/origin/release-2.10    ce0d111d update docker-ce to 18.09.7 (#4973) (#5162)
  remotes/origin/release-2.11    67167bd8 [2.11] fix broken scale procedure (#5926)
  remotes/origin/release-2.12    093d75f0 [2.12] Add 1.16.14 and 1.16.15 support (#6583)
  remotes/origin/release-2.13    cd832ead [2.13] Backport CI fix (#7119)
  remotes/origin/release-2.14    c3814bb2 Check kube-apiserver up on all masters before upgrade (#7193) (#7197)
  remotes/origin/release-2.15    82e90091 Add missing proxy environment in crio_repo.yml (#7492)
  remotes/origin/release-2.16    c91a05f3 debian: Fix test failed after bullseye release (#7888)
  remotes/origin/release-2.17    6ff35d0c CI: upgrade vagrant to 2.2.19 (#8264) (#8267)
  remotes/origin/release-2.18    70d4f70c [2.18] preinstall: Add nodelocaldns to supersede_nameserver if enabled
  remotes/origin/release-2.19    b75ee0b1 Define ostree variable for runc (#9417)
  remotes/origin/release-2.20    c553912f [2.20] Fix: install calico-kube-controller on kdd (#9358) (#9470)
  remotes/origin/release-2.7     05dabb7e Fix Bionic networking restart error #3430 (#3431)
  remotes/origin/release-2.8     d3f60799 bump rpm based docker versions to docker-ce-18.06.3.ce-3 (#4925)
  remotes/origin/release-2.9     fc1edbe7 Fix calico v3.4.0 scale and upgrade (#4531)
(myenv) root@5b10b9a79814:~/kubespray# 
```

Copy ``inventory/sample`` as ``inventory/mycluster``
---

```
cp -rfp inventory/sample inventory/mycluster
```

Update Ansible inventory file with inventory builder
---

```
declare -a IPS=(192.168.122.59 192.168.122.19 192.168.122.39)
```

Once you run below command you will have: 
---

```
CONFIG_FILE=inventory/mycluster/hosts.yaml python3 contrib/inventory_builder/inventory.py ${IPS[@]}
```

```
(myenv) root@5b10b9a79814:~/kubespray# cat inventory/mycluster/hosts.yaml 
all:
  hosts:
    node1:
      ansible_host: 192.168.122.59
      ip: 192.168.122.59
      access_ip: 192.168.122.59
    node2:
      ansible_host: 192.168.122.19
      ip: 192.168.122.19
      access_ip: 192.168.122.19
    node3:
      ansible_host: 192.168.122.39
      ip: 192.168.122.39
      access_ip: 192.168.122.39
  children:
    kube_control_plane:
      hosts:
        node1:
    kube_node:
      hosts:
        node2:
        node3:
    etcd:
      hosts:
        node1:
    k8s_cluster:
      children:
        kube_control_plane:
        kube_node:
    calico_rr:
      hosts: {}
(myenv) root@5b10b9a79814:~/kubespray# 
```

* ^^ , you can modify the data according to your need. 

Review and change parameters under ``inventory/mycluster/group_vars`` if needed. 
---

```
cat inventory/mycluster/group_vars/all/all.yml
cat inventory/mycluster/group_vars/k8s_cluster/k8s-cluster.yml
```

Deploy Kubespray with Ansible Playbook - run the playbook as root
---

```
ansible-playbook -i inventory/mycluster/hosts.yaml  --become --become-user=root cluster.yml
```

* It will take 15-20 min to form a k8s cluster. 

Verification:
---

```
(myenv) root@5b10b9a79814:~/kubespray# ssh 192.168.122.59
```

```
root@node1:~# kubectl get nodes
NAME    STATUS   ROLES           AGE   VERSION
node1   Ready    control-plane   72m   v1.25.4
node2   Ready    <none>          70m   v1.25.4
node3   Ready    <none>          70m   v1.25.4
root@node1:~# 
```

```
root@node1:~# kubectl get pods --all-namespaces
NAMESPACE     NAME                                      READY   STATUS    RESTARTS   AGE
kube-system   calico-kube-controllers-d6484b75c-tq5ck   1/1     Running   0          69m
kube-system   calico-node-2q57m                         1/1     Running   0          70m
kube-system   calico-node-6t675                         1/1     Running   0          70m
kube-system   calico-node-gfgr2                         1/1     Running   0          70m
kube-system   coredns-588bb58b94-mwmph                  1/1     Running   0          69m
kube-system   coredns-588bb58b94-nwzdc                  1/1     Running   0          69m
kube-system   dns-autoscaler-5b9959d7fc-qklvf           1/1     Running   0          69m
kube-system   kube-apiserver-node1                      1/1     Running   1          72m
kube-system   kube-controller-manager-node1             1/1     Running   1          72m
kube-system   kube-proxy-2qfvb                          1/1     Running   0          71m
kube-system   kube-proxy-5qhrb                          1/1     Running   0          71m
kube-system   kube-proxy-8mmf2                          1/1     Running   0          71m
kube-system   kube-scheduler-node1                      1/1     Running   1          72m
kube-system   nginx-proxy-node2                         1/1     Running   0          70m
kube-system   nginx-proxy-node3                         1/1     Running   0          70m
kube-system   nodelocaldns-78nhf                        1/1     Running   0          69m
kube-system   nodelocaldns-b8pdp                        1/1     Running   0          69m
kube-system   nodelocaldns-wnjg7                        1/1     Running   0          69m
root@node1:~# 
```

Access the cluster from deployer node. 
---

```
(myenv) root@5b10b9a79814:~/# mkdir /root/.kube
```

```
(myenv) root@5b10b9a79814:~/# scp root@192.168.122.59:/etc/kubernetes/admin.conf /root/.kube/config
```

*EDIT* 

```
vi /root/.kube/config
```

FROM: 

```
server: https://127.0.0.1:6443
```

TO:
```
server: https://192.168.122.59:6443
```

**NOTE** The container is already build with ``kubectl`` CLI. 

```
(myenv) root@5b10b9a79814:~# kubectl get pods --all-namespaces
NAMESPACE     NAME                                      READY   STATUS    RESTARTS   AGE
kube-system   calico-kube-controllers-d6484b75c-tq5ck   1/1     Running   0          74m
kube-system   calico-node-2q57m                         1/1     Running   0          74m
kube-system   calico-node-6t675                         1/1     Running   0          74m
kube-system   calico-node-gfgr2                         1/1     Running   0          74m
kube-system   coredns-588bb58b94-mwmph                  1/1     Running   0          73m
kube-system   coredns-588bb58b94-nwzdc                  1/1     Running   0          73m
kube-system   dns-autoscaler-5b9959d7fc-qklvf           1/1     Running   0          73m
kube-system   kube-apiserver-node1                      1/1     Running   1          76m
kube-system   kube-controller-manager-node1             1/1     Running   1          76m
kube-system   kube-proxy-2qfvb                          1/1     Running   0          75m
kube-system   kube-proxy-5qhrb                          1/1     Running   0          75m
kube-system   kube-proxy-8mmf2                          1/1     Running   0          75m
kube-system   kube-scheduler-node1                      1/1     Running   1          76m
kube-system   nginx-proxy-node2                         1/1     Running   0          74m
kube-system   nginx-proxy-node3                         1/1     Running   0          74m
kube-system   nodelocaldns-78nhf                        1/1     Running   0          73m
kube-system   nodelocaldns-b8pdp                        1/1     Running   0          73m
kube-system   nodelocaldns-wnjg7                        1/1     Running   0          73m
(myenv) root@5b10b9a79814:~# 
```

```
(myenv) root@5b10b9a79814:~# kubectl get nodes
NAME    STATUS   ROLES           AGE   VERSION
node1   Ready    control-plane   76m   v1.25.4
node2   Ready    <none>          75m   v1.25.4
node3   Ready    <none>          75m   v1.25.4
(myenv) root@5b10b9a79814:~# 
```

```
(myenv) root@5b10b9a79814:~# kubectl version --output=yaml
clientVersion:
  buildDate: "2022-11-09T13:36:36Z"
  compiler: gc
  gitCommit: 872a965c6c6526caa949f0c6ac028ef7aff3fb78
  gitTreeState: clean
  gitVersion: v1.25.4
  goVersion: go1.19.3
  major: "1"
  minor: "25"
  platform: linux/amd64
kustomizeVersion: v4.5.7
serverVersion:
  buildDate: "2022-11-09T13:29:58Z"
  compiler: gc
  gitCommit: 872a965c6c6526caa949f0c6ac028ef7aff3fb78
  gitTreeState: clean
  gitVersion: v1.25.4
  goVersion: go1.19.3
  major: "1"
  minor: "25"
  platform: linux/amd64

(myenv) root@5b10b9a79814:~# 
```

```
(myenv) root@5b10b9a79814:~# kubectl cluster-info
Kubernetes control plane is running at https://192.168.122.59:6443

To further debug and diagnose cluster problems, use 'kubectl cluster-info dump'.
(myenv) root@5b10b9a79814:~# 
```

Pod Testing
---

```
(myenv) root@5b10b9a79814:~# kubectl run myshell -it --rm --image busybox -- sh
```
```
root@5b10b9a79814:/# kubectl run myshell2 -it --rm --image busybox -- sh
```

```
root@5b10b9a79814:/# kubectl get pod -o wide
NAME       READY   STATUS    RESTARTS   AGE   IP            NODE    NOMINATED NODE   READINESS GATES
myshell    1/1     Running   0          93s   10.233.71.1   node3   <none>           <none>
myshell2   1/1     Running   0          75s   10.233.71.2   node3   <none>           <none>
root@5b10b9a79814:/# 
```

```
(myenv) root@5b10b9a79814:~# kubectl run myshell -it --rm --image busybox -- sh
If you don't see a command prompt, try pressing enter.
/ # hostname -i 
10.233.71.1
/ # 
/ # 
```

```
root@5b10b9a79814:/# kubectl run myshell2 -it --rm --image busybox -- sh
If you don't see a command prompt, try pressing enter.
/ # 
/ # hostname -i 
10.233.71.2
/ # 
```

```
(myenv) root@5b10b9a79814:~# kubectl run myshell -it --rm --image busybox -- sh
If you don't see a command prompt, try pressing enter.
/ # hostname -i 
10.233.71.1
/ # 
/ # ping -c3 10.233.71.2
PING 10.233.71.2 (10.233.71.2): 56 data bytes
64 bytes from 10.233.71.2: seq=0 ttl=63 time=0.640 ms
64 bytes from 10.233.71.2: seq=1 ttl=63 time=0.246 ms
64 bytes from 10.233.71.2: seq=2 ttl=63 time=0.234 ms

--- 10.233.71.2 ping statistics ---
3 packets transmitted, 3 packets received, 0% packet loss
round-trip min/avg/max = 0.234/0.373/0.640 ms
/ #
```

```
root@5b10b9a79814:/# kubectl run myshell2 -it --rm --image busybox -- sh
If you don't see a command prompt, try pressing enter.
/ # 
/ # hostname -i 
10.233.71.2
/ # ping -c3 10.233.71.1
PING 10.233.71.1 (10.233.71.1): 56 data bytes
64 bytes from 10.233.71.1: seq=0 ttl=63 time=0.300 ms
64 bytes from 10.233.71.1: seq=1 ttl=63 time=0.255 ms
64 bytes from 10.233.71.1: seq=2 ttl=63 time=0.229 ms

--- 10.233.71.1 ping statistics ---
3 packets transmitted, 3 packets received, 0% packet loss
round-trip min/avg/max = 0.229/0.261/0.300 ms
/ # 
```


