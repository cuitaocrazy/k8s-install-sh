#!/bin/bash

# 前置任务：
#   `helm repo add jetstack https://charts.jetstack.io`
helm install \
  cert-manager jetstack/cert-manager \
  --namespace cert-manager \
  --create-namespace \
  --set installCRDs=true