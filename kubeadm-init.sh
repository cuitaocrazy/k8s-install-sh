#!/bin/bash

# 打算用calico，需要192.168的网段
kubeadm init --pod-network-cidr=192.168.0.0/16 --image-repository registry.cn-hangzhou.aliyuncs.com/google_containers

# root用户添加
# echo "export KUBECONFIG=/etc/kubernetes/admin.conf" >> /root/.bashrc
KUBECONFIG=/etc/kubernetes/admin.conf

# 单节点部署，需要污染节点
kubectl taint nodes --all node-role.kubernetes.io/master-
# 扩大NodePort范围
sed '16i\ \ \ \ - --service-node-port-range=1-65535' -i /etc/kubernetes/manifests/kube-apiserver.yaml
