You can see the statistics generated in plan text in this [URL]({{TRAFFIC_HOST1_9901}}/stats/prometheus).

And you can use one particular field to build a graph, for example:
`envoy_cluster_external_upstream_rq`

![](/envoyproxy-scenarios/scenario/implementing-metrics-tracing/assets/envoy_cluster_external_upstream_rq.png)

To build the graph, go to the [dashboard]({{TRAFFIC_HOST1_9090}}/graph).

And use this query:
```
envoy_cluster_external_upstream_rq{envoy_cluster_name="targetCluster"}
```{{copy}}
