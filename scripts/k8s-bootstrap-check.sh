#!/bin/bash

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Parse flags
AUTO_FIX=false
while [[ "$#" -gt 0 ]]; do
  case $1 in
    --fix) AUTO_FIX=true ;;
  esac
  shift
done

NAMESPACE="workload-suite"
echo -e "${BLUE}🚀 Running Kubernetes Bootstrap & Validation for namespace: $NAMESPACE${NC}"
echo "======================================================================="

# 1. Verify kubectl context
echo -e "${YELLOW}🔍 Verifying current Kubernetes context...${NC}"
kubectl cluster-info || { echo -e "${RED}❌ Cluster not reachable${NC}"; exit 1; }

# 2. Check metrics-server
echo -e "${YELLOW}🔍 Checking for metrics-server...${NC}"
if ! kubectl get deployment metrics-server -n kube-system &>/dev/null; then
  echo -e "${RED}❌ metrics-server not found (HPA will not work)${NC}"
else
  echo -e "${GREEN}✅ metrics-server is present${NC}"
fi

# 3. Check StorageClass
echo -e "${YELLOW}🔍 Checking for 'gp2' StorageClass...${NC}"
if ! kubectl get sc gp2 &>/dev/null; then
  echo -e "${RED}❌ StorageClass 'gp2' not found${NC}"
else
  echo -e "${GREEN}✅ StorageClass 'gp2' is available${NC}"
fi

# 4. Check required secrets
REQUIRED_SECRETS=("tls-cert" "grafana-creds" "db-secret" "api-secret")
echo -e "${YELLOW}🔒 Checking required Secrets...${NC}"
for sec in "${REQUIRED_SECRETS[@]}"; do
  if ! kubectl get secret "$sec" -n "$NAMESPACE" &>/dev/null; then
    echo -e "${RED}❌ Missing Secret: $sec${NC}"
  else
    echo -e "${GREEN}✅ Secret '$sec' found${NC}"
  fi
done

# 5. Port-forward Prometheus and check if it's scraping api-gateway
echo -e "${YELLOW}📊 Port-forwarding Prometheus to check targets...${NC}"
kubectl port-forward svc/prometheus 9090:9090 -n "$NAMESPACE" >/dev/null 2>&1 &
PROM_PID=$!
sleep 3
if curl -s http://localhost:9090/api/v1/targets | grep -q "api-gateway"; then
  echo -e "${GREEN}✅ Prometheus is scraping api-gateway${NC}"
else
  echo -e "${RED}❌ Prometheus is not scraping api-gateway${NC}"
fi
kill $PROM_PID

# 6. Run diagnostic scripts
echo -e "${YELLOW}🛠 Running core diagnostics...${NC}"
if $AUTO_FIX; then
  ./scripts/k8-pod-lifecycle-stability-diagnose.sh $NAMESPACE --fix
  ./scripts/k8s-config-scheduling-diagnose.sh $NAMESPACE --fix
  ./scripts/k8s-probe-diagnose.sh $NAMESPACE --fix
  ./scripts/k8s-security-diagnose.sh $NAMESPACE --fix
else
  ./scripts/k8-pod-lifecycle-stability-diagnose.sh $NAMESPACE
  ./scripts/k8s-config-scheduling-diagnose.sh $NAMESPACE
  ./scripts/k8s-probe-diagnose.sh $NAMESPACE
  ./scripts/k8s-security-diagnose.sh $NAMESPACE
fi

echo -e "${GREEN}✅ Bootstrap check complete.${NC}"
