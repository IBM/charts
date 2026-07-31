# IBM Z Upgrade agent

## Overview
The IBM Z Upgrade agent enables system programmers to perform z/OS upgrades through the Watsonx Assistant for Z chat interface. It provides precise responses by leveraging z/OSMF APIs and client-specific documentation stored in ZRAG.

**Deployment Architecture**: The agent uses the Model Context Protocol (MCP) architecture with separate client and server components for improved scalability and maintainability.

## Agent capabilities

| Agent capability         |            Description                  |
|------------------------------|-----------------------------------|
| Lists software products        | Provides a comprehensive list of software products for a given system    |
Lists software instance details | Shows detailed metadata of a given software instance such as its Name, Description, Global Zone, Target Zone, and so on.
Retrieves missing FIXCATs by software instance | Identifies missing FIXCAT Updates for specific software instances and systems.
Retrieves missing FIXCATs by software product | Identifies missing FIXCAT updates for software instances associated with the specified products and systems.
Retrieves missing CRITICAL updates by software instance | Identifies missing  CRITICAL Updates such as HIPERs and PEs for specific software instances and systems.
Acquires missing FIXCAT and CRITICAL updates | Retrieves the required PTFs for the specified RESOLVERS or FIXCAT names.
Monitors PTF acquisition job status| Tracks the progress and current status of background jobs initiated to acquire PTFs.
Installs the acquired PTFs | Begins the installation or update process for the requested PTFs.
Retrieves the installation or update status | Retrieves the status of installation or update processes using either the process ID or the names of the software instance and system.
Displays HOLD data | Shows HOLD data related to any unresolved HOLDS.
Resumes installation or update process | Continues the installation or update process if the user agrees to resolve all unresolved HOLDS.
Cancels the installation or update process | Cancels the installation or update process only upon user request.
Copies installation output | Copies the installation or update output, along with the process ID, to the user-specified UNIX path (e.g., /AQFT/tmp/smpe/).
Check hardware-compatibility for upgrade | Performs a check if the given system's hardware is compatible for an upgrade to a specified version
Retrieve Content from agent documentation stored in ZRAG |  Answers the upgrade workflow-related queries using the ingested docs for the agent.


## Prerequisites
Ensure the following:

- [watsonx Assistant for Z]( https://www.ibm.com/docs/watsonx/waz/3.0.0?topic=install-premises-watsonx-orchestrate-watsonx-assistant-z) is installed
- The minimum version of z/OSMF is 3.1

## Deployment Guide

The IBM Z Upgrade Agent is deployed using a Custom Resource (CR) definition. The CR provides a declarative way to manage the agent deployment through the agent operator.

**Note**: The Upgrade Agent uses MCP (Model Context Protocol) architecture with separate client and server deployments for improved scalability and maintainability.

### Prerequisites

Before deploying the agent, ensure:

1. The agent operator is installed and running in your cluster
2. The target namespace exists
3. z/OSMF version 3.1 or higher is available

### Step 1: Create Secrets

The agent requires Kubernetes Secrets containing sensitive configuration values. **Never commit secrets to version control.**

#### Secret Types

The agent uses two types of secrets:

1. **Global Secrets** (`wxa4z-watsonx-credentials`): Shared across all agents
2. **Agent-Specific Secrets** (`wxa4z-upgrade-agent-secrets`): Unique to this agent

#### Agent-Specific Secret Reference

Create a secret with the following structure. **All values must be base64-encoded.**

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: wxa4z-upgrade-agent-secrets
  namespace: ""  # REQUIRED: Must match the agent namespace
type: Opaque
data:
  # Agent Authentication (base64-encoded, REQUIRED)
  AGENT_AUTH_TOKEN: ""  # REQUIRED: Agent auth token for registration with WxO
```

> **Important:**
> - **AGENT_AUTH_TOKEN is required** for agent registration with watsonx Orchestrate.

#### Creating the Secret

1. Save the secret configuration to a file (e.g., `upgrade-agent-secret.yaml`)
2. Update the namespace and base64-encode all secret values
3. Apply the secret:

```bash
oc apply -f upgrade-agent-secret.yaml
```

4. Verify the secret was created:

```bash
oc get secret wxa4z-upgrade-agent-secrets -n <namespace>
```

### Step 2: Deploy Agent using Custom Resource (CR)

#### Configuration Parameters

The following table outlines the key configuration parameters:

| Parameter | Description | Required |
|-----------|-------------|----------|
| **metadata.namespace** | Target namespace for agent deployment | Yes |
| **spec.tenantId** | Tenant identifier for multi-tenancy support | Yes |
| **spec.chart.version** | Helm chart version to deploy | Yes |
| **spec.values.env.WATSONX_MODEL_ID** | LLM Model ID (e.g., "meta-llama/llama-3-3-70b-instruct") | Yes |
| **spec.values.env.MODEL_RUNTIME** | MODEL RUNTIME (e.g., "openai_protocol") | Yes |
| **spec.values.secrets.name** | Name of agent-specific secrets | Yes |
| **spec.values.global.secrets.name** | Name of global shared secrets | Yes |
| **spec.values.env.HOST_NAME** | Cluster endpoint where the image is deployed | Yes |
| **spec.values.env.AUTHZ_SERVICE_URL** | URL for AuthZ service | Yes |

#### Additional Configuration Parameters

The following environment variables can be configured for ZRAG queries:

| Parameter | Description |
|-----------|-------------|
| **WRAPPER_URL** | Endpoint for OpenSearch |
| **INGESTION_URL** | URL for document ingestion service |

#### CR Definition

Below is the complete Custom Resource definition. Update the placeholder values according to your environment:

```yaml
apiVersion: wxa4z.watsonx.ibm.com/v1alpha1
kind: AgentService
metadata:
  name: upgrade-agent
  namespace: ""  # REQUIRED: Target namespace (e.g., wxa4z-agents)
  labels:
    wxa4z.watsonx.ibm.com/managed-by: agent-operator
spec:
  releaseName: upgrade-agent
  namespace: ""  # REQUIRED: Must match metadata.namespace
  tenantId: ""  # REQUIRED: Tenant identifier for multi-tenancy support
  wxa4z-core-services-namespace: wxa4z-zad  # Namespace where wxa4z core services are deployed
  
  agentDetails:
    - agentName: upgrade-agent
      agentId: wxa4z:upgrade-agent:agent
      description: 'Enables system programmers to perform z/OS upgrades through chat interface'
      bootstrapConfig:
        name: "upgrade-agent-bootstrap-config"
        fileName: "upgrade_agent_bootstrap_config.yaml"
  
  chart:
    repository: oci://icr.io/wxa4z-dev-container-registry
    name: upgrade-agent
    version: "1.2.1"  # Update to the desired chart version
    # Uncomment if using a private registry:
    # pullSecrets:
    #   - name: wxa4z-image-pull-secret

  values:
    replicaCount: 1
    
    global:
      secrets:
        name: wxa4z-watsonx-credentials  # Global secrets shared across agents
    
    secrets:
      name: wxa4z-upgrade-agent-secrets  # Agent-specific secrets
    
    env:
      # LLM Configuration
      WATSONX_MODEL_ID: "meta-llama/llama-3-3-70b-instruct"
      MODEL_RUNTIME: "openai_protocol"
      
      # Cluster Configuration
      HOST_NAME: ""  # REQUIRED: Cluster endpoint
      
      # Add additional PTF job configuration as needed
```

#### Installing the Agent

1. Save the CR configuration to a file (e.g., `upgrade-agent-cr.yaml`)
2. Update all placeholder values marked as `REQUIRED`
3. Apply the CR to your cluster:

```bash
oc apply -f upgrade-agent-cr.yaml
```

4. Verify the deployment:

```bash
# Check CR status
oc get agentservice upgrade-agent -n <namespace>

# Check MCP client pods
oc get pods -n <namespace> -l app=upgrade-agent-mcp-client

# Check MCP server pods
oc get pods -n <namespace> -l app=upgrade-agent-mcp-server

# View MCP client logs
oc logs -n <namespace> -l app=upgrade-agent-mcp-client --tail=100

# View MCP server logs
oc logs -n <namespace> -l app=upgrade-agent-mcp-server --tail=100
```

### Step 3: Subscribe to the agent

After successfully deploying the agent, you need to subscribe to it to make it available in watsonx Orchestrate.

1. Open the Cloud Pak for Data (CPD) home page.
   - Example: `https://cpd-<instance>.apps.<cluster-domain>/zen/?context=icp4data#/homepage`

2. Click on the **Launch WXA4Z console** tab.
   - This opens the WXA4Z Content Ingestion UI (Tenant Overview page).
   - Example: `https://wxa4z-content-ingestion-ui-route-wxa4z-zad.apps.<cluster-domain>/en`

3. On the Tenant Overview page, click on your **Tenant name**.

4. Navigate to the **Subscriptions** tab.
   - You will see a list of deployed agents with a **Subscribe** button next to each.

5. Click the **Subscribe** button next to the **IBM Z Upgrade Agent**.
   - This action adds the agent to watsonx Orchestrate (WXO) and makes it available for deployment.


### Step 4: Deploy the agent

1. Log in to watsonx Orchestrate.
2. From the main menu, navigate to **Build** > **Agent Builder**.
3. Select the **IBM Z Upgrade Agent** tile.
4. In the AI Assistant window, enter a query to confirm that the response aligns with your expectations.
5. Click **Deploy** to activate the agent and make it available in the live environment.


### Step 5: Upgrade the Agent

To upgrade the agent to a new version:

> **Note:** If the agent was previously subscribed to watsonx Orchestrate, you must first unsubscribe it before upgrading. After the upgrade is complete, re-subscribe the agent. See the [Uninstall the Agent](#step-6-uninstall-the-agent) section for unsubscribe steps and the [Subscribe to the agent](#step-3-subscribe-to-the-agent) section for subscribe steps.

1. Update the `spec.chart.version` field in your CR file:

```yaml
spec:
  chart:
    version: "1.2.2"  # Update to the new version
```

2. Apply the updated CR:

```bash
oc apply -f upgrade-agent-cr.yaml
```

3. Monitor the upgrade progress:

```bash
# Watch the MCP client pods rolling update
oc get pods -n <namespace> -l app=upgrade-agent-mcp-client -w

# Watch the MCP server pods rolling update
oc get pods -n <namespace> -l app=upgrade-agent-mcp-server -w

# Check the CR status
oc describe agentservice upgrade-agent -n <namespace>
```

The agent operator will automatically handle the upgrade process, including rolling updates of both MCP client and server pods.

### Step 6: Uninstall the Agent

To uninstall the agent:

**If the agent was previously subscribed to watsonx Orchestrate**, first unsubscribe it:

1. Open the Cloud Pak for Data (CPD) home page.
   - Example: `https://cpd-<instance>.apps.<cluster-domain>/zen/?context=icp4data#/homepage`

2. Click on the **Launch WXA4Z console** tab.
   - This opens the WXA4Z Content Ingestion UI (Tenant Overview page).
   - Example: `https://wxa4z-content-ingestion-ui-route-wxa4z-zad.apps.<cluster-domain>/en`

3. On the Tenant Overview page, click on your **Tenant name**.

4. Navigate to the **Subscriptions** tab.
   - You will see a list of deployed agents with an **Unsubscribe** button next to each.

5. Click the **Unsubscribe** button next to the **IBM Z Upgrade Agent**.
   - This action removes the agent from watsonx Orchestrate (WXO).

**Then, delete the agent resources:**

1. Delete the Custom Resource:

```bash
oc delete agentservice upgrade-agent -n <namespace>
```

2. Verify the agent resources are removed:

```bash
# Check that the MCP client pods are terminated
oc get pods -n <namespace> -l app=upgrade-agent-mcp-client

# Check that the MCP server pods are terminated
oc get pods -n <namespace> -l app=upgrade-agent-mcp-server

# Verify the CR is deleted
oc get agentservice -n <namespace>
```

3. (Optional) Clean up secrets if no longer needed:

```bash
# Delete agent-specific secrets
oc delete secret wxa4z-upgrade-agent-secrets -n <namespace>

# Note: Do not delete global secrets if other agents are using them
```

> **Note:** The agent operator will automatically clean up all resources created by the agent, including deployments, services, and configmaps. However, secrets must be manually deleted if they are no longer needed.

## Test the agent

After deployment, the agent becomes active and is available for selection in the live environment.

1. From the main menu, click **Chat**.
2. Choose your agent from the list.
3. Enter your queries using the AI Assistant.
   For example:
   
      - Can you show software instance available for system AQFT?

      - Can you retrieve missing fixcat updates for software instance Watsonx-Testing on system S2?

    Responses are displayed either in a tabular format or as a sentence, depending on the context.

4. Verify that the responses returned by the AI Assistant are accurate.

## Troubleshooting installation errors

If you run into any errors during installation, see [Troubleshooting](../../README.md#troubleshooting) for troubleshooting steps.

## Uninstalling the agent

1. Open the Cloud Pak for Data (CPD) home page.
   - Example: `https://cpd-<instance>.apps.<cluster-domain>/zen/?context=icp4data#/homepage`

2. Click on the **Launch WXA4Z console** tab.
   - This opens the WXA4Z Content Ingestion UI (Tenant Overview page).
   - Example: `https://wxa4z-content-ingestion-ui-route-wxa4z-zad.apps.<cluster-domain>/en`

3. On the Tenant Overview page, click on your **Tenant name**.

4. Navigate to the **Subscriptions** tab.
   - You will see a list of deployed agents with a **Unsubscribe** button next to each.

5. Click the **Unsubscribe** button next to the **IBM Z Upgrade Agent**.
   - This action removes the agent from watsonx Orchestrate (WXO).


## Troubleshooting agent runtime errors

Follow these steps to troubleshoot agent runtime errors:

1. _OpenSearch Connection Error_: Check that WRAPPER_URL, WRAPPER_USERNAME, and WRAPPER_PASSWORD are correct
3. _PTF Job Failures_: Verify all SMP/E configuration parameters (SMPNTS, SMPWDIR_PATH, SMPJHOME, SMPCPATH) are correct
4. _Certificate Issues_: Ensure KEYRING, CERT_NAME, DOWNLOADKEYRING, and SIGNATUREKEYRING are properly configured in RACF
5. _MCP Communication Issues_: Check that both MCP client and server pods are running and can communicate

-------------------------
