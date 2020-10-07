#!/bin/bash

# 前置任务：
#   git clone https://github.com/longhorn/longhorn
helm install longhorn ./longhorn/chart -n longhorn-system \
    --create-namespace \
    --set persistence.defaultClassReplicaCount=1 \
    --set defaultSettings.defaultReplicaCount=1 \
    --set csi.attacherReplicaCount=1 \
    --set csi.provisionerReplicaCount=1 -\
    -set csi.resizerReplicaCount=1