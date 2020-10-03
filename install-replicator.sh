#!/bin/bash

# 前置任务：
#   `helm repo add mittwald https://helm.mittwald.de`
# 此Chart的作用是从不同的命名空间复制想要的东西，目前我想复制的是wildcard certificates
helm install kubernetes-replicator mittwald/kubernetes-replicator -n kubernetes-replicator