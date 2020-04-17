#!/bin/bash

oc new-project cloudpak-monitoring


oc apply -f cpak-monitoring-og.yaml

oc apply -f cpak-grafana-sub.yaml 

oc apply -f cloudpak-grafana.yaml


oc get statefulset prometheus-k8s -o yaml -n openshift-monitoring > temp-prom.yaml
sed -i '.bak' 's/--web.listen-address=127.0.0.1:9090/--web.listen-address=:9090/g' temp-prom.yaml
oc apply -f temp-prom.yaml

rm temp-prom.yaml
rm temp-prom.yaml.bak 

oc apply -f prometheus-datasource.yaml 


