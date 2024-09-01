The EDS configuration is defined to allow the upstream clusters to be controlled dynamically. 

Within the static configuration, this was defined as:

```yaml
  clusters:
  - name: targetCluster
    connect_timeout: 0.25s
    type: STRICT_DNS
    dns_lookup_family: V4_ONLY
    lb_policy: ROUND_ROBIN
    hosts: [
      { socket_address: { address: 172.18.0.3, port_value: 80 }},
      { socket_address: { address: 172.18.0.4, port_value: 80 }}
    ]
```{{copy}}

## Convert to EDS

To convert this to EDS based a **eds_cluster_config** is required and changing the type to **EDS**.

Add the following cluster to the end of the Envoy configuration.

```yaml
  clusters:
  - name: targetCluster
    connect_timeout: 0.25s
    lb_policy: ROUND_ROBIN
    type: EDS
    eds_cluster_config:
      service_name: localservices
      eds_config:
        path: '/etc/envoy/eds.conf'

```{{copy}}

The values for the upstream servers, such as `172.18.0.3` and `172.18.0.4`, will come from the file `eds.conf`{{open}}.