# Cloud Pak Grafana Setup

This script will install a customizable Grafana instance on your OpenShift cluster, link it to prometheus, and install custom charts.

This script has been tested on OCP 4.3

### Prereqs
1. Have OC CLI
2. Be logged in
3. Have cluster admin privileges
4. Use Mac or Linux to run install

### Install Command:
``` 
./install.sh
```

### Add Cloud Pak for Data Dashboard
optional: If your Cloud Pak for Data namespace is not 'zen', run the following:
``` 
sed -i 's/namespace=\\"zen\\"/namespace=\\"your_namespace\\"/g' cpak-dashboards/grafana-dashboard-cp4d.yaml
``` 
Then run this:
``` 
oc apply -f cpak-dashboards/grafana-dashboard-cp4d.yaml
```


