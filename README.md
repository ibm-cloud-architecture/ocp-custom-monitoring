# OCP Prometheus + Grafana Custom Setup

This document provides instructions and resources for installing a custom Prometheus and Grafana instance on your OpenShift cluster.

Refer to the appropriate folder for your openshift version. The OCP 3.11 folder uses templates to install a custom Prometheus and Grafana on your cluster, while the OCP 4 folder uses Operators.

If you are just looking to get up and running quickly, run the following:

### For OpenShift 3.11: 

```
./ocp311/setup-monitoring.sh -n prometheus -p kube-system
```


### For OpenShift 4.3
``` 
MacOS Installer: ./ocp4/macos-install.sh
```

``` 
Linux Installer: ./ocp4/linux-install.sh
```
