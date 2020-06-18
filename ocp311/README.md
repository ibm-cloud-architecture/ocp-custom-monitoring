# Grafana Installer

For a quick setup of a customizable Grafana, run the following:
```
./install.sh
```

# Cloud Pak Dashboard

To add a Cloud Pak Dashboard to your new Grafana instance, use cloud-pak-monitoring.json. You can either upload it or paste the contents directly into the Grafana Import tab.

# OCP Prometheus + Grafana Installer

This document provides instructions and resources for installing a custom Prometheus and Grafana instance on your OpenShift cluster using Templates (not Operators).

This method has been tested on OpenShift 3.11

###The following configuration will deploy a custom Prometheus and Grafana to separate namespaces in your cluster. Run the deployment script:
```
./setup-monitoring.sh -n prometheus -p kube-system
```


# 1. Deploy Prometheus

This directory contains example components for running either an operational Prometheus setup for your OpenShift cluster, or deploying a standalone secured Prometheus instance for configurating yourself.

## Prometheus for Operations

The `prometheus.yaml` template creates a Prometheus instance preconfigured to gather OpenShift and Kubernetes platform and node metrics and report them to admins. It is protected by an OAuth proxy that only allows access for users who have view access to the `kube-system` namespace.

To deploy, run:

```
$ oc new-app -f prometheus.yaml
```

You may customize where the images (built from `openshift/prometheus` and `openshift/oauth-proxy`) are pulled from via template parameters.

# 2. Deploy Grafana

This example creates a custom Grafana instance preconfigured to gather Prometheus openshift metrics.
It uses "OAuth" token to login openshift Prometheus.

## Available Dashboards
- openshift cluster metrics
- node exporter metrics

## To run grafana and deploy dashboards
Note: make sure to have openshift prometheus deployed (possibly, with node exporter).
(https://github.com/openshift/origin/tree/master/examples/prometheus)

### Run the deployment script
``` 
./setup-grafana.sh -n <any_datasorce_name> -a -e
```
for more info ```./setup-grafana.sh -h```

