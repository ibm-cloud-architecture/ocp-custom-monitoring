#!/bin/bash

oc new-project cloudpak-monitoring


oc apply -f cpak-monitoring-og.yaml

oc apply -f cpak-grafana-sub.yaml 

oc apply -f cloudpak-grafana.yaml

oc expose svc grafana-service

oc get routes

#oc get statefulset prometheus-k8s -o yaml -n openshift-monitoring > temp-prom.yaml
#sed -i '.bak' 's/--web.listen-address=127.0.0.1:9090/--web.listen-address=:9090/g' temp-prom.yaml
#oc apply -f temp-prom.yaml

#rm temp-prom.yaml
#rm temp-prom.yaml.bak 

#oc apply -f prometheus-datasource.yaml 

#oc apply -f grafana-dashboard-cluster-total.yaml

#oc apply -f grafana-dashboard-etcd.yaml

#oc apply -f grafana-dashboard-k8s-resources-cluster.yaml

#oc apply -f grafana-dashboard-k8s-resources-namespace.yaml

#oc apply -f grafana-dashboard-k8s-resources-node.yaml

#oc apply -f grafana-dashboard-k8s-resources-pod.yaml

#oc apply -f grafana-dashboard-k8s-resources-workload.yaml

#oc apply -f grafana-dashboard-k8s-resources-workloads-namespace.yaml

#oc apply -f grafana-dashboard-node-cluster-rsrc-use.yaml

#oc apply -f grafana-dashboard-node-rsrc-use.yaml

#oc apply -f grafana-dashboard-prometheus.yaml

#oc apply -f grafana-dashboards.yaml
