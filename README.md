# Prometheus for OpenShift

This directory contains example components for running either an operational Prometheus setup for your OpenShift cluster, or deploying a standalone secured Prometheus instance for configurating yourself.

## Prometheus for Operations

The `prometheus.yaml` template creates a Prometheus instance preconfigured to gather OpenShift and Kubernetes platform and node metrics and report them to admins. It is protected by an OAuth proxy that only allows access for users who have view access to the `kube-system` namespace.

To deploy, run:

```
$ oc new-app -f prometheus.yaml
```

You may customize where the images (built from `openshift/prometheus` and `openshift/oauth-proxy`) are pulled from via template parameters.

## Useful metrics queries

### Related to how much data is being gathered by Prometheus

> sort_desc( count by (__name__)({__name__=~".+"}))

Number of metrics series per metric (a series is a unique combination of labels for a given metric).

> scrape_samples_scraped

Number of samples (individual metric values) exposed by each endpoint at the time it was scraped.

### System and container CPU

> sum(machine_cpu_cores)

Total number of cores in the cluster.

> sum(sort_desc(rate(container_cpu_usage_seconds_total{id="/"}[5m])))

Total number of consumed cores.

> sort_desc(sum by (kubernetes_io_hostname,type) (rate(container_cpu_usage_seconds_total{id="/"}[5m])))

CPU consumed per node in the cluster.

> sort_desc(sum by (cpu,id,pod_name,container_name) (rate(container_cpu_usage_seconds_total{type="infra"}[5m])))

CPU consumption per system service or container on the infrastructure nodes.

> sort_desc(sum by (namespace) (rate(container_cpu_usage_seconds_total[5m])))

CPU consumed per namespace on the cluster.

> drop_common_labels(sort_desc(sum without (cpu) (rate(container_cpu_usage_seconds_total{container_name="prometheus"}[5m]))))

CPU per instance of Prometheus container.

> sum(rate(container_cpu_usage_seconds_total{id="/"}[3m])) / sum(machine_cpu_cores)

Percentage of total cluster CPU in use

> sum(container_memory_rss) / sum(machine_memory_bytes)

Percentage of total cluster memory in use

> sum by (kubernetes_io_hostname) (rate(container_cpu_usage_seconds_total{type="master",id=~"/system.slice/(docker\|etcd).service"}[10m]))

Aggregate CPU usage of several systemd units

### Changes in your cluster

> sum(changes(container_start_time_seconds[10m]))

The number of containers that start or restart over the last ten minutes.


### API related queries

> sort_desc(drop_common_labels(sum without (instance,type,code) (rate(apiserver_request_count{verb=~"POST|PUT|DELETE|PATCH"}[5m]))))

Number of mutating API requests being made to the control plane.

> sort_desc(drop_common_labels(sum without (instance,type,code) (rate(apiserver_request_count{verb=~"GET|LIST|WATCH"}[5m]))))

Number of non-mutating API requests being made to the control plane.

### Network Usage

> topk(10, (sum by (pod_name) (rate(container_network_receive_bytes_total[5m]))))

Top 10 pods doing the most receive network traffic

### etcd related queries

> etcd_disk_wal_fsync_duration_seconds_count{type="master"}

etcd "write-ahead-log" latency in milliseconds.  If this goes over 100ms, the cluster might destabilize.  Over 1000ms and things definitely start falling apart.

### Kubelet / docker related queries

> kubelet_docker_operations_latency_microseconds{type="compute",quantile="0.9"}

90th percentile latency for docker operations (in microseconds).  This number will include image pulls, so often will be hundreds of seconds.

> kubelet_docker_operations_timeout

Returns a running count (not a rate) of docker operations that have timed out since the kubelet was started.

> kubelet_docker_operations_errors

Returns a running count (not a rate) of docker operations that have failed since the kubelet was started.

> kubelet_pleg_relist_latency_microseconds

Returns PLEG (pod lifecycle event generator) latency metrics.  This represents the latency experienced by calls from the kubelet to the container runtime (i.e. docker or CRI-O).  High PLEG latency is often related to disk I/O performance on the docker storage partition.

### OpenShift build related queries

> count(openshift_build_active_time_seconds{phase="New",strategy!="JenkinsPipeline",reason!="InvalidOutputReference",reason!="InvalidImageReference",reason!="CannotRetrieveServiceAccount"} < time() - 600)

Returns the number of builds which have not yet started after 10 minutes.  This query filters out
builds where the fact they have not started could be cited as resulting from user error.  Namely:

* Image references in the BuildConfig are incorrect (pointing to non-existent Images or ImageStreams for example)
* ServiceAccount references are incorrect (again, pointing to a ServiceAccount which cannot be retrieved by the user submitting the build request)
* Pipeline strategy builds can often be hung up by conditions in the Jenkins server the user has created which the Build subsystem cannot account for

NOTE:  OpenShift Online monitors builds in a fashion similar to this today.

> sum(openshift_build_total{job="kubernetes-apiservers",phase="Error"})/(sum(openshift_build_total{job="kubernetes-apiservers",phase=~"Complete|Error"})) * 100

Calculates the error rate for builds, where the error might indicate issues with the cluster or namespace.  Note, it ignores builds in the "Failed" and "Cancelled" phases, as builds typically end up in
one of those phases as the result of a user choice or error.  Administrators after some experience with their cluster could decide what is an acceptable error rate and monitor when it is exceeded.

> ((sum(openshift_build_total{job="kubernetes-apiservers",phase="Complete"})-
> sum(openshift_build_total{job="kubernetes-apiservers",phase="Complete"} offset 1h))  / 
> (sum(openshift_build_total{job="kubernetes-apiservers",phase=\~"Failed|Complete|Error"}) - 
> (sum(openshift_build_total{job="kubernetes-apiservers",phase=\~"Failed|Complete|Error"} offset 1h)))) * 100

Calculates the percentage of builds that were successful in the last hour.  Note that this value is only accurate if no pruning of builds
is performed, otherwise it is impossible to determine how many builds ran (successfully or otherwise) in the last hour.

> predict_linear(openshift_build_total{phase="Error"}[1h],3600)

Predicts what the error count will be in 1 hour, using last hours data.

> predict_linear(openshift_build_total{phase="Error"}[1h],3600) / (predict_linear(openshift_build_total{phase="Error"}[1h],3600) + predict_linear(openshift_build_total{phase="Completed"}[1h],3600)) * 100

Similar to the two queries above, this query will predict what the error rate will be in one hour based on last hours data.

> count(openshift_build_active_time_seconds{phase="Running"} < time() - 600)

Returns the number of builds that have been running for more than 10 minutes (600 seconds).

> count(openshift_build_active_time_seconds{phase="Pending"} < time() - 600)

Returns the number of build that have been waiting at least 10 minutes (600 seconds) to start.

> sum(openshift_build_total{phase="Failed"})

Returns the number of failed builds, regardless of the failure reason.

> openshift_build_total{phase="failed",reason="FetchSourceFailed"}

Returns the number of failed builds because of problems retrieving source from the associated Git repository.

> sum(openshift_build_total{phase="Complete"})

Returns the number of successfully completed builds.

> openshift_build_total{phase="Failed"} offset 5m

Returns the failed builds totals, per failure reason, from 5 minutes ago.

# Openshift Grafana Dashboards

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

#### Manual deployment for oauth proxy:
Note: when using oauth make sure your user has permission to browse grafana.
- add a openshift user htpasswd ```htpasswd -c /etc/origin/master/htpasswd gfadmin```
- use the HTPasswdPasswordIdentityProvider as described here - https://docs.openshift.com/enterprise/3.0/admin_guide/configuring_authentication.html 
- make sure point the provider file to /etc/origin/master/htpasswd.
  or using this example cmd:
  ```
  sed -ie 's|AllowAllPasswordIdentityProvider|HTPasswdPasswordIdentityProvider\n      file: /etc/origin/master/htpasswd|' /etc/origin/master/master-config.yaml
  ```
- add view role to user ```oc adm policy add-cluster-role-to-user cluster-reader gfadmin```
- restart master api ```systemctl restart atomic-openshift-master-api.service```
- get the grafana url by ```oc get route```
- discover your openshift dashboard.

#### Pull standalone docker grafana instance
to build standalone docker instance see
https://github.com/mrsiano/grafana-ocp

#### Resources 
- example video https://youtu.be/srCApR_J3Os
- deploy openshift prometheus https://github.com/openshift/origin/tree/master/examples/prometheus 
