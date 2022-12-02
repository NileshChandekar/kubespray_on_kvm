#### kubespray_on_kvm

![iameg](https://github.com/NileshChandekar/kubespray_on_kvm/blob/main/images/featuredImage_hu3bced1e920add2777bea4e2136b2d62b_53357_700x350_fill_q95_box_smart1_2.png)

### Creating an HA cluster using Kubespray and understanding how the control plane’s components behave

* Kubespray is a composition of Ansible playbooks, inventory, provisioning tools, and domain knowledge for generic OS/Kubernetes clusters configuration management tasks.

### Pre-requisites ### On baremetal node.

* install KVM 
* Install Docker
* Install Tmux. 

### Assumptions

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
|----|----|----|----|----|----|----|
|Master|kube-kspray-master-0|192.168.122.59|Ubuntu 22.04|12G|6|
|Worker|kube-kspray-worker-0|192.168.122.19|Ubuntu 22.04|16G|6|
|Worker|kube-kspray-worker-1|192.168.122.39|Ubuntu 22.04|16G|6|


