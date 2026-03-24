# Name

IBM&reg; MQ Agent Add-on

# Introduction

## Summary

The IBM® MQ Agent Add-on is a separate IBM MQ (<https://www.ibm.com/products/mq>) component that provides an AI agent to help you find and solve problems with messages building up in your IBM MQ system.

# Chart Details

This chart deploys the IBM MQ Agent into a Red Hat OpenShift Container Platform cluster.

## Prerequisites

* Red Hat OpenShift Container Platform 4.12 or later
* At least one amd64 Linux worker node
* Helm v3 or Helm v4
* watsonx.ai credentials (project ID and API key)
* The IBM Licensing Operator needs to be installed separately; see <https://www.ibm.com/docs/en/cloud-paks/cp-integration/latest?topic=administration-deploying-license-service>
* IBM MQ connection configuration:
  * CCDT (Client Channel Definition Table) ConfigMap
  * MCP server configuration Secret (.ini file) for authentication settings and other advanced configuration
  * PKCS#12 keystore Secret for TLS connection to queue managers (if required)

## Limitations

* Platform Support: Red Hat OpenShift Container Platform 4.12 or later only
* Architecture: amd64 (x86_64) only
* watsonx.ai Dependency: Requires active watsonx.ai instance (for example in US South region) with valid credentials
