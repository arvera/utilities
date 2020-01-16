#!/bin/bash
#
# Created by Angel Vera (gunfus@gmail.com) (angel.vera@hcl.com)
# Extracted from https://www.linuxtechi.com/install-kubernetes-1-7-centos7-rhel7/ and adapted to CentOS8
# with also the help from: https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/install-kubeadm/

setenforce 0

# Step 1
echo "...Dissabling SELINUX"
#
sed -i --follow-symlinks 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/sysconfig/selinux


# Step 2
echo "...Ensure that firewalld is enabled"
#
systemctl enable firewalld
systemctl start firewalld
firewall-cmd --state

# Step 3
echo "...Setup firewalld rules for k8s"
#
firewall-cmd --permanent  --add-port=6443/tcp
firewall-cmd --permanent --add-port=2379-2380/tcp
firewall-cmd --permanent --add-port=10250/tcp
firewall-cmd --permanent --add-port=10251/tcp
firewall-cmd --permanent --add-port=10252/tcp
firewall-cmd --permanent --add-port=10255/tcp
firewall-cmd --reload


modprobe br_netfilter
# this was documented in the orignal site, but CentOS 8 already has the bit set to 1
#echo '1' > /proc/sys/net/bridge/bridge-nf-call-iptables

# Step 4
echo "...Adding k8s repo to yum.d"
#
KUBE_YUM_FILE="/etc/yum.repos.d/kubernetes.repo"
echo "[kubernetes] >$KUBE_YUM_FILE
echo "name=Kubernetes" >>$KUBE_YUM_FILE
echo "baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64" >>$KUBE_YUM_FILE
echo "enabled=1" >>$KUBE_YUM_FILE
echo "gpgcheck=1" >>$KUBE_YUM_FILE
echo "repo_gpgcheck=1" >>$KUBE_YUM_FILE
echo "gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg" >>$KUBE_YUM_FILE
echo "       https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg" >>$KUBE_YUM_FILE

# Step 5
echo "...Installing k8s"
yum install kubeadm docker -y

# Step 6
echo "...enabled k8s and docker"
# only required on centos7
systemctl restart kubelet.service && systemctl enable kubelet.service
systemctl enable --now kubelet 

#A bunch of manual steps

# Step 7
echo "...disabling swap"

# Step 8
swapoff -a


