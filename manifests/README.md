# 📦 Kubernetes Manifests

This directory contains all Kubernetes resource definitions grouped by workload type.

## Structure

| Folder | Contents |
|--------|----------|
| `base/`           | Global configs: namespaces, ServiceAccounts, PriorityClasses, PDBs |
| `deployments/`    | Core stateless workloads (API Gateway, Frontend UI) |
| `statefulsets/`   | Stateful apps like databases (Postgres) |
| `daemonsets/`     | Node-level agents like loggers |
| `jobs/`           | One-time tasks like batch processors |
| `cronjobs/`       | Scheduled automation (e.g., cleanup tasks) |
| `services/`       | Internal networking via ClusterIP/Headless services |
| `ingress/`        | External access via NGINX/ALB |
| `autoscaling/`    | HPA definitions for scaling workloads |
| `configs/`        | ConfigMaps and Secrets used across the stack |
| `volumes/`        | Storage classes and persistent volume setup |

## Apply All Manifests

kubectl apply -R -f manifests/

Requirements
Namespace must exist first: kubectl apply -f base/namespace.yaml

Use --prune or Helm to manage deletions gracefully


---

## 📁 `scripts/README.md`

(Already created earlier. No change needed.)

---

## 📁 `observability/README.md`


# 🔭 Observability Stack

This folder contains Prometheus and Grafana deployment manifests for cluster and app monitoring.

## Includes

- `prometheus-deployment.yaml`: Single-node Prometheus with ConfigMap-based scrape configs
- `grafana-deployment.yaml`: Grafana with password-injected via Secret
- `alert-rules.yaml`: Optional rule set for Prometheus (used via ConfigMap or CRD)

## Related Configs

Prometheus is configured using:

manifests/configs/configmap-prometheus.yaml
To enable scraping from your apps, annotate pods or deployments like:

metadata:
  annotations:
    prometheus.io/scrape: "true"
    prometheus.io/port: "8080"

Access
Grafana: http://<grafana-svc-ip>:3000

Prometheus: http://<prometheus-svc-ip>:9090

Use port-forwarding for local testing:
kubectl port-forward svc/grafana 3000:3000 -n workload-suite


