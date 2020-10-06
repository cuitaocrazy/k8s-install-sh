#!/bin/bash

# 前置任务：
#   `helm repo add traefik https://helm.traefik.io/traefik`
#   分配好一个pv，我们的acme.json要存储到这个地方，traefik不负责状态处理
# 参数太多，最好写一个`values.yaml`文件用`--values values.yaml`参数安装
# --certificatesresolvers.le.acme.caserver=https://acme-staging-v02.api.letsencrypt.org/directory
# 生产中弃掉，这是测试caServer，默认值是生产的caServer
# helm install traefik traefik/traefik -n traefik \
#     --create-namespace \
#     --set additionalArguments=[ \
#         "--certificatesresolvers.le.acme.email=ctllfh@gmail.com", \
#         "--certificatesresolvers.le.acme.storage=/data/acme.json", \
#         "--certificatesresolvers.le.acme.dnschallenge.provider=alidns", \
#         "--certificatesresolvers.le.acme.caserver=https://acme-staging-v02.api.letsencrypt.org/directory" \
#     ] \
#  写不下去了。。。
cat <<EOF | helm template traefik traefik/traefik -n traefik --create-namespace --values -
additionalArguments:
  - --certificatesresolvers.le.acme.email=ctllfh@gmail.com
  - --certificatesresolvers.le.acme.storage=/data/acme.json
  - --certificatesresolvers.le.acme.dnschallenge.provider=alidns
  - --certificatesresolvers.le.acme.caserver=https://acme-staging-v02.api.letsencrypt.org/directory
env:
  - name: ALICLOUD_ACCESS_KEY
    value: LTAI4Fojyd71AnBNBrGrpNsz
  - name: ALICLOUD_SECRET_KEY
    value: $1
  - name: ALICLOUD_REGION_ID
    value: cn-beijing
persistence:
  enabled: true
  storageClass: manual
  path: /data
service:
  type: NodePort
ports:
  traefik:
    expose: true
    nodePort: 9000
  web:
    nodePort: 80
  websecure:
    nodePort: 443
EOF