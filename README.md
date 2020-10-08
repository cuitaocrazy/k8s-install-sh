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

目前发现的一个域名存在污染：\*.githubusercontent.com

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

备注：

>  卸载traefik时会不会删除涉及他的资源（IngressRoute，Middleware），估计是为了好升级
>
> pvc没有用longhorn的持久卷管理，longhorn不会用，不知道如何浏览、添加删除文件，不想丢掉已经创建好的acme.json（不然每次都要请求证书，letsencypt有每周5次主域限制）。

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

# install-longhorn.sh

安装volume管理器

必须安装open-iscsi，[说明](https://longhorn.io/docs/0.8.0/install/requirements/)

```bash
# centos
yum install iscsi-initiator-utils
```

Dashboard的IngressRoute:

```yaml
apiVersion: traefik.containo.us/v1alpha1
kind: IngressRoute
metadata:
  name: longhorn-websecre
  namespace: longhorn-system
spec:
  entryPoints:
  - websecure
  routes:
  - kind: Rule
    middlewares:
    - name: longhorn-basic-auth
    match: Host(`longhorn.yadadev.com`)
    services:
    - name: longhorn-frontend
      port: 80
  tls:
    certResolver: le
    domains:
    - main: yadadev.com
      sans:
      - '*.yadadev.com'
```

为Dashboard加一个简单用户验证，[说明](https://doc.traefik.io/traefik/middlewares/basicauth/)：

```yaml
apiVersion: traefik.containo.us/v1alpha1
kind: Middleware
metadata:
  name: longhorn-basic-auth
  namespace: longhorn-system
spec:
  basicAuth:
    secret: longhorn-basic-secret
---
apiVersion: v1
kind: Secret
metadata:
  name: longhorn-basic-secret
  namespace: longhorn-system
data:
  users: bG9uZ2hvcm46JGFwcjEkc0FxcVV3Y3EkamFkY3VMMHJsd29NVFVmdG1UdHh1MQo=
```

备注：由于测试的服务器只有一个节点，还是master节点，因此脚本里的参数都改成1，longhorn默认的环境是3节点，参数也都是3，如果不改为1回出现各种错误，其中一个错误是：多个pod抢占一个块设备，导致成功分配pvc，但是挂载可能成功或不成功，但是最终成功，因为他会一直重试，正好碰到拿到锁的pod就会成功。

# 基础应用

## install-dashboard.sh

安装仪表盘

安装完后创建用户并绑定角色

```bash
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: ServiceAccount
metadata:
  name: admin-user
  namespace: kubernetes-dashboard
EOF
```

```bash
cat <<EOF | kubectl apply -f -
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: admin-user
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
subjects:
- kind: ServiceAccount
  name: admin-user
  namespace: kubernetes-dashboard
EOF
```

查找token

```bash
kubectl -n kubernetes-dashboard describe secret $(kubectl -n kubernetes-dashboard get secret | grep admin-user | awk '{print $1}')
```

## install-efk.sh

添加IngressRoute和简单验证

```yaml
apiVersion: traefik.containo.us/v1alpha1
kind: Middleware
metadata:
  name: kibana-basic-auth
  namespace: logs
spec:
  basicAuth:
    secret: kibana-basic-secret
---
apiVersion: v1
kind: Secret
metadata:
  name: kibana-basic-secret
  namespace: logs
data:
  users: a2liYW5hOiRhcHIxJEh5alQyZEh1JERRRUxpODVxbzJZNHFuLllaSnM4WC8K
---
apiVersion: traefik.containo.us/v1alpha1
kind: IngressRoute
metadata:
  name: kibana-websecre
  namespace: logs
spec:
  entryPoints:
  - websecure
  routes:
  - kind: Rule
    middlewares:
    - name: kibana-basic-auth
    match: Host(`kibana.yadadev.com`)
    services:
    - name: kibana-kibana
      port: 5601
  tls:
    certResolver: le
    domains:
    - main: yadadev.com
      sans:
      - '*.yadadev.com'
```

elasticsearch的pvc创建依赖于longhorn，如果手动加入pv或不使用持久自己设置values的参数

## install-prometheus-grafana.sh

添加IngressRoute参照上longhorn Dashboard

grafana登陆账户密码在secret：prometheus-grafana里

## install keycloak

没有用helm安装

测试可用一下部署

```yaml
apiVersion: apps/v1 # for versions before 1.9.0 use apps/v1beta2
kind: Deployment
metadata:
  name: keycloak-deployment
spec:
  selector:
    matchLabels:
      app: keycloak
  template:
    metadata:
      labels:
        app: keycloak
    spec:
      containers:
      - name: keycloak
        image: quay.io/keycloak/keycloak:11.0.2
        env:
        - name: KEYCLOAK_USER
          value: "admin"
        - name: KEYCLOAK_PASSWORD
          value: "admin"
        - name: PROXY_ADDRESS_FORWARDING
          value: "true"
        ports:
        - name: http
          containerPort: 8080
        - name: https
          containerPort: 8443
        readinessProbe:
          httpGet:
            path: /auth/realms/master
            port: 8080
---
apiVersion: v1
kind: Service
metadata:
  name: keycloak
spec:
  ports:
  - port: 8080
    targetPort: 8080
    protocol: TCP
  selector:
    app: keycloak
---
apiVersion: traefik.containo.us/v1alpha1
kind: IngressRoute
metadata:
  name: keycloak-websecre
spec:
  entryPoints:
  - websecure
  routes:
  - kind: Rule
    match: Host(`keycloak.yadadev.com`)
    services:
    - name: keycloak
      port: 8080
  tls:
    certResolver: le
    domains:
    - main: yadadev.com
      sans:
      - '*.yadadev.com'
```

