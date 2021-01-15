# What's new in Helm Charts Version 2.0.1 for IBM Sterling File Gateway Enterprise Edition v6.1.0.1
* Support for configuring topology spread constraints for application pods
* Support for configuring tolerations for application pods
* Support for configuring additional annotations and loadBalancer IP for services
* Support for configuring truststore and keystore certificates using Kubernetes secrets for Database, IBM MQ and Liberty SSL connections. Additional certificates and configuration maps can also be mapped now to application pods using extra secrets and configmaps configurations.
* Security fixes


# Breaking Changes
Rolling upgrades for product version v6.1.0.0 will be supported but for product versions earlier than v6.1.0.0 installed using IIM, Docker or Certified Container will not be supported.

# Documentation
Check the README file provided with the chart for detailed installation instructions.

# Fixes
N/A

# Prerequisites
Please refer prerequisites section from README.md

# Version History

| Chart | Date | Kubernetes Version Required | Breaking Changes | Details |
| ----- | ---- | --------------------------- | ---------------- | ------- |
| 2.0.1   | December 18, 2020 | >=1.14.6 | N  | Fix pack release upgrade for IBM Sterling File Gateway Certified Containers | 
