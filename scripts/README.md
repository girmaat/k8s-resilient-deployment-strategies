# ⚙️ Kubernetes Diagnostic & Utility Scripts

This folder provides production-grade troubleshooting and automation tools for managing Kubernetes workloads across areas like stability, networking, IAM, probes, and scheduling.

---

## 🩺 Diagnostic Scripts

### 1. `k8-pod-lifecycle-stability-diagnose.sh`
Diagnoses pod lifecycle failures:
- `CrashLoopBackOff`, `ImagePullBackOff`, `ContainerCreating`
- `OOMKilled`, high restart counts
- Job backoff failures
- Auto-restarts or rollbacks in `--fix` mode

**Usage**
```bash
./k8-pod-lifecycle-stability-diagnose.sh <namespace> [--fix]

2. k8s-config-scheduling-diagnose.sh
Detects configuration & scheduling issues:

Missing ConfigMap, Secret, or PVC

Bad env var refs, toleration/taint mismatches

Overprovisioned CPU/memory

Affinity rules blocking scheduling

--fix mode can:

Create placeholders for ConfigMaps and Secrets

Patch tolerations in deployments

Usage

./k8s-config-scheduling-diagnose.sh <namespace> [--fix]

3. k8s-network-diagnose.sh
Validates networking inside the cluster:

DNS resolution inside pods

Service reachability (ClusterIP, port 80)

Port mismatch between Services and containers

Empty endpoint mappings

Ingress routing, NetworkPolicy, and LoadBalancer checks

Detects duplicate endpoint IPs

Usage

./k8s-network-diagnose.sh <namespace>
4. k8s-probe-diagnose.sh
Checks health probe configuration:

Readiness/liveness probe failures

Probe timing issues (e.g., initialDelaySeconds)

Endpoint behavior (HTTP 4xx/5xx)

Suggests startupProbe for slow boot apps

--fix mode can:

Patch delay thresholds

Add startupProbe based on readiness

Usage
./k8s-probe-diagnose.sh <namespace> [--fix]
5. k8s-security-diagnose.sh
Diagnoses IAM and security issues:

IRSA role annotation and trust policy

Missing ServiceAccount token mounts

Invalid or missing AWS STS identity

Missing RBAC RoleBindings

Exposed secrets in pod environment variables

--fix mode can:

Patch missing IRSA annotations

Usage
./k8s-security-diagnose.sh <namespace> [--fix]
⚙️ Utility Scripts
6. load-generator.sh
Launches synthetic load (e.g. K6 or Locust) against services for:

HPA testing

Resiliency evaluation

Stress simulation

Usage

./load-generator.sh <namespace>
7. rollout-recovery.sh
Automates rollback and status checks for deployments:

Monitors rollout progress

Reverts faulty rollouts using kubectl rollout undo

Outputs logs from failing pods (if any)

Usage

./rollout-recovery.sh <deployment-name> <namespace>
🧩 Conventions
All scripts are POSIX-compatible and require kubectl, jq, and optionally awscli

--fix mode requires interactive input and admin permissions

Use kubectl config use-context to target the correct EKS cluster