#################################################################
# Licensed Materials - Property of IBM
# (C) Copyright IBM Corp. 2020. All Rights Reserved.
#
# US Government Users Restricted Rights - Use, duplication or
# disclosure restricted by GSA ADP Schedule Contract with
# IBM Corp.
################################################################# 

echo '---' > insightsMigrationSecrets.yaml
oc get secret -o yaml data-encryption-password >> insightsMigrationSecrets.yaml
echo '---' >> insightsMigrationSecrets.yaml
oc get secret -o yaml insights-api-password  >> insightsMigrationSecrets.yaml
echo '---' >> insightsMigrationSecrets.yaml
oc get secret -o yaml insights-gcm-aad >> insightsMigrationSecrets.yaml
echo '---' >> insightsMigrationSecrets.yaml
oc get secret -o yaml insights-mongodb >> insightsMigrationSecrets.yaml
echo '---' >> insightsMigrationSecrets.yaml
oc get secret -o yaml insights-tenant-user-secret >> insightsMigrationSecrets.yaml
echo Migration secrets stored in insightsMigrationSecrets.yaml