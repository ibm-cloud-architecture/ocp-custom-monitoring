#!/bin/bash

  oc get secret prometheus-k8s-htpasswd -n openshift-monitoring -o jsonpath='{.data.auth}{"\n"}' | base64 -D > /tmp/htpasswd-tmp
  oldpass=$(cat /tmp/htpasswd-tmp)
  addpass='grafana-test:{SHA}EiAf5eICiDvUX8l+hzZuoFGD4OQ='
  newpass="${oldpass}\n${addpass}"
  newpass_enc=$(echo -e $newpass | base64)
  oc patch secret prometheus-k8s-htpasswd -n openshift-monitoring -p "{\"data\":{\"auth\":\"$newpass_enc\"}}"
