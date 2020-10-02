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

## install-ingress-nginx.sh

安装ingress，详细信息查看注释

## install-cert-manager.sh

安装证书管理

## install-dashboard.sh

安装仪表盘
