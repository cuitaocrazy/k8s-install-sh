#!/bin/bash

# 2020-10-2
# 前置任务：
#   `helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx`
#   修改`/etc/kubernetes/manifests/kube-apiserver.yaml`加入`--service-node-port-range=1-65535`
# 各个参数的修改参照ingress-nginx的values.yaml
# 最方便的获取values.yaml的方法使用`helm pull ingress-nginx/ingress-nginx`获取
# 默认镜像在google资料库上，我是使用本地pull的镜像save出再到服务器load上的，因此hash无法验证
# 因此加入`--set controller.image.digest=`参数去掉签名
# `k8s.gcr.io/ingress-nginx/controller:v0.35.0`为ingress-nginx的目前最新镜像，
# `registry.cn-hangzhou.aliyuncs.com/google_containers`无法找到
# 默认service的type是走负载均衡，因此修改为NodePort
# NodePort的端口范围是30000-32767，因此需要修改`/etc/kubernetes/manifests/kube-apiserver.yaml`
helm install ingress-nginx \
    ingress-nginx/ingress-nginx \
    -n ingress-nginx --create-namespace \
    --set controller.image.digest= \
    --set controller.service.type=NodePort \
    --set controller.service.nodePorts.http=80 \
    --set controller.service.nodePorts.https=443
