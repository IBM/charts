## In RHOS, create the following routes to get to the application

### Variable release_name has to be set to the release in which the chart is deployed


```
oc create route passthrough --service="${release_name}-common-ui-nginx" --port=3000
oc create route passthrough --service="${release_name}-rms-streams" --port=8443
oc create route passthrough --service="${release_name}-elasticsearch" --port=9200
oc create route passthrough --service="${release_name}-logging-kb" --port=5601
oc create route passthrough --service="${release_name}-logging-ls" --port=5044
```
