helm upgrade metrics-server bitnami/metrics-server -n kube-system --set "extraArgs.kubelet-insecure-tls"=,apiService.create=t│
rue --install