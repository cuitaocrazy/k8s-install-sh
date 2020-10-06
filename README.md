# k8s-install-sh

## 前提

docker kubectl kubeselect kubeadm helm

```bash
helm repo add jetstack https://charts.jetstack.io
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo add kubernetes-dashboard https://kubernetes.github.io/dashboard
```

[阿里云的安装参照](https://developer.aliyun.com/article/763983)

阿里云资料库没有一些新的镜像，需要手动load

node: 注意dns解析ip，避免dns污染 [阿里云disable network自动配置](https://help.aliyun.com/document_detail/57803.html), 目前配置的dns时候`114.114.114.114`和`8.8.8.8`

目前发现的两个域名存在污染：\*.githubusercontent.com，\*.letsencrypt.org

## kubeadm-init.sh

执行初始化

node: root用户可在执行前把`export KUBECONFIG=/etc/kubernetes/admin.conf`加入到`~/.bashrc`

## install-calico.sh

安装calico配合coredns

# ingress controller

## 方案1

## install-traefik.sh

安装traefik，参数1:alidns的密钥（不便于在公共资料库公开）

e.g: ./install-traefik.sh FeAXXXXXXXXXXXXXXXXXXXXXX69bu

### 前置工作

创建本地pv：

```bash
mkdir -p /mnt/data
chmod 777 /mnt/data
```

```yaml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: task-pv-volume
  labels:
    type: local
spec:
  storageClassName: manual
  capacity:
    storage: 10Gi
  accessModes:
    - ReadWriteOnce
  hostPath:
    path: "/mnt/data"
```

[本地pv不能动态分配](https://kubernetes.io/zh/docs/concepts/storage/volumes/#local)

### 测试

test web:

```yaml
apiVersion: apps/v1 # for versions before 1.9.0 use apps/v1beta2
kind: Deployment
metadata:
  name: whoami-deployment
spec:
  selector:
    matchLabels:
      app: whoami
  template:
    metadata:
      labels:
        app: whoami
    spec:
      containers:
      - name: whoami
        image: containous/whoami:v1.5.0
        ports:
        - containerPort: 80
---
apiVersion: v1
kind: Service
metadata:
  name: whoami
spec:
  ports:
  - port: 80
    targetPort: 80
    protocol: TCP
  selector:
    app: whoami
```

ingress:

创建一个middleware用于http to https

```yaml
apiVersion: traefik.containo.us/v1alpha1
kind: Middleware
metadata:
  name: https-redirect
spec:
  redirectScheme:
    scheme: https
    permanent: true
```

创建一个80的IngressRoute

```yaml
apiVersion: traefik.containo.us/v1alpha1
kind: IngressRoute
metadata:
  name: whoami-web
spec:
  entryPoints:
  - web
  routes:
  - kind: Rule
    match: Host(`whoami.yadadev.com`)
    middlewares:
    - name: https-redirect
    services:
    - name: whoami
      port: 80
```

创建一个443的IngressRoute

```yaml
apiVersion: traefik.containo.us/v1alpha1
kind: IngressRoute
metadata:
  name: whoami-websecre
spec:
  entryPoints:
  - websecure
  routes:
  - kind: Rule
    match: Host(`whoami.yadadev.com`)
    services:
    - name: whoami
      port: 80
  tls:
    certResolver: le
    domains:
    - main: yadadev.com
      sans:
      - '*.yadadev.com'
```

## 方案2

以前我用的，现在作为备选

### install-ingress-nginx.sh

安装ingress，详细信息查看注释

### install-cert-manager.sh

安装证书管理

# 基础应用

## install-dashboard.sh

安装仪表盘