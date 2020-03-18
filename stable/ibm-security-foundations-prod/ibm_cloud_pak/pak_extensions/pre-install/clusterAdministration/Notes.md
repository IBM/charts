The script `createSecurityClusterPrereqs.sh` will perform following operations:
- will allow the Ambassador pod, operators and ISC microservices run as users 8888 and 1001 respectively
- will create image pull secret

Usage is 
```
createSecurityClusterPrereqs.sh <namespace><repository> <repo-username> <repo-password>
```
