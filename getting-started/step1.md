Envoy is configured using a YAML definition file to control the proxy's behaviour. In this step, we're building a configuration using the Static Configuration API. This means that all the settings are pre-defined within the configuration.

Envoy also supports Dynamic Configuration. This allows the settings to be discovered via an external source.

## Resources

The first line of the Envoy configuration defines the API configuration being used. In this case, we're configuring the Static API, so the first line should be *static_resources*. Copy the snippet to the editor.

```
static_resources:
```{{copy}}

## Listeners

The beginning of the configuration defines the _Listeners_. A Listener is the networking configuration, such as IP address and ports, that Envoy listens to for requests. Envoy runs inside of a Docker Container, so it needs to listen on the IP address **0.0.0.0**. In this case, Envoy will listen on port **10000**.

Below is the configuration to define this setup. Copy the snippet to the editor.

```
  listeners:
  - name: listener_0
    address:
      socket_address:
        protocol: TCP
        address: 0.0.0.0
        port_value: 10000
```{{copy}}

## Filter Chains and Filters

With Envoy listening for incoming traffic, the next stage is to define how to process the requests. Each Listener has a set of filters, and different Listeners can have a different set of filters.

In this example, we'll proxy all traffic to Google.com (thanks Google!). The result: We should be able to request the Envoy endpoint and see the Google homepage appear, without the URL changing.

Filtering is defined using *filter_chains*. The aim of each _filter_ is to find a match on the incoming request, to match it to the target destination. Copy the snippet to the editor.

```
    filter_chains:
    - filters:
      - name: envoy.filters.network.http_connection_manager
        typed_config:
          "@type": type.googleapis.com/envoy.extensions.filters.network.http_connection_manager.v3.HttpConnectionManager
          stat_prefix: ingress_http
          route_config:
            name: local_route
            virtual_hosts:
            - name: local_service
              domains: ["*"]
              routes:
              - match:
                  prefix: "/"
                route:
                  host_rewrite_literal: www.google.com
                  cluster: service_google
          http_filters:
          - name: envoy.filters.http.router
            typed_config:
              "@type": type.googleapis.com/envoy.extensions.filters.http.router.v3.Router
```{{copy}}

The filter is using *envoy.http_connection_manager*, a built-in filter designed for HTTP connections. The details are as follows:

- ***stat_prefix:*** The human-readable prefix to use when emitting statistics for the connection manager.

- ***route_config:*** The configuration for the route. If the virtual host matches, then the route is checked. In this example, the *route_config* matches all incoming HTTP requests, no matter the host domain requested.

- ***routes:*** If the URL prefix is matched then a set of route rules defines what should happen next. In this case "/" means match the root of the request

- ***host_rewrite:*** Change the inbound Host header for the HTTP request.

- ***cluster:*** The name of the cluster which will handle the request. The implementation is defined below.

- ***http_filters:*** The filter allows Envoy to adapt and modify the request as it is processed.

## Clusters

When a request matches a filter, the request is passed onto a cluster. The cluster shown below defines that the host is google.com running over HTTPS. If multiple hosts had been defined, then Envoy would perform a Round Robin strategy.

Copy the cluster implementation to complete the configuration:

```
  clusters:
  - name: service_google
    connect_timeout: 30s
    type: LOGICAL_DNS
    # Comment out the following line to test on v6 networks
    dns_lookup_family: V4_ONLY
    lb_policy: ROUND_ROBIN
    load_assignment:
      cluster_name: service_google
      endpoints:
      - lb_endpoints:
        - endpoint:
            address:
              socket_address:
                address: www.google.com
                port_value: 443
    typed_extension_protocol_options:
      envoy.extensions.upstreams.http.v3.HttpProtocolOptions:
        "@type": type.googleapis.com/envoy.extensions.upstreams.http.v3.HttpProtocolOptions
        explicit_http_config:
          http3_protocol_options: {}
        common_http_protocol_options:
          idle_timeout: 1s
    transport_socket:
      name: envoy.transport_sockets.quic
      typed_config:
        "@type": type.googleapis.com/envoy.extensions.transport_sockets.quic.v3.QuicUpstreamTransport
        upstream_tls_context:
          sni: www.google.com
```{{copy}}

## Admin

Finally, an admin section is required. The admin section is explained in more detail in the following steps.

```
admin:
  address:
    socket_address:
      protocol: TCP
      address: 0.0.0.0
      port_value: 9901
```{{copy}}

This structure defines the boilerplate for Envoy Static Configuration. The Listener defines the ports and IP address for Envoy. The listener has a set of filters to match on the incoming requests. Once a request is matched, it will be forwarded to a cluster.

You can view the full configuration on [Github](https://github.com/envoyproxy/envoy/blob/main/configs/google_com_http3_upstream_proxy.yaml).
