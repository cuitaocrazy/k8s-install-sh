#!/bin/bash

# 前置任务：
#   git clone https://github.com/longhorn/longhorn
#   dnf install iscsi-initiator-utils
helm install longhorn center/longhorn/longhorn -n longhorn-system \
    --create-namespace \
    --set persistence.defaultClassReplicaCount=1 \
    --set defaultSettings.defaultReplicaCount=1 \
    --set csi.attacherReplicaCount=1 \
    --set csi.provisionerReplicaCount=1 \
    --set csi.resizerReplicaCount=1 \
    --set defaultSettings.backupTarget=nfs://172.17.152.29:/
