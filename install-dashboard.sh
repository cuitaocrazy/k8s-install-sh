#!/bin/bash

# 2020-10-2
# 前置任务：
#   `helm repo add kubernetes-dashboard https://kubernetes.github.io/dashboard/`
# dashbord通过web访问，并且可以做k8s的操作，不建议在公网部署
# dashbord可以无密码登陆或跳过登陆，可以不通过https访问，这些可通过这个chart的values.yaml查看配置
# 为安全起见，默认部署
# --set extraArgs[0]="--enable-skip-login"
# token需要创建用户
# https://github.com/kubernetes/dashboard/blob/master/docs/user/access-control/creating-sample-user.md
# cat <<EOF | kubectl apply -f -
# apiVersion: v1
# kind: ServiceAccount
# metadata:
#   name: admin-user
#   namespace: kubernetes-dashboard
# EOF
#
# cat <<EOF | kubectl apply -f -
# apiVersion: rbac.authorization.k8s.io/v1
# kind: ClusterRoleBinding
# metadata:
#   name: admin-user
# roleRef:
#   apiGroup: rbac.authorization.k8s.io
#   kind: ClusterRole
#   name: cluster-admin
# subjects:
# - kind: ServiceAccount
#   name: admin-user
#   namespace: kubernetes-dashboard
# EOF
#
# kubectl -n kubernetes-dashboard describe secret $(kubectl -n kubernetes-dashboard get secret | grep admin-user | awk '{print $1}')

helm install kubernetes-dashboard kubernetes-dashboard/kubernetes-dashboard \
    -n kubernetes-dashboard \
    --create-namespace \
    --set protocolHttp=true \
    --set service.externalPort=80 \
    --set extraArgs[0]="--enable-insecure-login" \
    --set extraArgs[1]="--system-banner=\"Welcome to Kubernetes\""