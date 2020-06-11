#!/bin/bash

oc new-project cloudpak-monitoring

oc apply -f grafana-setup/cpak-monitoring-og.yaml

oc apply -f grafana-setup/cpak-grafana-sub.yaml 

echo "Waiting for Operator to spin up"
sleep 10

oc apply -f grafana-setup/cloudpak-grafana.yaml

echo "Waiting for Operator to spin up Grafana resources"
sleep 10

oc expose svc grafana-service -n cloudpak-monitoring

if [ "$(uname)" == "Darwin" ]; then

  oc get secret prometheus-k8s-htpasswd -n openshift-monitoring -o jsonpath='{.data.auth}{"\n"}' | base64 -D > /tmp/htpasswd-tmp
  oldpass=$(cat /tmp/htpasswd-tmp)
  addpass='grafana-test:{SHA}EiAf5eICiDvUX8l+hzZuoFGD4OQ='
  newpass="${oldpass}\n${addpass}"
  newpass_enc=$(echo -e $newpass | base64)
  oc patch secret prometheus-k8s-htpasswd -n openshift-monitoring -p "{\"data\":{\"auth\":\"$newpass_enc\"}}"

else
  
  oc get secret prometheus-k8s-htpasswd -n openshift-monitoring -o jsonpath='{.data.auth}{"\n"}' | base64 -d > /tmp/htpasswd-tmp
  oldpass=$(cat /tmp/htpasswd-tmp)
  addpass='grafana-test:{SHA}EiAf5eICiDvUX8l+hzZuoFGD4OQ='
  newpass="${oldpass}\n${addpass}"
  newpass_enc=$(echo -e $newpass | base64 -w0)
  oc patch secret prometheus-k8s-htpasswd -n openshift-monitoring -p "{\"data\":{\"auth\":\"$newpass_enc\"}}"

fi

oc delete pod -l app=prometheus -n openshift-monitoring

oc apply -f grafana-setup/prom-datasource.yaml 

oc apply -f ocp-dashboards/grafana-dashboard-cluster-total.yaml

oc apply -f ocp-dashboards/grafana-dashboard-etcd.yaml

oc apply -f ocp-dashboards/grafana-dashboard-k8s-resources-cluster.yaml

oc apply -f ocp-dashboards/grafana-dashboard-k8s-resources-namespace.yaml

oc apply -f ocp-dashboards/grafana-dashboard-k8s-resources-node.yaml

oc apply -f ocp-dashboards/grafana-dashboard-k8s-resources-pod.yaml

oc apply -f ocp-dashboards/grafana-dashboard-k8s-resources-workload.yaml

oc apply -f ocp-dashboards/grafana-dashboard-k8s-resources-workloads-namespace.yaml

oc apply -f ocp-dashboards/grafana-dashboard-node-cluster-rsrc-use.yaml

oc apply -f ocp-dashboards/grafana-dashboard-node-rsrc-use.yaml

oc apply -f ocp-dashboards/grafana-dashboard-prometheus.yaml

oc apply -f ocp-dashboards/grafana-dashboards.yaml

echo "Setup complete! You can access your dashboards using the following routes: "
oc get routes -n cloudpak-monitoring 
echo 'Your Grafana admin login is root:Passw0rd!'

