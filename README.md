# KubeEasy

A Kubernetes application deployment toolkit that lets anyone deploy containerised applications to Kubernetes with minimal configuration, whether running locally with kind or on a cloud provider.

## Overview

This project provides a reusable, extensible Helm chart that allows user to deploy any containerized application to Kubernetes with minimal configuration. Built with production best practices in mind, it removes the complexity of Kubernetes YAML and infrastructure setup so developers can get workloads running quickly and consistently.

### Key Features

- Deploy any container image with a single Helm command
- Sensible defaults with full configurability
- Support for local development using kind
- Production-ready patterns built-in
- Environment-specific configurations
- Comprehensive CI/CD pipeline
- Clear migration path to Kubernetes Operators

## Architecture

### Current: Helm-Based Approach (Phase 1)

The platform currently uses Helm charts to provide a declarative way to deploy applications. This approach:

- Provides immediate value with zero custom code
- Works across all Kubernetes distributions
- Supports GitOps workflows
- Offers extensive configuration options via `values.yaml`

### Future: Operator-Based Evolution (Phase 2)

The design anticipates evolution to a Kubernetes Operator pattern:

- **CustomResourceDefinitions (CRDs)** for application specifications
- **Go-based controllers** for automated operations
- **Enhanced lifecycle management** (auto-scaling, self-healing, upgrades)
- **Advanced features** like backup/restore, monitoring integration

The current Helm chart structure cleanly separates concerns to enable this transition without disrupting existing deployments.

## Prerequisites

- **Docker**: For building and running containers
- **kubectl**: Kubernetes CLI (v1.27+)
- **Helm**: Package manager for Kubernetes (v3.12+)
- **kind**: For local Kubernetes clusters (v0.20+)

### Installation

```bash
# Install Docker
# Visit https://docs.docker.com/get-docker/

# Install kubectl
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
chmod +x kubectl
sudo mv kubectl /usr/local/bin/

# Install Helm
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

# Install kind
go install sigs.k8s.io/kind@latest
# Or on macOS: brew install kind
```

## Quick Start

### 1. Create a Local Kubernetes Cluster

```bash
# Clone this repository
git clone https://github.com/harleyzhd/KubeEasy.git
cd KubeEasy

# Create a kind cluster with ingress support
./scripts/create-kind-cluster.sh

# Verify cluster is running
kubectl cluster-info --context kind-app-starter
```

### 2. Deploy Your First Application

Deploy a sample nginx application:

```bash
helm install my-app ./charts/app-starter \
  --set image.repository=nginx \
  --set image.tag=1.25 \
  --set service.type=NodePort \
  --set service.nodePort=30080
```

Access the application:

```bash
# Get the service URL
kubectl get svc -l app.kubernetes.io/instance=my-app

# Access via NodePort (if using kind, map port 30080)
curl http://localhost:30080
```

### 3. Deploy with Custom Configuration

Create a custom values file:

```yaml
# my-values.yaml
replicaCount: 3

image:
  repository: myregistry/myapp
  tag: "v1.0.0"
  pullPolicy: Always

resources:
  limits:
    cpu: 500m
    memory: 512Mi
  requests:
    cpu: 250m
    memory: 256Mi

env:
  - name: APP_ENV
    value: "production"
  - name: LOG_LEVEL
    value: "info"

configMap:
  enabled: true
  data:
    app.config: |
      server:
        port: 8080
        timeout: 30s

secret:
  enabled: true
  data:
    DATABASE_PASSWORD: supersecret
    API_KEY: your-api-key-here

ingress:
  enabled: true
  className: nginx
  annotations:
    cert-manager.io/cluster-issuer: letsencrypt-prod
  hosts:
    - host: myapp.example.com
      paths:
        - path: /
          pathType: Prefix
  tls:
    - secretName: myapp-tls
      hosts:
        - myapp.example.com
```

Deploy with your custom values:

```bash
helm install my-app ./charts/app-starter -f my-values.yaml
```

## Configuration Reference

### Essential Configuration

| Parameter | Description | Default |
|-----------|-------------|---------|
| `replicaCount` | Number of pod replicas | `1` |
| `image.repository` | Container image repository | `nginx` |
| `image.tag` | Image tag | `""` (uses chart appVersion) |
| `image.pullPolicy` | Image pull policy | `IfNotPresent` |

### Service Configuration

| Parameter | Description | Default |
|-----------|-------------|---------|
| `service.type` | Service type (ClusterIP, NodePort, LoadBalancer) | `ClusterIP` |
| `service.port` | Service port | `80` |
| `service.targetPort` | Container port | `80` |

### Resource Management

| Parameter | Description | Default |
|-----------|-------------|---------|
| `resources.limits.cpu` | CPU limit | `100m` |
| `resources.limits.memory` | Memory limit | `128Mi` |
| `resources.requests.cpu` | CPU request | `100m` |
| `resources.requests.memory` | Memory request | `128Mi` |

### Environment Variables

```yaml
env:
  - name: ENV_VAR_NAME
    value: "value"
  - name: SECRET_ENV_VAR
    valueFrom:
      secretKeyRef:
        name: my-secret
        key: password
```

### ConfigMaps and Secrets

```yaml
configMap:
  enabled: true
  data:
    config.yaml: |
      key: value

secret:
  enabled: true
  data:
    API_KEY: your-secret-here
```

For a complete configuration reference, see [`charts/app-starter/values.yaml`](charts/app-starter/values.yaml).

## Local Development with kind

### Loading Local Images

If you've built a Docker image locally and want to test it in kind:

```bash
# Build your image
docker build -t my-app:latest .

# Load it into kind
./scripts/load-image-kind.sh my-app:latest

# Deploy with the local image
helm install my-app ./charts/app-starter \
  --set image.repository=my-app \
  --set image.tag=latest \
  --set image.pullPolicy=Never
```

### Setting up Ingress

The kind cluster includes nginx-ingress-controller. To test ingress locally:

```bash
# Deploy with ingress enabled
helm install my-app ./charts/app-starter \
  --set ingress.enabled=true \
  --set ingress.className=nginx \
  --set ingress.hosts[0].host=myapp.local \
  --set ingress.hosts[0].paths[0].path=/ \
  --set ingress.hosts[0].paths[0].pathType=Prefix

# Add to /etc/hosts
echo "127.0.0.1 myapp.local" | sudo tee -a /etc/hosts

# Access via browser
open http://myapp.local
```

## Multi-Environment Deployments

The `examples/` directory contains environment-specific values files:

```bash
# Development
helm install my-app ./charts/app-starter -f examples/values-dev.yaml

# Staging
helm install my-app ./charts/app-starter -f examples/values-staging.yaml

# Production
helm install my-app ./charts/app-starter -f examples/values-prod.yaml
```

### Environment Strategy

- **Development**: Single replica, relaxed resources, debug logging
- **Staging**: Production-like setup with lower resource limits
- **Production**: Multiple replicas, strict resources, monitoring enabled

## CI/CD Pipeline

This repository includes a GitHub Actions workflow that:

1. **Lints** all Helm charts using `helm lint`
2. **Templates** charts to validate YAML structure
3. **Tests** installation in a kind cluster
4. **Validates** example values files

The pipeline runs on:
- Push to `main` or `develop` branches
- Pull requests to `main` or `develop`
- Changes to charts or workflow files

See [`.github/workflows/helm-lint.yaml`](.github/workflows/helm-lint.yaml) for details.

## Production Best Practices

While this chart provides sensible defaults, consider enabling these features for production:

### Health Checks

```yaml
livenessProbe:
  enabled: true
  httpGet:
    path: /healthz
    port: http
  initialDelaySeconds: 30
  periodSeconds: 10

readinessProbe:
  enabled: true
  httpGet:
    path: /ready
    port: http
  initialDelaySeconds: 5
  periodSeconds: 10
```

### Autoscaling

```yaml
autoscaling:
  enabled: true
  minReplicas: 2
  maxReplicas: 10
  targetCPUUtilizationPercentage: 80
```

### Pod Disruption Budget

```yaml
podDisruptionBudget:
  enabled: true
  minAvailable: 1
```

### Security Context

```yaml
securityContext:
  capabilities:
    drop:
      - ALL
  readOnlyRootFilesystem: true
  runAsNonRoot: true
  runAsUser: 1000
```

### Resource Limits

Always set appropriate resource limits based on your application's needs:

```yaml
resources:
  limits:
    cpu: 1000m
    memory: 1Gi
  requests:
    cpu: 500m
    memory: 512Mi
```

## Cloud Deployment

### Amazon EKS

```bash
# Configure kubectl for EKS
aws eks update-kubeconfig --name my-cluster --region us-west-2

# Deploy
helm install my-app ./charts/app-starter -f values-prod.yaml
```

### Google GKE

```bash
# Configure kubectl for GKE
gcloud container clusters get-credentials my-cluster --zone us-central1-a

# Deploy
helm install my-app ./charts/app-starter -f values-prod.yaml
```

### Azure AKS

```bash
# Configure kubectl for AKS
az aks get-credentials --resource-group my-rg --name my-cluster

# Deploy
helm install my-app ./charts/app-starter -f values-prod.yaml
```

## Advanced Usage

### Init Containers

Run setup tasks before your main container:

```yaml
initContainers:
  - name: init-database
    image: busybox:1.35
    command: ['sh', '-c', 'until nslookup database; do echo waiting for database; sleep 2; done']
```

### Sidecar Containers

Run additional containers alongside your app:

```yaml
sidecars:
  - name: log-collector
    image: fluent/fluent-bit:2.0
    volumeMounts:
      - name: varlog
        mountPath: /var/log
```

### Volume Mounts

Mount ConfigMaps, Secrets, or persistent volumes:

```yaml
volumes:
  - name: config
    configMap:
      name: my-config
  - name: data
    persistentVolumeClaim:
      claimName: my-pvc

volumeMounts:
  - name: config
    mountPath: /etc/config
    readOnly: true
  - name: data
    mountPath: /data
```

## Troubleshooting

### Common Issues

**Pods not starting:**
```bash
kubectl describe pod -l app.kubernetes.io/instance=my-app
kubectl logs -l app.kubernetes.io/instance=my-app
```

**Image pull errors:**
```bash
# Verify image exists and is accessible
docker pull <image-name>

# For private registries, create image pull secret
kubectl create secret docker-registry regcred \
  --docker-server=<registry> \
  --docker-username=<username> \
  --docker-password=<password>

# Reference in values.yaml
imagePullSecrets:
  - name: regcred
```

**Service not accessible:**
```bash
# Check service and endpoints
kubectl get svc,endpoints -l app.kubernetes.io/instance=my-app

# Test from within cluster
kubectl run -it --rm debug --image=busybox --restart=Never -- wget -O- http://my-app
```

## Roadmap

### Phase 1: Helm Foundation (Current)
- ✅ Core Helm chart with flexible configuration
- ✅ Support for ConfigMaps, Secrets, Ingress
- ✅ Local development with kind
- ✅ CI/CD pipeline for chart validation
- ✅ Multi-environment support

### Phase 2: Enhanced Features (Q2 2025)
- [ ] Helm chart versioning and release management
- [ ] Advanced networking (NetworkPolicies, Service Mesh)
- [ ] Observability integration (Prometheus, Grafana)
- [ ] Backup and restore capabilities
- [ ] Database operator integration

### Phase 3: Operator Evolution (Q3-Q4 2025)
- [ ] Design CustomResourceDefinitions (CRDs)
- [ ] Implement Go-based Kubernetes Operator
- [ ] Automated day-2 operations
- [ ] Self-healing and auto-remediation
- [ ] Migration tooling from Helm to Operator

### Future Considerations
- [ ] Multi-cluster deployments
- [ ] Policy enforcement (OPA/Gatekeeper)
- [ ] Cost optimization recommendations
- [ ] Security scanning integration
- [ ] Developer self-service portal

## Contributing

Contributions are welcome! This project aims to be a community-driven resource for Kubernetes application deployment.

### How to Contribute

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Make your changes
4. Run the tests (`helm lint ./charts/app-starter`)
5. Commit your changes (`git commit -m 'Add amazing feature'`)
6. Push to the branch (`git push origin feature/amazing-feature`)
7. Open a Pull Request

### Development Guidelines

- Follow Kubernetes best practices
- Maintain backward compatibility
- Add tests for new features
- Update documentation
- Keep changes focused and atomic

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Support

- **Issues**: [GitHub Issues](https://github.com/harleyzhd/KubeEasy/issues)
- **Discussions**: [GitHub Discussions](https://github.com/harleyzhd/KubeEasy/discussions)
- **Documentation**: [Wiki](https://github.com/harleyzhd/KubeEasy/wiki)

## Related Projects

- [Kubernetes Official Charts](https://github.com/kubernetes/charts)
- [Helm](https://helm.sh/)
- [kind](https://kind.sigs.k8s.io/)
- [Operator SDK](https://sdk.operatorframework.io/)
