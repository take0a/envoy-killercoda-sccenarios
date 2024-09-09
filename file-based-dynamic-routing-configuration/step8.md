With the configuration based on CDS, LDS and EDS, we can dynamically add a new cluster.

Open the file `cds.conf`{{}}.

## Add new cluster

We'll call this new cluster `newTargetCluster`. Replace the configuration with the following to add a new cluster.

```json
{
  "version_info": "0",
  "resources": [
    {
      "@type": "type.googleapis.com/envoy.config.cluster.v3.Cluster",
      "name": "targetCluster",
      "connect_timeout": "0.25s",
      "lb_policy": "ROUND_ROBIN",
      "type": "EDS",
      "eds_cluster_config": {
        "service_name": "localservices",
        "eds_config": {
          "path": "/etc/envoy/eds.conf"
        }
      }
    },
    {
      "@type": "type.googleapis.com/envoy.config.cluster.v3.Cluster",
      "name": "newTargetCluster",
			"connect_timeout": "0.25s",
			"lb_policy": "ROUND_ROBIN",
			"type": "EDS",
			"eds_cluster_config": {
				"service_name": "localservices",
				"eds_config": {
					"path": "/etc/envoy/eds1.conf"
				}
			}
    }
  ]
}
```

You also need to create the `eds_cluster_config` file for this new cluster.
Create the file `eds1.conf` with this content:

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
                    "port_value": 8009
                  }
                }
              }
            },
            {
              "endpoint": {
                "address": {
                  "socket_address": {
                    "address": "172.30.1.2",
                    "port_value": 8010
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
```{{copy}}

And you can use this new cluster, in the listener that you previously configured. Open the file `lds.conf`{{}}.
Replace the target cluster with the name of the new cluster `newTargetCluster`.

```json
  "route": {
      "cluster": "newTargetCluster"
  }
```{{copy}}

The configuration of `lds.conf` should look like:

```json
...
      "filter_chains": [
        {
          "filters": [
            {
              "name": "envoy.filters.network.http_connection_manager",
              "typed_config": {
                "@type": "type.googleapis.com/envoy.extensions.filters.network.http_connection_manager.v3.HttpConnectionManager",
                "stat_prefix": "ingress_http",
                "codec_type": "AUTO",
                "route_config": {
                  "name": "local_route",
                  "virtual_hosts": [
                    {
                      "name": "local_service",
                      "domains": [
                        "*"
                      ],
                      "routes": [
                        {
                          "match": {
                            "prefix": "/"
                          },
                          "route": {
                            "cluster": "newTargetCluster"
                          }
                        }
                      ]
                    }
                  ]
                },
                "http_filters": [
                  {
                    "name": "envoy.filters.http.router",
                    "typed_config": {
                      "@type": "type.googleapis.com/envoy.extensions.filters.http.router.v3.Router"
                    }
                  }
                ]
              }
            }
          ]
        }
      ]
...
```

Start two HTTP servers to handle the incoming requests for the new cluster
`docker run -d -p 8009:80 nginx:alpine; docker run -d -p 8010:80 nginx:alpine;`{{exec}}

Based on how Docker handles file inode tracking, sometimes the filesystem change isn't triggered and detected.
Force the change with the command: `mv cds.conf tmp; mv tmp cds.conf; mv lds.conf tmp; mv tmp lds.conf`{{exec}}

Envoy should automatically reload the configuration and add the new cluster. You can try running the following command:
`curl localhost:81`{{exec}}.

You can notice with the response of each request, that the ID of the nodes changes, corresponding to the nodes of `newTargetCluster`{{}}.