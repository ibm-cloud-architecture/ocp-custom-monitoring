#!/bin/bash

oc new-project cloudpak-monitoring

oc apply -f cpak-monitoring-og.yaml

oc apply -f cpak-grafana-sub.yaml 

oc apply -f cloudpak-grafana.yaml

echo "Waiting for Operator to spin up Grafana resources"
sleep 10

oc expose svc grafana-service -n cloudpak-monitoring

oc get routes

oc get secret prometheus-k8s-htpasswd -n openshift-monitoring -o jsonpath='{.data.auth}{"\n"}' | base64 -D > /tmp/htpasswd-tmp

htpasswd -s -b  /tmp/htpasswd-tmp grafana-test topsecret

oc patch secret prometheus-k8s-htpasswd -n openshift-monitoring -p "{\"data\":{\"auth\":\"$(base64 /tmp/htpasswd-tmp)\"}}"

oc delete pod -l app=prometheus -n openshift-monitoring

oc apply -f prom-datasource.yaml 

oc apply -f prometheus-datasource.yaml 

oc apply -f grafana-dashboard-cluster-total.yaml

oc apply -f grafana-dashboard-etcd.yaml

oc apply -f grafana-dashboard-k8s-resources-cluster.yaml

oc apply -f grafana-dashboard-k8s-resources-namespace.yaml

oc apply -f grafana-dashboard-k8s-resources-node.yaml

oc apply -f grafana-dashboard-k8s-resources-pod.yaml

oc apply -f grafana-dashboard-k8s-resources-workload.yaml

oc apply -f grafana-dashboard-k8s-resources-workloads-namespace.yaml

oc apply -f grafana-dashboard-node-cluster-rsrc-use.yaml

oc apply -f grafana-dashboard-node-rsrc-use.yaml

oc apply -f grafana-dashboard-prometheus.yaml

oc apply -f grafana-dashboards.yaml

oc apply -f grafana-dashboard-custom.yaml