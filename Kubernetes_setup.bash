#!/usr/bin/bash

### Run as root user ###
sudo su

###Create the Repo###
cat <<EOF > /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
exclude=kube*
EOF

###Disable swap memory###
swapoff -a

### set to SELINUX property ####
setenforce 0
sed -i 's/^SELINUX=enforcing$/SELINUX=permissive/' /etc/selinux/config
yum install -y kubelet kubeadm kubectl --disableexcludes=kubernetes

###Enable Kublet service, starts on reboot###
systemctl enable --now kubelet

###Set up IP tables###
cat <<EOF >  /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF
sysctl --system

### Load br_netfilter modules###
lsmod | grep br_netfilter 
st=$?
if [ $st -ne 0 ] ; then 
modprobe br_netfilter
fi


# Install Docker CE
## Set up the repository
### Install required packages.
yum install -y yum-utils device-mapper-persistent-data lvm2

### Add docker repository.
yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo -y

## Install docker ce.
yum update -y
yum install -y docker-ce-18.06.2.ce

## Create /etc/docker directory.
mkdir /etc/docker

# Setup daemon.
cat > /etc/docker/daemon.json <<EOF
{
  "exec-opts": ["native.cgroupdriver=systemd"],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m"
  },
  "storage-driver": "overlay2",
  "storage-opts": [
    "overlay2.override_kernel_check=true"
  ]
}
EOF

mkdir -p /etc/systemd/system/docker.service.d

#### Restart docker ####
systemctl daemon-reload
systemctl restart docker
systemctl enable docker.service

yum install -y strace

### Configure cluster ###
kubeadm init --pod-network-cidr=192.168.0.0/16

### switch to cluser admin user###
su vagrant

###set up configuration for non root user###
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

###to untaint i.e. to allow schedule other pods in the master. this is mostly being used for single node cluster ##
kubectl taint nodes --all node-role.kubernetes.io/master-

### Download and install POD Network Calico ###
kubectl apply -f https://docs.projectcalico.org/v3.3/getting-started/kubernetes/installation/hosted/rbac-kdd.yaml
kubectl apply -f https://docs.projectcalico.org/v3.3/getting-started/kubernetes/installation/hosted/kubernetes-datastore/calico-networking/1.7/calico.yaml
