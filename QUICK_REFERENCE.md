# Quick Reference Guide

## Common Commands

### Local Development (kind)

```bash
# Create local cluster
make kind-create
# OR
./scripts/create-kind-cluster.sh

# Install chart
make install
# OR
helm install my-app ./charts/app-starter

# Install with custom values
helm install my-app ./charts/app-starter -f examples/values-dev.yaml

# Load local image
make kind-load IMAGE=my-app:latest
# OR
./scripts/load-image-kind.sh my-app:latest

# Clean up
make uninstall
make kind-delete
```

### Helm Operations

```bash
# Lint chart
helm lint ./charts/app-starter

# Render templates (dry-run)
helm template my-release ./charts/app-starter

# Install
helm install my-app ./charts/app-starter -n production --create-namespace

# Upgrade
helm upgrade my-app ./charts/app-starter -f values-prod.yaml

# Uninstall
helm uninstall my-app -n production

# List releases
helm list -A

# Get release details
helm get values my-app
helm get manifest my-app

# Rollback
helm rollback my-app 1
```

### Kubernetes Debugging

```bash
# Get all resources
kubectl get all -l app.kubernetes.io/instance=my-app

# Describe deployment
kubectl describe deployment my-app-app-starter

# View logs
kubectl logs -l app.kubernetes.io/instance=my-app --tail=100 -f

# Execute into pod
kubectl exec -it <pod-name> -- /bin/sh

# Port forward
kubectl port-forward svc/my-app-app-starter 8080:80

# Get events
kubectl get events --sort-by='.lastTimestamp'
```

### Testing

```bash
# Run all tests
make test

# Test chart installation
helm install test-release ./charts/app-starter --dry-run --debug

# Test with different values
helm template test ./charts/app-starter -f examples/values-prod.yaml | kubectl apply --dry-run=client -f -
```

## Common Configurations

### Deploy with Environment Variables

```yaml
env:
  - name: DATABASE_HOST
    value: "postgres.default.svc.cluster.local"
  - name: REDIS_URL
    value: "redis://redis:6379"
```

### Enable Ingress

```yaml
ingress:
  enabled: true
  className: nginx
  hosts:
    - host: myapp.example.com
      paths:
        - path: /
          pathType: Prefix
```

### Configure Resources

```yaml
resources:
  limits:
    cpu: 1000m
    memory: 1Gi
  requests:
    cpu: 500m
    memory: 512Mi
```

### Enable Autoscaling

```yaml
autoscaling:
  enabled: true
  minReplicas: 2
  maxReplicas: 10
  targetCPUUtilizationPercentage: 70
```

### Add Health Checks

```yaml
livenessProbe:
  enabled: true
  httpGet:
    path: /healthz
    port: http

readinessProbe:
  enabled: true
  httpGet:
    path: /ready
    port: http
```

## Troubleshooting

### Pods not starting

```bash
# Check pod status
kubectl get pods -l app.kubernetes.io/instance=my-app

# Describe pod to see events
kubectl describe pod <pod-name>

# Check logs
kubectl logs <pod-name>

# Check previous logs if pod restarted
kubectl logs <pod-name> --previous
```

### Image pull errors

```bash
# Create image pull secret
kubectl create secret docker-registry regcred \
  --docker-server=<registry> \
  --docker-username=<username> \
  --docker-password=<password>

# Add to values.yaml
imagePullSecrets:
  - name: regcred
```

### Service not accessible

```bash
# Check service
kubectl get svc my-app-app-starter

# Check endpoints
kubectl get endpoints my-app-app-starter

# Test from within cluster
kubectl run -it --rm debug --image=busybox --restart=Never -- wget -O- http://my-app-app-starter
```

### Ingress not working

```bash
# Check ingress
kubectl get ingress

# Describe ingress
kubectl describe ingress my-app-app-starter

# Check ingress controller logs
kubectl logs -n ingress-nginx -l app.kubernetes.io/component=controller
```

## File Structure Reference

```
KubeEasy/
├── charts/app-starter/
│   ├── Chart.yaml              # Chart metadata
│   ├── values.yaml             # Default configuration
│   ├── .helmignore             # Files to ignore when packaging
│   └── templates/
│       ├── _helpers.tpl        # Template helpers
│       ├── NOTES.txt           # Post-install notes
│       ├── deployment.yaml     # Deployment manifest
│       ├── service.yaml        # Service manifest
│       ├── ingress.yaml        # Ingress manifest (conditional)
│       ├── configmap.yaml      # ConfigMap manifest (conditional)
│       ├── secret.yaml         # Secret manifest (conditional)
│       ├── serviceaccount.yaml # ServiceAccount manifest
│       ├── hpa.yaml            # HPA manifest (conditional)
│       └── poddisruptionbudget.yaml  # PDB manifest (conditional)
├── examples/
│   ├── values-dev.yaml         # Development values
│   ├── values-staging.yaml     # Staging values
│   ├── values-prod.yaml        # Production values
│   └── values-custom-app.yaml  # Custom app example
├── kind/
│   └── kind-config.yaml        # kind cluster configuration
├── scripts/
│   ├── create-kind-cluster.sh  # Cluster creation script
│   └── load-image-kind.sh      # Image loading script
├── .github/workflows/
│   └── helm-lint.yaml          # CI/CD pipeline
├── Makefile                    # Common commands
├── README.md                   # Main documentation
├── CONTRIBUTING.md             # Contribution guidelines
├── CHANGELOG.md                # Version history
├── LICENSE                     # MIT License
└── .gitignore                  # Git ignore rules
```

## Environment-Specific Deployments

```bash
# Development
helm install myapp ./charts/app-starter \
  -f examples/values-dev.yaml \
  -n development --create-namespace

# Staging
helm install myapp ./charts/app-starter \
  -f examples/values-staging.yaml \
  -n staging --create-namespace

# Production
helm install myapp ./charts/app-starter \
  -f examples/values-prod.yaml \
  -n production --create-namespace
```

## Values Override Priority

Helm uses the following priority (lowest to highest):

1. `values.yaml` in the chart
2. `-f values-file.yaml` flag (can be repeated)
3. `--set` flag

Example combining multiple sources:

```bash
helm install myapp ./charts/app-starter \
  -f examples/values-prod.yaml \
  -f my-overrides.yaml \
  --set image.tag=v2.0.0 \
  --set replicaCount=5
```
