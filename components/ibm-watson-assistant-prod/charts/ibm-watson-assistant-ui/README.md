# Helm Deploy Scripts for Watson Assistant Tooling for ICP

## Sequence of Deployment
This helm chart MUST be deployed AFTER both the deployment of store and the deployment of the resource controller, authentication backend, and provision service (all three of which are in icp-wa-ingress-example helm chart).

## To Do
Before this script is applied, a TLS secret must be made on the same namespace as where this will be deploy. The TLS/SSL certification secret needs to contain CN and O entries with the subdomain of tooling as its value.

The terminal commands to create the Kubernetes TLS secrets are:
```
openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout wa.key -out wa.cert -subj "/CN=${subdomain}/O=${subdomain}"

kubectl create secret tls ${CERT_NAME} --key wa.key --cert wa.cert
```

Replace `${subdomain}` with the complete subdomain name, such as `watson-assistant-tooling-1.assistui.icp.ibmcsf.net`.

The `${CERT_NAME}` must match the `tls.cert` variables defined in the kingdom configs or `values.yaml`.
