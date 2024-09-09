The contents of `eds.conf`{{}} is a JSON definition of the same information defined within our static configuration. 

## Task

Create `eds.conf`{{}} file with the following content:

```json
{
  "version_info": "0",
  "resources": [
    {
      "@type": "type.googleapis.com/envoy.config.endpoint.v3.ClusterLoadAssignment",
      "cluster_name": "localservices",
      "endpoints": [
        {
          "lb_endpoints": [
            {
              "endpoint": {
                "address": {
                  "socket_address": {
                    "address": "172.30.1.2",
                    "port_value": 8008
                  }
                }
              }
            }
          ]
        }
      ]
    }
  ]
}
```

This defines a single endpoint at `172.30.1.2:8008`{{}}.