# Contributing to Kubernetes App Starter Platform

Thank you for considering contributing to this project! We welcome contributions from everyone.

## How Can I Contribute?

### Reporting Bugs

Before creating bug reports, please check existing issues to avoid duplicates. When creating a bug report, include:

- A clear and descriptive title
- Steps to reproduce the issue
- Expected behavior
- Actual behavior
- Environment details (Kubernetes version, Helm version, cloud provider)
- Relevant logs or error messages

### Suggesting Enhancements

Enhancement suggestions are tracked as GitHub issues. When creating an enhancement suggestion, include:

- A clear and descriptive title
- Detailed description of the proposed functionality
- Why this enhancement would be useful
- Examples of how it would be used

### Pull Requests

1. Fork the repository
2. Create a new branch from `main`:
   ```bash
   git checkout -b feature/your-feature-name
   ```
3. Make your changes
4. Test your changes:
   ```bash
   # Lint the chart
   helm lint ./charts/app-starter

   # Test rendering templates
   helm template test-release ./charts/app-starter

   # Test installation (if possible)
   kind create cluster --name test
   helm install test-release ./charts/app-starter
   helm uninstall test-release
   kind delete cluster --name test
   ```
5. Commit your changes with clear commit messages
6. Push to your fork
7. Open a Pull Request

## Development Guidelines

### Helm Chart Development

- Follow [Helm best practices](https://helm.sh/docs/chart_best_practices/)
- Use meaningful variable names in `values.yaml`
- Add comments to explain non-obvious configurations
- Keep templates readable with proper indentation
- Use helper functions for repeated logic
- Test with multiple value configurations

### Code Style

- Use 2 spaces for indentation in YAML files
- Use descriptive names for all Kubernetes resources
- Add comments for complex logic
- Keep lines under 120 characters when possible

### Documentation

- Update README.md for user-facing changes
- Add inline comments for complex template logic
- Update example values files if adding new features
- Include usage examples for new features

### Testing

Before submitting a PR, ensure:

- [ ] Helm chart lints successfully (`helm lint`)
- [ ] Templates render without errors (`helm template`)
- [ ] Chart installs successfully in a test cluster
- [ ] All example values files work correctly
- [ ] Documentation is updated
- [ ] Commit messages are clear and descriptive

### Commit Messages

- Use the present tense ("Add feature" not "Added feature")
- Use the imperative mood ("Move file to..." not "Moves file to...")
- Limit the first line to 72 characters or less
- Reference issues and pull requests after the first line

Examples:
```
Add support for custom annotations on pods

- Allow users to specify custom annotations via values.yaml
- Update documentation with examples
- Add tests for annotation rendering

Fixes #123
```

## Project Structure

```
k8s-app-starter/
├── charts/
│   └── app-starter/          # Main Helm chart
│       ├── Chart.yaml        # Chart metadata
│       ├── values.yaml       # Default values
│       └── templates/        # Kubernetes manifests
├── examples/                 # Example values files
├── kind/                     # Local cluster configs
├── scripts/                  # Helper scripts
└── .github/workflows/        # CI/CD pipelines
```

## Release Process

Maintainers follow this process for releases:

1. Update `version` in `Chart.yaml`
2. Update `CHANGELOG.md`
3. Create a git tag: `git tag -a v0.1.0 -m "Release v0.1.0"`
4. Push the tag: `git push origin v0.1.0`
5. GitHub Actions will create a release

## Questions?

Feel free to open an issue with the `question` label or start a discussion in GitHub Discussions.

## Code of Conduct

This project follows a code of conduct. By participating, you are expected to uphold this code. Please report unacceptable behavior to the project maintainers.

## License

By contributing, you agree that your contributions will be licensed under the MIT License.
