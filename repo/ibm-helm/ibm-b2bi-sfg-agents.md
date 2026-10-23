# IBM Sterling B2B Integrator and File Gateway Agents 1.0.0.0

Deploys the IBM Sterling B2B Integrator and File Gateway Agents (multi-agent host) and its co-located
`b2bi-mcp-server` tool server as a single Helm release, per
`agent-hub/ocp/Agent-Deployment-Spec-v0.5.md` section 8 (Pattern B: "agent
chart includes MCP server"), packaged for OCP/Kubernetes.

## Prerequisites

- Helm >= 4.2.3
- OpenShift Client (`oc`) >= 4.22
- Kubernetes >= 1.32 / OpenShift >= 4.19 & <=4.22
- All pods must be able to run under the `restricted-v2` SCC (OCP) / restricted
  Pod Security Standard (vanilla Kubernetes) — this chart does not request
  elevated permissions.
- **Recommended with AgentHub deployed on OCP:** OpenShift Service Mesh (Istio) >= 3.4.
  Since `istio.enabled=true` is this chart's **default**, sidecar injection
  must be enabled on the target namespace **before** installing, or agent/
  mcp-server pods will get stuck waiting on a proxy that never starts (no
  sidecar was injected, yet this chart's `PeerAuthentication` still requires
  STRICT mTLS). Enable it with whichever mechanism your mesh installation
  uses — check with your platform/mesh administrator:
  ```console
  kubectl label namespace <your-namespace> istio-injection=enabled
  # or, for revision-based injection (common on newer OSSM 3 / Sail Operator setups):
  kubectl label namespace <your-namespace> istio.io/rev=<your-istio-revision-name>
  ```
  If istiod runs in a **different** namespace than this release (typical),
  also set `istio.controlPlaneNamespace` — see
  [Network policy](#network-policy) below, and
  [Istio vs. native mTLS](#istio-vs-native-mtls) below.
- A reachable B2BI/SFG instance and credentials for `mcpServer.b2bi.baseUrl`.
  The B2BI/SFG user that AgentHub impersonates must be granted `APIUser`, or
  the specific GET/POST/PUT/DELETE API permissions matching whichever B2BI/SFG
  REST APIs the agent needs to invoke. Refer to the B2BI/SFG product
  documentation for how to assign these permissions.
- An ingress `NetworkPolicy` (or equivalent firewall rule) added on the B2BI/SFG
  side that allows inbound traffic from this release's namespace on the B2BI
  API port (`mcpServer.b2bi.baseUrl`'s port) — this chart's own `NetworkPolicy`
  resources (see [Network policy](#network-policy)) only manage egress *from*
  the agent/mcp-server pods; they cannot open ingress on the B2BI side, which
  lives outside this chart's control and must be configured separately.
- A reachable model gateway address for `agents.modelGateway.url` — required
  whenever `agents.modelGateway.mode=hub` (the default). Left empty, the agent
  starts but every LLM call fails with `MODEL_GATEWAY_MODE=hub but
  HUB_MODEL_GATEWAY_URL not set`. If the gateway requires an API key
  (`agents.modelGateway.auth=api_key`), pre-create a Secret for it before
  installing — see [Model gateway](#model-gateway).

## Quick start

`your-namespace` below is just a placeholder — use the same namespace used for the AgentHub deployment which generally defaults to `agenthub`.

Both examples below rely on `agents.mode` (`hub` by default, or `standalone`):
`hub` mode registers this deployment with the Agent Hub at
`agents.hub.registryUrl` and lets the Hub route requests to it; `standalone`
mode skips Hub registration entirely and routes internally, with no Hub
dependency at all.

With Istio (the default — **enable sidecar injection on the namespace first**,
see [Prerequisites](#prerequisites), or pods will hang instead of becoming Ready):

```console
kubectl create namespace your-namespace
kubectl label namespace your-namespace istio-injection=enabled

helm install my-agents ./ibm-b2bi-sfg-agents \
  --namespace your-namespace \
  --set global.license=true \
  --set istio.installed=true \
  --set agents.hub.registryUrl=https://agent-hub:8443/v1/registry/agents \
  --set agents.modelGateway.url=https://gateway-ibm-agenthub-gateway:8002/v1 \
  --set mcpServer.b2bi.baseUrl=https://your-b2bi-host:9080 \
  --set mcpServer.b2bi.username=admin \
  --set mcpServer.b2bi.password=changeme
```

The examples above set `agents.modelGateway.url` since `agents.modelGateway.mode`
defaults to `hub` — see [Model gateway](#model-gateway) for the gateway's
auth options (including API-key Secret setup) and the `direct` alternative.

Run `helm test my-agents -n your-namespace` afterwards to verify both `/health`
endpoints respond.

## Configuration

| Value | Default | Purpose |
|---|---|---|
| `agents.preferDataUserPrompt` | `false` | Query source for `POST /message:send` — `true` prefers `message.parts[].data.user_prompt`, `false` prefers `message.parts[].text` (the orchestrator's execution plan). Toggle to test both payload shapes with AgentHub until their text-part handling is fixed. Sets the `PREFER_DATA_USER_PROMPT` container env var. |
| `agents.mcpDiscoverMaxRetries` | `3` | Max attempts for the initial MCP tools/list discovery handshake at startup. Increase if MCP server pods are slow to become Ready behind their Service. Sets the `MCP_DISCOVER_MAX_RETRIES` container env var. |

## Agents

The `agents` image is a multi-agent package — one combined Deployment hosts
every bundled agent, not one Deployment
per agent. `agents.*` is therefore mostly common config for that single
instance (image, port, hub, modelGateway, resources, probes, etc.), with one
exception: nested per-agent-ID entries (e.g. `agents.b2bi_resolution_v1.enabled`,
matching the agent ID baked into the image) are enable/disable bookkeeping
only — they do **not** gate the Deployment/Service/HPA/PDB/NetworkPolicy/Istio
policies, which always exist as long as this release is installed. Reserved
for future per-agent filtering once the service supports selectively
activating bundled agents; not yet consumed by the running service.

## Istio vs. native mTLS

| | `istio.enabled=true` (default) | `istio.enabled=false` |
|---|---|---|
| mTLS | STRICT, enforced by the mesh sidecar (`PeerAuthentication`) | App-level TLS via `agents.nativeTls` (mounted cert/key/CA Secret) |
| App listener | Plain HTTP (sidecar terminates mTLS) | HTTPS (agent only — see Dockerfile) |
| Identity/authz | `AuthorizationPolicy` (mesh principals) | `agents.authMode=mtls` (custom `X-Client-Cert-DN` header) |
| Prerequisite | OpenShift Service Mesh installed + namespace enrolled; `istio.installed=true` to acknowledge | None |

This chart does **not** hard-require Istio. `istio.enabled=true` is recommended
on OCP with OSSM already available (it's the same mesh the Agent Hub platform
itself requires); `istio.enabled=false` is for clusters without a service
mesh. Do not set `agents.authMode=mtls` while `istio.enabled=true` — Istio
emits `X-Forwarded-Client-Cert`, not the `X-Client-Cert-DN` header the app
checks for; use `agents.authMode=none` and rely on the mesh's
`AuthorizationPolicy` for identity instead (the chart's default).

## Secrets

This chart never accepts plaintext credentials as first-class values (OWASP
A02/A05) except as an explicit, documented quick-start convenience:

| Value | Purpose | Preferred |
|---|---|---|
| `mcpServer.b2bi.existingSecretName` | B2BI credentials (`B2BI_USERNAME`/`B2BI_PASSWORD` or `B2BI_API_TOKEN`) for a user with the `APIUser` permission — see [Prerequisites](#prerequisites) | Pre-create the Secret and reference it here |
| `mcpServer.logExtraction.downloadApiSecretName` | Shared HMAC secret (key `DOWNLOAD_API_SECRET`, fixed) for signing `download_logs` links — see [Download links](#download-links--downloadapisecretname-downloadexternalbaseurl) | Always pre-create — must match B2BI/SFG's own `download.api.secret` byte-for-byte |
| `agents.nativeTls.existingSecretName` | mTLS `agent.crt`/`agent.key`/`hub-ca.crt` (native TLS mode) | Always pre-create — this chart never generates certs |
| `agents.apiKeyExistingSecretName` | `API_KEY` (when `authMode=api_key`) | Always pre-create |
| `agents.modelGateway.apiKeyExistingSecretName` | `MODEL_GATEWAY_API_KEY` (when `agents.modelGateway.auth=api_key`) | Always pre-create — see [Model gateway](#model-gateway) |
| `sharedCacheStore.passwordExistingSecretName` | `SHARED_CACHE_PASSWORD` (redis/valkey auth, when `sharedCacheStore.enabled=true`) | Always pre-create — see [Shared cache](#shared-cache-valkey) |

## Shared cache (Valkey)

Pending human-in-the-loop approvals and similar cross-request state use a
generic, backend-agnostic shared cache (`sharedCacheStore`) rather than
in-process memory, so state survives across the agent's multiple replicas.
It is disabled by default — the agent falls back to an in-memory cache (not
safe across replicas, but requires no external dependency) when
`sharedCacheStore.enabled=false`.

Two ways to enable it:

**1. Bring your own** (recommended for production) — point at an
externally-managed, clustered/HA `redis`/`valkey`/`memcached` instance:

```yaml
sharedCacheStore:
  enabled: true
  backend: valkey
  url: my-external-valkey:6379
  passwordExistingSecretName: my-external-valkey-password
```

For redis/valkey, prefer `passwordExistingSecretName` (an existing Secret with
a `password` key, wired in as `SHARED_CACHE_PASSWORD`) over embedding a
password in `url` directly. Not applicable for `memcached` (no AUTH
mechanism).

**2. Use the bundled single-instance Valkey** — a quick-start/dev option with
no external dependency (no clustering/HA; a best-effort cache, not a source of
truth, backed by a PVC so data survives pod restarts):

```yaml
sharedCacheStore:
  enabled: true
  bundled:
    enabled: true
    image:
      repository: cp.icr.io/cp/ibm-b2bi-sfg-agents/b2bi-valkey
      tag: "8.1.10"
```

`sharedCacheStore.url` is left blank in this case — it defaults to the
bundled Valkey Service's in-cluster DNS name automatically.

A pre-built `b2bi-valkey` image is shipped for this chart, and
`sharedCacheStore.bundled.image.repository` defaults to it
(`cp.icr.io/cp/ibm-b2bi-sfg-agents/b2bi-valkey`). Override
`repository`/`.tag` only if you mirror the image to a private registry or
build your own (see [deploy/valkey/README.md](../../valkey/README.md)).

The bundled Valkey Deployment/Service/PVC are only rendered when
`sharedCacheStore.bundled.enabled=true`; the `NetworkPolicy` rules
restricting access to it (see [Network policy](#network-policy)) only render
alongside it.

## MCP server wiring

`agents.mcpServers` renders `config/mcp_servers.yaml` for
the agent container. Leave it empty (default) to auto-wire to this chart's
own co-located `mcpServer` Service. Set it explicitly to point at
additional/external MCP servers:

```yaml
agents:
  mcpServers:
    - name: b2bi
      transport: http
      url: http://my-agents-ibm-b2bi-sfg-agents-mcp-server:8090/mcp
      auth: none
```

### MCP server OAuth2 authentication

Setting `mcpServer.authMode=oauth2` makes `b2bi-mcp-server` an OAuth2
**resource server** — it validates every inbound request's `Authorization:
Bearer` token (signature, issuer, audience, expiry) against an identity
provider's JWKS before allowing the call through:

| Value | Default | Purpose |
|---|---|---|
| `mcpServer.oauth.issuer` | `""` | **Required.** The identity provider's OAuth2 issuer URL. |
| `mcpServer.oauth.audience` | `"b2b-client"` | **Required.** Expected `aud` claim on inbound tokens. Identity-services commonly set `aud` to the calling client's own `client_id` (not a fixed service name) — set this to match the `client_id` configured in `agents.mcpOAuth`'s secret. |
| `mcpServer.oauth.jwksUri` | `""` | Override the JWKS endpoint; defaults to `{issuer}/.well-known/jwks.json` when empty. |
| `mcpServer.oauth.clockSkewSeconds` | `60` | Leeway for `exp`/`nbf` validation. |
| `mcpServer.oauth.jwksCacheTtlSeconds` | `300` | How long the JWKS signing keys are cached before refreshing. |

To enable OAuth authentication/authorization for the Agent Hub user impersonating B2BI user on the B2BI APIs side, `mcpServer.b2bi.authStrategy` should be set to `relay`, in which case the MCP server relays the OAuth token to B2BI APIs. On the B2BI APIs side, it should also be configured for OAuth authentication as per the B2BI/SFG product documentation. If configured for OAuth, the APIs validate the token on every inbound request and authorize based on the permissions assigned to the user.

| Value | Default | Purpose |
|---|---|---|
| `mcpServer.b2bi.authStrategy` | `static` | Set to Static or Relay. Should be set to `relay` to pass the OAuth token to B2BI APIs |

The agent, in turn, needs to **obtain and send** that Bearer token — it acts
as an OAuth2 **client** using the client-credentials grant. For the
auto-wired co-located `mcpServer` entry (`agents.mcpServers` left empty), set:

| Value | Purpose |
|---|---|
| `agents.mcpOAuth.tokenUrl` | The identity provider's token endpoint |
| `agents.mcpOAuth.existingSecretName` | Name of a pre-created Secret with keys `client_id` and `client_secret` — always pre-create, this chart never generates it |
| `agents.mcpOAuth.scope` | Optional space-separated scopes to request |


`mcpServer.oauth.issuer`, `agents.mcpOAuth.tokenUrl`, and `mcpServer.oauth.jwksUri`
are all derived from the same identity-service base address —
`<protocol>://<identity-service-FQDN>:<identity-service-port>` — with a
fixed path appended for the token and JWKS endpoints:

```
issuer   = https://identity-service.example.com:8443
tokenUrl = https://identity-service.example.com:8443/oauth2/token
jwksUri  = https://identity-service.example.com:8443/oauth2/jwks
```
Note that the mcp-oauth-creds secret should have the same client_id and client_secret values as configured on the B2BI deployment side.

```console
kubectl create secret generic mcp-oauth-creds \
  --namespace your-namespace \
  --from-literal=client_id=b2b-client \
  --from-literal=client_secret=b2b-secret

helm upgrade --install my-agents ./ibm-b2bi-sfg-agents \
  --namespace your-namespace \
  --set mcpServer.authMode=oauth2 \
  --set mcpServer.oauth.issuer=https://identity-service.example.com:8443 \
  --set mcpServer.oauth.jwksUri=https://identity-service.example.com:8443/oauth2/jwks \
  --set mcpServer.oauth.audience=b2b-client \
  --set agents.mcpOAuth.tokenUrl=https://identity-service.example.com:8443/oauth2/token \
  --set agents.mcpOAuth.existingSecretName=mcp-oauth-creds
```

If you configure `agents.mcpServers` manually instead (external MCP servers),
`agents.mcpOAuth` does not apply — add an `oauth:` block (`token_url`,
`client_id`/`client_id_env`, `client_secret`/`client_secret_env`, `scope`)
directly to that entry's YAML instead; the `_env`-suffixed keys name
container env vars this chart doesn't set for you in that case — add them
via `agents.extraEnv` with your own `secretKeyRef`.

#### Network policy for identity-service

Neither of the identity-service endpoints above is covered by this chart's
built-in `NetworkPolicy` allow-rules (see [Network policy](#network-policy))
— **both** the agent (token endpoint) and mcp-server (JWKS endpoint) need
egress to identity-service, or requests will be silently dropped:

```yaml
networkPolicy:
  extraEgress:
    # identity-service token + JWKS endpoints (OAuth2)
    - to:
        - ipBlock: { cidr: 10.0.0.0/8 }
      ports:
        - protocol: TCP
          port: 8443
```

Use a `podSelector`/`namespaceSelector` instead of `ipBlock` if
identity-service is a same-namespace or same-cluster Service — see the
supervisor/model-gateway examples in [Network policy](#network-policy) for
that pattern.

This egress rule only opens the path from this chart's side. identity-service
itself typically also enforces its own ingress `NetworkPolicy` (or
firewall) — a matching **ingress** rule must be added on the identity-service
deployment allowing traffic from this release's namespace on its OAuth2 port,
the same way the [Prerequisites](#prerequisites) section describes for
B2BI/SFG. This chart has no way to manage that policy since it lives outside
its own resources.

## Log extraction — sharing B2BI's logs volume

The bundled `extract_logs`/`download_logs` MCP tools (and B2BI/SFG's own log
download API) work against the **same physical logs volume** — B2BI/SFG
writes its logs there, `b2bi-mcp-server` reads/archives from it
(`mcpServer.logExtraction.persistence`, mounted at `/app/logs`), and writes
its `_archive` folder (`mcpServer.logExtraction.archiveDirname`) back into
that same volume so B2BI/SFG's own download API can serve it. This only works
if both sides are genuinely looking at the same files on disk — this section
covers how to wire that up.

Log-line timestamps on that volume are naive (no timezone offset) and in
whatever local time B2BI/SFG's own server runs in — set
`mcpServer.b2bi.serverTimezone` (env var `B2BI_SERVER_TIMEZONE`, IANA zone
name e.g. `UTC`, `Asia/Kolkata`) to that server's timezone so `extract_logs`/
`download_logs` can correctly convert UTC tool inputs to match. Leave blank
to use the image's bundled default (`America/New_York`).

**Namespaces, release names, storage/NFS server addresses, and paths below
are all customer/environment-specific** — substitute your own throughout;
nothing here is a fixed convention.

### Why this needs a few manual steps

A `PersistentVolumeClaim` is a **namespaced** object — a Pod can only mount a
PVC that exists in its own namespace, so `b2bi-mcp-server` cannot directly
mount B2BI/SFG's PVC if they're deployed in different namespaces (the common
case). This chart also always provisions its own dedicated PVC for
`mcpServer.logExtraction.persistence` (no "use an existing PVC" option).

What two Pods in different namespaces *can* share is the same **underlying
storage** — if B2BI/SFG's logs volume is backed by NFS (common for a
`ReadWriteMany` logs volume), the same NFS export can be mounted a second
time, independently, from this chart's namespace, via a second
`PersistentVolume`/`PersistentVolumeClaim` pair that points at the same NFS
server + path. `PersistentVolume` objects are cluster-scoped, so this works
regardless of which namespace either chart is installed into.

### Step 1 — find B2BI/SFG's real logs volume

```bash
# Replace with your B2BI/SFG release name/namespace
B2BI_NAMESPACE=your-b2bi-namespace
B2BI_LOGS_PVC=your-b2bi-release-b2bi-logs   # ibm-b2bi-prod's logs PVC naming convention

PV_NAME=$(kubectl get pvc "$B2BI_LOGS_PVC" -n "$B2BI_NAMESPACE" -o jsonpath='{.spec.volumeName}')
kubectl get pv "$PV_NAME" -o jsonpath='{.spec.nfs}{"\n"}'
# -> {"path":"/nfs-share/b2bi-logs","server":"10.x.x.x"}
```

If this isn't NFS-backed (a different `spec.<driver>` block instead of
`spec.nfs`), the approach below doesn't apply as-is — consult your storage
provider for an equivalent "mount the same export from a second namespace"
option.

### Step 2 — confirm the real on-disk layout

B2BI/SFG mounts this volume at `/ibm/trace` (not `/ibm/trace/logs`) — the
actual log files live one level deeper, under `/ibm/trace/logs/`, which is
where B2BI/SFG's own log-download API also expects `_archive` to live
(`b2bAPIs.download.log.archiveDir=/ibm/trace/logs/_archive` in B2BI/SFG's own
`customer_overrides.properties`). This chart's `b2bi-mcp-server`, however,
mounts its logs volume directly at `/app/logs` with no extra subdirectory.

To make `/app/logs` (this chart) and `/ibm/trace/logs` (B2BI/SFG) refer to
the exact same directory, point the new `PersistentVolume`'s NFS `path` **one
level deeper** than B2BI/SFG's own PV — at the `logs` subdirectory of its
export, not the export root:

```
B2BI/SFG's own PV: server=10.x.x.x path=/nfs-share/b2bi-logs
This chart's PV:   server=10.x.x.x path=/nfs-share/b2bi-logs/logs   <- note the extra "/logs"
```

(That `logs` subdirectory already exists once B2BI/SFG itself has started at
least once and written anything — confirm with a quick `kubectl exec` into
the B2BI/SFG pod, `ls /ibm/trace/`, before continuing.)

### Step 3 — create a second PV for this chart's namespace

```yaml
# b2bi-shared-logs-pv.yaml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: b2bi-shared-logs-pv
spec:
  capacity:
    storage: 1000Mi            # match (or safely exceed) B2BI/SFG's own logs PVC size
  accessModes:
    - ReadWriteMany
  persistentVolumeReclaimPolicy: Retain   # IMPORTANT — never Delete; this volume holds B2BI/SFG's real log data
  storageClassName: b2bi-shared-logs       # a name used by nothing else, so the PVC below binds to exactly this PV
  nfs:
    server: 10.x.x.x                       # from Step 1
    path: /nfs-share/b2bi-logs/logs        # from Step 2 — one level deeper than B2BI/SFG's own PV
```

```bash
kubectl apply -f b2bi-shared-logs-pv.yaml
```

`storageClassName` here is a plain label, not a real provisioner — as long
as no other PV on the cluster uses the same (unusual) class name, the
`PersistentVolumeClaim` this chart creates in Step 4 will bind to this exact
PV deterministically (standard Kubernetes static-binding-by-class behavior;
no provisioner needed since there's only one PV to match).

### Step 4 — point this chart's own PVC at it

```yaml
mcpServer:
  logExtraction:
    persistence:
      enabled: true
      size: 1000Mi                     # <= the PV's capacity above
      storageClassName: b2bi-shared-logs
      accessMode: ReadWriteMany
```

```bash
helm upgrade --install my-agents ./ibm-b2bi-sfg-agents \
  --namespace your-namespace \
  -f your-values.yaml
```

Verify the resulting PVC actually bound to the PV from Step 3 (not some
other PV):

```bash
kubectl get pvc -n your-namespace -l app.kubernetes.io/component=mcp-server
# VOLUME column should read b2bi-shared-logs-pv
```

### Step 5 — verify both sides see the same files

```bash
kubectl exec -n your-namespace deploy/my-agents-ibm-b2bi-sfg-agents-mcp-server -c mcp-server -- ls /app/logs
kubectl exec -n your-b2bi-namespace your-b2bi-release-b2bi-api-server-0 -- ls /ibm/trace/logs
# both should list the same files
```

### Permissions

OpenShift's `restricted-v2` SCC assigns each pod a per-namespace random UID
but a shared group `0` (root group) — in testing, this was sufficient for
`b2bi-mcp-server` to create `_archive/` and write files on an NFS export
originally owned by B2BI/SFG's own (different) random UID, without any extra
configuration. If your NFS server's export options are more restrictive
(e.g. `root_squash` combined with strict UID/GID enforcement), you may need
to adjust the export's squash/permission settings instead — this chart has
no values-based control over the NFS server side of this.

### Download links — `downloadApiSecretName`, `downloadExternalBaseUrl`

`download_logs` (one of the bundled MCP tools) packages matching log content
into a zip and returns a signed, time-limited download URL rather than the
raw file content. Signing/verifying that link requires a shared HMAC secret
(`download.api.secret`) that must match **byte-for-byte** with B2BI/SFG's own
value — the `ibm-b2bi-prod` chart's `setupCfg.downloadApiSecret`, configurable
in B2BI/SFG >= v6.2.2.2 (the name of a Secret it already expects to exist,
default key `DOWNLOAD_API_SECRET`) — and the link is built from
`mcpServer.logExtraction.downloadExternalBaseUrl`:

| Value | Env var | Default | Purpose |
|---|---|---|---|
| `mcpServer.logExtraction.downloadApiSecretName` | `DOWNLOAD_API_SECRET` (Secret key, fixed) | `""` | Pre-created Secret name holding the shared HMAC secret — see below. |
| `mcpServer.logExtraction.downloadExternalBaseUrl` | `LOG_EXTRACTION_DOWNLOAD_BASE_URL` | `""` | Required for `download_logs` to issue a working link — see [B2BI/SFG version compatibility](#b2bisfg-version-compatibility) for what to set it to. |
| `mcpServer.logExtraction.downloadExpiryDuration` | `LOG_EXTRACTION_DOWNLOAD_EXPIRY_DURATION` | `PT4H` | ISO 8601 duration a download link stays valid (e.g. `PT1H`, `P7D`). Also drives the cleanup job below (an archive is deleted once its age exceeds this). |
| `mcpServer.logExtraction.downloadCleanupSchedule` | `LOG_EXTRACTION_DOWNLOAD_CLEANUP_SCHEDULE` | `0 0 * * *` | Cron expression (5-field, UTC) for the background job that deletes expired archives. Keep aligned with `downloadExpiryDuration` (e.g. every 4h if that's `PT4H`) — the app doesn't cross-validate the two for you. |

```yaml
mcpServer:
  logExtraction:
    # Pre-created Secret name holding the shared HMAC secret. The Secret
    # MUST contain a key literally named "DOWNLOAD_API_SECRET" -- that key
    # name is fixed by the chart, not configurable.
    downloadApiSecretName: b2bi-download-api-secret   # see below

    # Required for download_logs to issue a working link -- it fails at
    # call time (DOWNLOAD_NOT_CONFIGURED) if left blank. Set to:
    #   - "{b2bi_baseUrl}/B2BAPIs" for b2bi/SFG >= 6.2.2.2
    #   - mcp server's own reachable address for earlier versions (see below)
    downloadExternalBaseUrl: "https://your-b2bi-host:9080/B2BAPIs"

    downloadExpiryDuration: PT4H
    downloadCleanupSchedule: "0 0 * * *"
```

Secrets are namespace-scoped, so if B2BI/SFG's `b2b-download-api-secret` lives
in a **different** namespace than this release, you cannot reference it
directly — copy its *value* (not just the name) into a new Secret in this
release's own namespace instead:

```bash
# Read the existing value from B2BI/SFG's own namespace (requires read access there)
SECRET_VAL=$(kubectl get secret b2b-download-api-secret -n your-b2bi-namespace \
  -o jsonpath='{.data.DOWNLOAD_API_SECRET}' | base64 -d)

# Recreate it, byte-for-byte, in this release's namespace
kubectl create secret generic b2bi-download-api-secret \
  --namespace your-namespace \
  --from-literal=DOWNLOAD_API_SECRET="$SECRET_VAL"
```

If this chart is instead installed in the **same** namespace as B2BI/SFG,
skip the copy and reference `b2b-download-api-secret` (or whatever
`setupCfg.downloadApiSecret` is named) directly as `downloadApiSecretName`
above.

Confirm it's wired correctly after `helm upgrade` — `b2bi-mcp-server` logs a
`DownloadTokenConfig initialized` line on successful startup; if either
field above is unset or empty, `download_logs` instead fails at call time
with a `DOWNLOAD_NOT_CONFIGURED` error, not at pod startup.

#### B2BI/SFG version compatibility

`downloadExternalBaseUrl` always has the fixed `/download/log?token=<jwt>`
path appended to it — which service actually serves that path depends on
what you set it to:

- **b2bi/SFG 6.2.2.2 and later** — set it to `{b2bi_baseUrl}/B2BAPIs`;
  b2biapis already serves `GET /B2BAPIs/download/log` under that path.
- **Earlier than 6.2.2.2** — that endpoint doesn't exist yet on B2BI/SFG's
  side. Set it to this server's own reachable address instead — **one
  combined URL string** (`scheme://host:port`, e.g. `http://my-mcp-server:8090`),
  not separate host/port values. A Route (or Ingress) could be created
  exposing just this server's `/download/log` endpoint, with its external
  hostname used as this reachable address — for example, on OpenShift:

  ```bash
  oc create route edge my-mcp-server-download-log \
    --service=my-mcp-server --port=http --path=/download/log \
    --insecure-policy=Redirect
  ```

  The OpenShift router isn't an Istio mesh member, so it can't present a
  mesh client certificate — with `istio.enabled=true` this workload's
  `PeerAuthentication` defaults to `STRICT` and rejects that plaintext
  traffic at the mTLS handshake. Set `mcpServer.istio.mtls.mode: PERMISSIVE`
  so the above Route can reach it.

#### Other download-link settings (`extraEnv`)

Everything below has no dedicated values field — override via
`mcpServer.extraEnv` only if the default isn't suitable:

| Env var | Default | Purpose |
|---|---|---|
| `LOG_EXTRACTION_DOWNLOAD_JWT_ALGORITHM` | `HS256` | HMAC algorithm download tokens are signed with. Must match whatever b2biapis itself accepts: `HS256`, `HS384`, or `HS512`. |

```yaml
mcpServer:
  extraEnv:
    - name: LOG_EXTRACTION_DOWNLOAD_JWT_ALGORITHM
      value: "HS384"
```

#### Other log-extraction settings (`extraEnv`)

These also have no dedicated values field — scalar settings from the image's
bundled `log_extraction_config.yaml`, each read from its env var first,
falling back to the YAML value if unset:

| Env var | Default | Purpose |
|---|---|---|
| `LOG_EXTRACTION_NODE_PATTERN` | `node*` | Glob pattern for node subdirectories under `LOG_EXTRACTION_ROOT_LOG_PATH`. |
| `LOG_EXTRACTION_DEFAULT_WINDOW_SECONDS` | `3600` | How far back `extract_logs` searches when no timestamps are supplied. |
| `LOG_EXTRACTION_CORRELATION_CONTEXT_LINES` | `10` | Lines of context around each correlation-ID hit (before + after each occurrence). |
| `LOG_EXTRACTION_ARCHIVE_RETENTION_COUNT` | `20` | Keep at most N archives across the `_archive` folder. |
| `LOG_EXTRACTION_ZIP_COMPRESSLEVEL` | `1` | Zip compression level for `download_logs` archives: `1` (fastest/largest) to `9` (slowest/smallest). |

```yaml
mcpServer:
  extraEnv:
    - name: LOG_EXTRACTION_ARCHIVE_RETENTION_COUNT
      value: "10"
```

Not overridable this way: `common_log_files`, `log_category_mappings`, and
the two timestamp-pattern fields — all list/dict-shaped, so a single env var
can't cleanly hold one. Use `mcpServer.logExtraction.existingConfigMapName`
to replace the whole file if you need to change those.


## Model gateway

Every bundled agent calls out to an LLM through `agents.modelGateway.*`, which
is independent of Agent Hub registration (`agents.mode`/`agents.hub.*`).

| Value | Default | Purpose |
|---|---|---|
| `agents.modelGateway.mode` | `hub` | `hub` delegates chat completions to an external OpenAI-compatible gateway at `agents.modelGateway.url`. |
| `agents.modelGateway.url` | `""` | The gateway's OpenAI-compatible base URL. It needs to be derived from Agent Hub gateway service host and port - http://{gateway-service-host}:{gateway-service-port}/v1 (e.g. `http://gateway-ibm-agenthub-gateway.agenthub.svc.cluster.local:8002/v1`). **Required when `mode=hub`** — left empty, every LLM call fails at runtime with `MODEL_GATEWAY_MODE=hub but HUB_MODEL_GATEWAY_URL not set`. |
| `agents.modelGateway.auth` | `api_key` | `none` or `api_key` (sends `Authorization: Bearer <key>` using the value below). |
| `agents.modelGateway.apiKeyExistingSecretName` | `""` | Name of a Secret with key `api_key`, consumed when `auth=api_key`. This can be set to an existing secret with name `gateway-tenant` created as part of Agent Hub deployment in the same namespace. Unlike `mcpServer.b2bi.*`, this chart never creates this Secret for you inline — always configure it to a pre-existing secret. |

```console
kubectl create secret generic model-gateway-api-key \
  --namespace your-namespace \
  --from-literal=MODEL_GATEWAY_API_KEY=changeme

helm upgrade --install my-agents ./ibm-b2bi-sfg-agents \
  --namespace your-namespace \
  --set agents.modelGateway.url=https://agent-hub-model-gateway:4000/v1 \
  --set agents.modelGateway.auth=api_key \
  --set agents.modelGateway.apiKeyExistingSecretName=model-gateway-api-key
```

If the gateway is a same-namespace AgentHub component, it also needs a
`networkPolicy.extraEgress` rule — see [Network policy](#network-policy).

## Network policy

This chart is secure-by-default: a `default-deny` `NetworkPolicy`
(`networkPolicy.enabled=true`) blocks **all** ingress and egress for every pod
it manages (agent + mcp-server), then a handful of narrowly-scoped companion
policies explicitly re-allow only the traffic this chart itself needs:

| Policy | Allows |
|---|---|
| `allow-dns-egress` | DNS lookups — UDP+TCP ports 53 *and* 5353 to any destination. Both ports are allowed because NetworkPolicy matches the real destination port **after** Service DNAT, not the Service's advertised port — OpenShift's `dns-default` Service listens on 53 but its CoreDNS pods actually listen on 5353. Omitting 5353 silently breaks all DNS resolution on OpenShift. |
| `agent-allow-ingress` | Inbound traffic to the agent Deployment (e.g. from the Agent Hub, or your own clients) |
| `agent-allow-egress-to-mcp` | Agent → co-located `mcpServer` Service only |
| `mcp-server-allow-ingress-from-agent` | mcp-server accepts traffic from the agent pod in this same release, and, whenever `networkPolicy.enabled=true`, from AgentHub's Supervisor pods (`app.kubernetes.io/name: ibm-agenthub-supervisor`, `app.kubernetes.io/instance: supervisor`) — the Supervisor probes the MCP endpoint during agent registration |
| `agent-allow-egress-to-agenthub` (when `networkPolicy.agentHub.enabled=true`, default) | Agent → same-namespace AgentHub Supervisor (8080), Gateway (8002). An external Valkey is not covered — add it via `networkPolicy.extraEgress`. Selectors/ports are configurable under `networkPolicy.agentHub.*` |
| `agent-allow-egress-to-valkey` (only when `sharedCacheStore.bundled.enabled=true`) | Agent → bundled Valkey Service only |
| `valkey-allow-ingress-from-agent` (only when `sharedCacheStore.bundled.enabled=true`) | Bundled Valkey accepts traffic only from the agent pod in this same release |

**Anything else is silently dropped.** In particular, the following are common
and *not* covered by the policies above — you must add rules yourself:

**1. An external (AgentHub) Valkey** (`sharedCacheStore.url`). This release
supports AgentHub in the **same namespace** only. Supervisor and Gateway egress
is allowed out of the box (`networkPolicy.agentHub`, see table above); Valkey is
not, so add it via `networkPolicy.extraEgress` or the agent silently falls back
to its in-memory cache:

**2. The B2BI/SFG product API** (`mcpServer.b2bi.baseUrl`) is a separate
external dependency of the mcp-server component and needs its own
`extraEgress` rule too (this same value applies to both agent and mcp-server
pods) — the same `podSelector`/`namespaceSelector`/`ipBlock` patterns above
apply.

For B2BI/SFG deployed on the same cluster but a different namespace, the
`extraEgress` rule could be setup based on the `namespaceSelector` mapped to
B2BI/SFG's namespace.

This egress rule only opens the path from this chart's side. B2BI/SFG itself
typically also enforces an ingress `NetworkPolicy` (or firewall), so a
matching **ingress** rule must be added on the B2BI/SFG side allowing traffic
from this release's namespace on the B2BI API port — see
[Prerequisites](#prerequisites). This chart has no way to manage that policy
since it lives outside its own resources.

**3. Exporting traces** (`agents.otelExporterOtlpEndpoint`) needs its own
`extraEgress` rule too, for the same reason — this chart cannot know your
collector's address in advance. Don't assume the collector carries standard
`app.kubernetes.io/*` labels — debug/test collectors in particular are often
deployed with just a plain `app` label instead; check with
`kubectl get pods -n your-namespace -l <best-guess-selector> -o jsonpath='{.items[0].metadata.labels}'`
before writing the rule:

```yaml
networkPolicy:
  extraEgress:
    # OTel collector (agents.otelExporterOtlpEndpoint) — same-namespace example
    - to:
        - podSelector:
            matchLabels:
              app: otel-collector   # verify against the real pod's actual labels first
      ports:
        - protocol: TCP
          port: 4317
```

**4. istiod running in a different namespace** (the common case when
`istio.enabled=true`): the sidecar injected into every pod here needs to
reach istiod's control-plane (XDS) port, which the policies above do **not**
allow since it's cross-namespace traffic. Set `istio.controlPlaneNamespace`
to istiod's namespace (e.g. `istio-system`) and the chart adds the required
egress rule (TCP 15012) automatically — otherwise pods can get stuck waiting
on a sidecar that can never sync its config:

```yaml
istio:
  controlPlaneNamespace: istio-system
```

Leave it unset only if istiod happens to run in this same release's
namespace.

See the top-level values below (`values.yaml`) for the full configuration surface.
