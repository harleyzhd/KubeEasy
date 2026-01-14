.PHONY: help lint test template install uninstall kind-create kind-delete kind-load clean

CHART_NAME := app-starter
CHART_PATH := ./charts/$(CHART_NAME)
RELEASE_NAME := test-release
NAMESPACE := default
CLUSTER_NAME := app-starter

help:
	@echo "Kubernetes App Starter Platform - Makefile"
	@echo ""
	@echo "Available targets:"
	@echo "  lint              - Lint the Helm chart"
	@echo "  template          - Render Helm templates"
	@echo "  test              - Run chart tests"
	@echo "  install           - Install the chart to Kubernetes"
	@echo "  uninstall         - Uninstall the chart from Kubernetes"
	@echo "  upgrade           - Upgrade an existing release"
	@echo "  kind-create       - Create a kind cluster"
	@echo "  kind-delete       - Delete the kind cluster"
	@echo "  kind-load IMAGE   - Load a Docker image into kind"
	@echo "  package           - Package the Helm chart"
	@echo "  clean             - Clean up generated files"
	@echo ""
	@echo "Variables:"
	@echo "  RELEASE_NAME      - Helm release name (default: $(RELEASE_NAME))"
	@echo "  NAMESPACE         - Kubernetes namespace (default: $(NAMESPACE))"
	@echo "  VALUES_FILE       - Path to values file (optional)"

lint:
	@echo "Linting Helm chart..."
	helm lint $(CHART_PATH)

template:
	@echo "Rendering Helm templates..."
	@if [ -n "$(VALUES_FILE)" ]; then \
		helm template $(RELEASE_NAME) $(CHART_PATH) -f $(VALUES_FILE); \
	else \
		helm template $(RELEASE_NAME) $(CHART_PATH); \
	fi

test: lint
	@echo "Testing chart rendering..."
	@helm template $(RELEASE_NAME) $(CHART_PATH) > /dev/null
	@echo "Testing with dev values..."
	@helm template $(RELEASE_NAME) $(CHART_PATH) -f examples/values-dev.yaml > /dev/null
	@echo "Testing with staging values..."
	@helm template $(RELEASE_NAME) $(CHART_PATH) -f examples/values-staging.yaml > /dev/null
	@echo "Testing with prod values..."
	@helm template $(RELEASE_NAME) $(CHART_PATH) -f examples/values-prod.yaml > /dev/null
	@echo "All tests passed!"

install:
	@echo "Installing chart $(CHART_NAME)..."
	@if [ -n "$(VALUES_FILE)" ]; then \
		helm install $(RELEASE_NAME) $(CHART_PATH) -n $(NAMESPACE) -f $(VALUES_FILE) --create-namespace; \
	else \
		helm install $(RELEASE_NAME) $(CHART_PATH) -n $(NAMESPACE) --create-namespace; \
	fi

uninstall:
	@echo "Uninstalling release $(RELEASE_NAME)..."
	helm uninstall $(RELEASE_NAME) -n $(NAMESPACE)

upgrade:
	@echo "Upgrading release $(RELEASE_NAME)..."
	@if [ -n "$(VALUES_FILE)" ]; then \
		helm upgrade $(RELEASE_NAME) $(CHART_PATH) -n $(NAMESPACE) -f $(VALUES_FILE); \
	else \
		helm upgrade $(RELEASE_NAME) $(CHART_PATH) -n $(NAMESPACE); \
	fi

kind-create:
	@echo "Creating kind cluster..."
	./scripts/create-kind-cluster.sh

kind-delete:
	@echo "Deleting kind cluster..."
	kind delete cluster --name $(CLUSTER_NAME)

kind-load:
	@if [ -z "$(IMAGE)" ]; then \
		echo "Error: IMAGE variable is required"; \
		echo "Usage: make kind-load IMAGE=my-image:tag"; \
		exit 1; \
	fi
	@echo "Loading image $(IMAGE) into kind..."
	./scripts/load-image-kind.sh $(IMAGE) $(CLUSTER_NAME)

package:
	@echo "Packaging Helm chart..."
	helm package $(CHART_PATH)

clean:
	@echo "Cleaning up..."
	rm -f *.tgz
	@echo "Done!"

# Quick development workflow
dev-install: kind-create install
	@echo "Development environment ready!"
	@echo "To access your app, run: kubectl port-forward svc/$(RELEASE_NAME)-$(CHART_NAME) 8080:80"

dev-clean: uninstall kind-delete
	@echo "Development environment cleaned up!"
