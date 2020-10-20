curl -sfL http://rancher-mirror.cnrancher.com/k3s/k3s-install.sh | INSTALL_K3S_MIRROR=cn INSTALL_K3S_SKIP_START=true sh -l -s -- --no-deploy traefik --write-kubeconfig-mode 644
mkdir -p /etc/rancher/k3s/
cat <<EOF > /etc/rancher/k3s/registries.yaml
mirrors:
  "docker.io":
    endpoint:
      - https://kfwkfulq.mirror.aliyuncs.com
      - https://2lqq34jg.mirror.aliyuncs.com
      - https://pee6w651.mirror.aliyuncs.com
      - http://hub-mirror.c.163.com
      - https://docker.mirrors.ustc.edu.cn
      - https://registry.docker-cn.com
EOF
curl -sfL http://rancher-mirror.cnrancher.com/k3s/v1.18.9-k3s1/k3s-airgap-images-amd64.tar -O
mkdir -p /var/lib/rancher/k3s/agent/images/
mv ./k3s-airgap-images-amd64.tar /var/lib/rancher/k3s/agent/images/
systemctl start k3s
