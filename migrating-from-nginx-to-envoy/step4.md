When a request comes into NGINX, a location block defines how to process and where to forward the traffic. In the following snippet, all the traffic to the site is proxied to an upstream cluster called _`targetCluster`_. The upstream cluster defines the nodes that should process the request. We will discuss this in the next step.

```
location / {
    proxy_pass         http://targetCluster/;
    proxy_redirect     off;

    proxy_set_header   Host             $host;
    proxy_set_header   X-Real-IP        $remote_addr;
}
```

Within Envoy, this is managed by Filters.

## Envoy Filters

For the static configuration, the filters define how to handle incoming requests. In this case, we are setting the filters that match the *server_names* in the previous step. When incoming requests are received that match the defined domains and routes, the traffic is forwarded to the cluster. This is the equivalent of the upstream NGINX configuration.

```yaml
    filter_chains:
    - filters:
      - name: envoy.filters.network.http_connection_manager
        typed_config:
          "@type": type.googleapis.com/envoy.extensions.filters.network.http_connection_manager.v3.HttpConnectionManager
          codec_type: auto
          stat_prefix: ingress_http
          route_config:
            name: local_route
            virtual_hosts:
            - name: backend
              domains:
                - "one.example.com"
                - "www.one.example.com"
              routes:
              - match:
                  prefix: "/"
                route:
                  cluster: targetCluster
          http_filters:
            - name: envoy.filters.http.router
              typed_config:
                "@type": type.googleapis.com/envoy.extensions.filters.http.router.v3.Router
```{{copy}}

The name *envoy.http_connection_manager* is a built-in filter within Envoy Proxy. Other filters include _Redis_, _Mongo_, _TCP_. You can find the complete list in the [documentation](https://www.envoyproxy.io/docs/envoy/latest/api-v3/config/listener/v3/listener.proto#config-listener-v3-listener).

For more information about other load balancing policies visit the [Envoy documentation](https://www.envoyproxy.io/docs/envoy/v1.8.0/intro/arch_overview/load_balancing).