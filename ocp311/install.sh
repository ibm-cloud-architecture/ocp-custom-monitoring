#!/bin/bash

oc new-project cloudpak-monitoring

oc process -f grafana.yaml |oc create -f -
oc rollout status deployment.apps/grafana

oc project cloudpak-monitoring

payload="$( mktemp )"
cat <<EOF >"${payload}"
{
"name": "prometheus",
"type": "prometheus",
"typeLogoUrl": "",
"access": "proxy",
"url": "https://$( oc get route prometheus-k8s -n openshift-monitoring -o jsonpath='{.spec.host}' )",
"basicAuth": false,
"withCredentials": false,
"jsonData": {
    "tlsSkipVerify":true,
    "httpHeaderName1":"Authorization"
},
"secureJsonData": {
    "httpHeaderValue1":"Bearer $( oc sa get-token prometheus-k8s -n openshift-monitoring )"
}
}
EOF

grafana_host="https://$( oc get route grafana -n cloudpak-monitoring -o jsonpath='{.spec.host}' )"
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

echo "Setup complete! You can access your dashboards using the following routes: "
oc get routes -n cloudpak-monitoring 
