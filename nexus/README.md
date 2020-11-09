# nexus资料库

没有任何理由在项目中不使用自己的资料库。

因为其重要性。单独出一个主题详细说明。

当部署nexus时，最好直接让他接触证书体系，而是通过nginx，nginx-ingress，traefik等这样的反响代理软件去做去挂证书，避免配置复杂性。

## 自己使用

自己机器上部署nexus时，如果想做docker的mirro，就要使用有效的证书，尽量和公共环境的配置一致，避免一些特殊设置。

自己在机器上的`/etc/hosts`里添加域名，注意：hosts里配的实际上是机器名，我们只是把他当域名用，因此他不支持通配符域名这样的东西。

```bash
sudo cat <<EOF >> hosts
127.0.0.1 repo.example.com
127.0.0.1 registry.example.com
EOF
```

第一个域名给nexus的普通资料库用，第二个给docker资料库用。

下一步我们要签发一个通配符证书。

```bash
openssl req -x509 -newkey rsa -nodes -subj /CN=nexus \
	-extensions san -days 3650 -keyout server.key -out server.crt \
	-config <(echo "[req]";echo distinguished_name=req;echo "[san]";echo subjectAltName=DNS:*.example.com)
```

把server.crt添加的系统环境里：

- mac：钥匙链添加用户里即可（双击证书），注意添加后，证书->显示简介->信任->始终信任
- Ubuntu：把证书拷贝到`/usr/local/share/ca-certificates/`，没有文件夹就建一个，执行`update-ca-certificates`
- CentOS：把证书拷贝到`/etc/pki/ca-trust/source/anchors/`，执行`update-ca-trust`

到此，我们就认为证书和域名都有了，下一步开始部署反向代理环境。

我只说下k8s的部署:

```bash
# 添加证书到k8s
kubectl create secret tls mycert --key server.key --cert server.crt -n kube-system
# 部署nginx-ingress，设置他的默认证书
helm install ingress-controller center/bitnami/nginx-ingress-controller -n kube-system --set extraArgs.default-ssl-certificate='kube-system/mycert'
# 部署nexus
helm upgrade nexus -n repos center/sonatype/nexus-repository-manager --install --create-namespace --values - <<EOF
ingress:
  enabled: true
  hostRepo: repo.example.com
  hostDocker: registry.example.com
  tls:
    - secretName: ~
      hosts:
        - "*.example.com"
EOF
```

注意：nexus在helm上生产的ingress基本上用的默认值，需要添加`nginx.ingress.kubernetes.io/proxy-body-size: 100m`到annotations上，不然当提交一些大的docker文件时会拒绝，目前搞了100M，估计还是不够的。

## 公网环境部署

搞个过审的域名，证书用lets encrypt免费申请，ingress用treafik。

感觉很简单，具体部署时在补充脚本。

## nexus配置

