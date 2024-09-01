With the *TLS Context* defined, the site will be able to serve traffic over HTTPS. If a user happens to land on the HTTP version of the site, we want them to redirect them to the HTTPS version to ensure they are secure.

## Edit HTTP Filter

Within our HTTP configuration, as part of the filter match for the domain, a flag of ***`https_redirect: true`*** needs to be added to the filter configuration.

Our standard Envoy Proxy configuration looks like below.

```yaml
route_config:
  virtual_hosts:
  - name: backend
  domains:
  - "example.com"
  routes:
  - match:
      prefix: "/"
```

This needs to be extended to include the field HTTPS Redirect.

```yaml
redirect:
                  path_redirect: "/"
                  https_redirect: true
```{{copy}}

When a user visits the HTTP version of the site, Envoy Proxy matches the domain and path based on the filter configuration. This cause the user to be redirected to the HTTPS version of the site.

This can be seen within the completed example at `envoy-completed.yaml`{{open}}.