#!/bin/bash

oc new-project grafana
oc process -f grafana.yaml |oc create -f -
oc rollout status deployment/grafana
oc adm policy add-role-to-user view -z grafana -n prometheus

payload="$( mktemp )"
cat <<EOF >"${payload}"
{
"name": "prometheus",
"type": "prometheus",
"typeLogoUrl": "",
"access": "proxy",
"url": "https://$( oc get route prometheus -n prometheus -o jsonpath='{.spec.host}' )",
"basicAuth": false,
"withCredentials": false,
"jsonData": {
    "tlsSkipVerify":true,
    "httpHeaderName1":"Authorization"
},
"secureJsonData": {
    "httpHeaderValue1":"Bearer $( oc sa get-token prometheus -n prometheus )"
}
}
EOF

# setup grafana data source
grafana_host="https://$( oc get route grafana -o jsonpath='{.spec.host}' )"
curl --insecure -H "Content-Type: application/json" -u admin:admin "${grafana_host}/api/datasources" -X POST -d "@${payload}"

# deploy openshift dashboard
dashboard_file="./openshift-cluster-monitoring.json"
sed -i.bak "s/Xs/${graph_granularity}/" "${dashboard_file}"
sed -i.bak "s/\${DS_PR}/prometheus/" "${dashboard_file}"
curl --insecure -H "Content-Type: application/json" -u admin:admin "${grafana_host}/api/dashboards/db" -X POST -d "@k8s-cluster-rsrc-use.json"
curl --insecure -H "Content-Type: application/json" -u admin:admin "${grafana_host}/api/dashboards/db" -X POST -d "@k8s-node-rsrc-use.json"
curl --insecure -H "Content-Type: application/json" -u admin:admin "${grafana_host}/api/dashboards/db" -X POST -d "@k8s-resources-cluster.json"
curl --insecure -H "Content-Type: application/json" -u admin:admin "${grafana_host}/api/dashboards/db" -X POST -d "@k8s-resources-namespace.json"
curl --insecure -H "Content-Type: application/json" -u admin:admin "${grafana_host}/api/dashboards/db" -X POST -d "@k8s-resources-pod.json"
mv "${dashboard_file}.bak" "${dashboard_file}"
