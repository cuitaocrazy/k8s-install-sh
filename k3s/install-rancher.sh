helm install rancher rancher-stable/rancher -n cattle-system \
  --set tls=external,replicas=1,hostname=rancher.yadadev.com \
  --create-namespace

cat <<EOF | kubectl -n cattle-system apply -f -
apiVersion: traefik.containo.us/v1alpha1
kind: IngressRoute
metadata:
  name: rancher-websecre
spec:
  entryPoints:
  - websecure
  routes:
  - kind: Rule
    match: Host(\`rancher.yadadev.com\`)
    services:
    - name: rancher
      port: 80
  tls:
    certResolver: le
    domains:
    - main: yadadev.com
      sans:
      - '*.yadadev.com'
EOF
