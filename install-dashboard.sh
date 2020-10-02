#!/bin/bash

# 2020-10-2
# 前置任务：
#   `helm repo add kubernetes-dashboard https://kubernetes.github.io/dashboard/`
# dashbord通过web访问，并且可以做k8s的操作，不建议在公网部署
# dashbord可以无密码登陆或跳过登陆，可以不通过https访问，这些可通过这个chart的values.yaml查看配置
# 为安全起见，默认部署
helm install kubernetes-dashboard kubernetes-dashboard/kubernetes-dashboard \
    -n kubernetes-dashboard \
    --create-namespace