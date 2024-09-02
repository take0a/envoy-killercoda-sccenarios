Within NGINX, the upstream configuration defines the set of target servers that will handle the traffic. In this case, two clusters have been assigned.

```
  upstream targetCluster {
    172.18.0.3:80;
    172.18.0.4:80;
  }

```

Within Envoy, this is managed by clusters.

## Envoy Clusters

The equivalent of upstream is defined as Clusters. In this case, the hosts that will serve the traffic have been defined. The way the hosts are accessed, such as the timeouts, are defined as the cluster configuration. This allows finer grain control over aspects such as timeouts and load balancing.

```yaml
  clusters:
  - name: targetCluster
    connect_timeout: 0.25s
    type: STRICT_DNS
    dns_lookup_family: V4_ONLY
    lb_policy: ROUND_ROBIN
    load_assignment:
      cluster_name: targetCluster
      endpoints:
      - lb_endpoints:
        - endpoint:
            address:
              socket_address:
                address: 172.30.1.2
                port_value: 8008
        - endpoint:
            address:
              socket_address:
                address: 172.30.1.2
                port_value: 8009
```{{copy}}

When using *STRICT_DNS* service discovery, Envoy will continuously and asynchronously resolve the specified DNS targets. Each returned IP address in the DNS result will be considered an explicit host in the upstream cluster. This means that if the query returns two IP addresses, Envoy will assume the cluster has two hosts, and both should be load balanced to. If a host is removed from the result, Envoy assumes it no longer exists and will drain traffic from any existing connection pools.

For further information, refer to [Envoy Proxy documentation](https://www.envoyproxy.io/docs/envoy/latest/intro/arch_overview/upstream/service_discovery#strict-dns).