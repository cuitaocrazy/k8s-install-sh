
# traefik
mkdir -p /mnt/data
chmod 777 /mnt/data
# 如果有acme.json copy到/mnt/data，并执行 chown 65532:65532 /mnt/data/acme.json
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: PersistentVolume
metadata:
  name: yada-acme
  labels:
    type: local
spec:
  storageClassName: manual
  capacity:
    storage: 200Mi
  accessModes:
    - ReadWriteOnce
  hostPath:
    path: "/mnt/data"
EOF
