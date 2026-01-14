# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.1.0] - 2025-01-04

### Added
- Initial release of Kubernetes App Starter Platform
- Core Helm chart (`app-starter`) with comprehensive configuration options
- Support for arbitrary container image deployment
- Configurable resources (CPU, memory limits/requests)
- Environment variable injection via `env` values
- ConfigMap and Secret management
- Service configuration (ClusterIP, NodePort, LoadBalancer)
- Optional Ingress with TLS support
- ServiceAccount creation
- Horizontal Pod Autoscaler (HPA) support
- PodDisruptionBudget support
- Health probes (liveness, readiness, startup)
- Init container and sidecar support
- Volume and volume mount configuration
- Rolling update strategy configuration
- Node selector, tolerations, and affinity support
- kind cluster configuration for local development
- Helper scripts:
  - `create-kind-cluster.sh` - Sets up local Kubernetes cluster
  - `load-image-kind.sh` - Loads Docker images into kind
- Environment-specific values files:
  - `values-dev.yaml` - Development configuration
  - `values-staging.yaml` - Staging configuration
  - `values-prod.yaml` - Production configuration
- GitHub Actions CI pipeline for chart linting and testing
- Comprehensive documentation in README.md
- Contributing guidelines
- MIT License

### Features
- Production-ready defaults with full customization
- Multi-environment support
- Security context configuration ready for non-root containers
- Extensible design for future Operator migration
- Well-commented templates and values

### Documentation
- Quick start guide
- Local development instructions
- Cloud deployment examples (EKS, GKE, AKS)
- Configuration reference
- Troubleshooting guide
- Roadmap for future development

[Unreleased]: https://github.com/yourusername/k8s-app-starter/compare/v0.1.0...HEAD
[0.1.0]: https://github.com/yourusername/k8s-app-starter/releases/tag/v0.1.0
