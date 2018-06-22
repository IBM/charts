#dep-couchdb

This chart is intended for use as a dependency of the parent chart ibm-cem, a cloud based event management solution which can be deployed on ICp. It is not currently recommended to use this chart to install couchdb in a standalone fashion, though it may be adapted for that purpose in the future.

There is no values.yaml in this chart, it pulls from the parent chart's values.yaml dep-couchdb property.