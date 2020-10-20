# 前置任务
#   helm repo add center https://repo.chartcenter.io
helm install elasticsearch center/elastic/elasticsearch \
    -n logs --create-namespace \
    --set image=elasticsearch \
    --set imageTag=7.9.2 \
    --set replicas=1 --set minimumMasterNodes=1

# fluent解析有点问题，不会配 以后再说 用filebeat替换
# helm install fluent center/fluent/fluent-bit -n logs \
#   --set metrics.enabled=true \
#   --set backend.type=es \
#   --set backend.es.time_key='@ts' \
#   --set backend.es.host=elasticsearch-master \
#   --set backend.es.tls=on \
#   --set backend.es.tls_verify=off

helm install filebeat center/elastic/filebeat -n logs  --set image=elastic/filebeat,imageTag=7.9.2

cat <<EOF | helm install kibana center/elastic/kibana -n logs --values -
image: "kibana"
imageTag: "7.9.2"
kibanaConfig:
  kibana.yml: |
    i18n.locale: "zh-CN"
EOF
