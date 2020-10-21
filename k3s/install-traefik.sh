cat <<EOF | helm install traefik center/traefik/traefik -n traefik --create-namespace --values -
additionalArguments:
  - --certificatesresolvers.le.acme.email=ctllfh@gmail.com
  - --certificatesresolvers.le.acme.storage=/data/acme.json
  - --certificatesresolvers.le.acme.dnschallenge.provider=alidns
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
EOF
