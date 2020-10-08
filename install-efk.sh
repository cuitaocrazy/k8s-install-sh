# 前置任务
#   helm repo add center https://repo.chartcenter.io
helm install elasticsearch center/elastic/elasticsearch \
    -n logs --create-namespace \
    --set replicas=1 --set minimumMasterNodes=1

helm install fluent center/fluent/fluent-bit -n logs

helm install kibana center/elastic/kibana -n logs
