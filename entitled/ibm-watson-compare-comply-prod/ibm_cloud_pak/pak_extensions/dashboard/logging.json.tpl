[
  {
    "_id": "@@RELEASE_NAME@@-ibm-watson-compare-comply-prod",
    "_type": "search",
    "_source": {
      "title": "Watson Compare and Comply - @@RELEASE_NAME@@",
      "description": "",
      "hits": 0,
      "columns": [
        "message",
        "kubernetes.pod",
        "model",
        "params",
        "statusCode"
      ],
      "sort": [
        "@timestamp",
        "desc"
      ],
      "version": 1,
      "kibanaSavedObjectMeta": {
        "searchSourceJSON": "{\"index\":\"logstash-*\",\"highlightAll\":true,\"version\":true,\"query\":{\"query_string\":{\"query\":\"*\",\"analyze_wildcard\":true}},\"filter\":[{\"$state\":{\"store\":\"appState\"},\"meta\":{\"alias\":null,\"disabled\":false,\"index\":\"logstash-*\",\"key\":\"kubernetes.container_name\",\"negate\":false,\"type\":\"phrase\",\"value\":\"ibm-watson-compare-comply-prod\"},\"query\":{\"match\":{\"kubernetes.container_name\":{\"query\":\"ibm-watson-compare-comply-prod\",\"type\":\"phrase\"}}}},{\"meta\":{\"index\":\"logstash-*\",\"negate\":false,\"disabled\":false,\"alias\":null,\"type\":\"phrase\",\"key\":\"kubernetes.pod\",\"value\":\"@@RELEASE_NAME@@-ibm-watson-compare-comply-prod*\"},\"query\":{\"match\":{\"kubernetes.pod\":{\"query\":\"@@RELEASE_NAME@@-ibm-watson-compare-comply-prod*\",\"type\":\"phrase\"}}},\"$state\":{\"store\":\"appState\"}},{\"meta\":{\"negate\":false,\"index\":\"logstash-*\",\"type\":\"phrase\",\"key\":\"kubernetes.namespace\",\"value\":\"@@NAMESPACE@@\",\"disabled\":false,\"alias\":null},\"query\":{\"match\":{\"kubernetes.namespace\":{\"query\":\"@@NAMESPACE@@\",\"type\":\"phrase\"}}},\"$state\":{\"store\":\"appState\"}}]}"
      }
    }
  }
]
