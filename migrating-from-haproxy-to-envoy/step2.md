Within the HTTP configuration block, the HA Proxy configuration listens on port 8080 and all traffic is handled by the backend nodes.

```
frontend localnodes
    bind *:8080
    mode http
    default_backend nodes
```

Within Envoy Proxy, this concept is handled by Listeners.

## Envoy Listeners

The Envoy binding of configuration is defined as Listeners. Each listener can define a port and a series of filters, routes and clusters that respond on that port. In this case, there is one listener defined bound to port 8080.

Envoy Proxy uses YAML notation for its configuration. If you are not familiarized with this notation can see this [link](https://yaml.org/spec/1.2/spec.html).

```yaml
static_resources:
  listeners:
  - name: listener_0
    address:
      socket_address: { address: 0.0.0.0, port_value: 8080 }
```{{copy}}

In the next step, you'll find the configuration of routes and cluster that will handle the traffic.