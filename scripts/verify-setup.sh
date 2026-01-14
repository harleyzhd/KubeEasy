#!/usr/bin/env bash
#
# verify-setup.sh
# Verifies that the Kubernetes App Starter Platform is correctly set up
#

set -e

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo "Kubernetes App Starter Platform - Setup Verification"
echo "======================================================"
echo ""

# Function to check command exists
check_command() {
    if command -v "$1" &> /dev/null; then
        echo -e "${GREEN}✓${NC} $1 is installed"
        if [ -n "$2" ]; then
            echo "  Version: $($2 2>&1)"
        fi
        return 0
    else
        echo -e "${RED}✗${NC} $1 is not installed"
        return 1
    fi
}

# Function to check file exists
check_file() {
    if [ -f "$1" ]; then
        echo -e "${GREEN}✓${NC} $1 exists"
        return 0
    else
        echo -e "${RED}✗${NC} $1 is missing"
        return 1
    fi
}

# Function to check directory exists
check_dir() {
    if [ -d "$1" ]; then
        echo -e "${GREEN}✓${NC} $1/ exists"
        return 0
    else
        echo -e "${RED}✗${NC} $1/ is missing"
        return 1
    fi
}

ERRORS=0

echo "Checking Prerequisites..."
echo "-------------------------"

check_command "docker" "docker --version" || ERRORS=$((ERRORS+1))
check_command "kubectl" "kubectl version --client --short" || ERRORS=$((ERRORS+1))
check_command "helm" "helm version --short" || ERRORS=$((ERRORS+1))
check_command "kind" "kind version" || ERRORS=$((ERRORS+1))

echo ""
echo "Checking Repository Structure..."
echo "--------------------------------"

check_dir "charts" || ERRORS=$((ERRORS+1))
check_dir "charts/app-starter" || ERRORS=$((ERRORS+1))
check_dir "charts/app-starter/templates" || ERRORS=$((ERRORS+1))
check_dir "examples" || ERRORS=$((ERRORS+1))
check_dir "kind" || ERRORS=$((ERRORS+1))
check_dir "scripts" || ERRORS=$((ERRORS+1))
check_dir ".github/workflows" || ERRORS=$((ERRORS+1))

echo ""
echo "Checking Core Files..."
echo "----------------------"

check_file "README.md" || ERRORS=$((ERRORS+1))
check_file "LICENSE" || ERRORS=$((ERRORS+1))
check_file "Makefile" || ERRORS=$((ERRORS+1))
check_file "charts/app-starter/Chart.yaml" || ERRORS=$((ERRORS+1))
check_file "charts/app-starter/values.yaml" || ERRORS=$((ERRORS+1))

echo ""
echo "Checking Templates..."
echo "---------------------"

check_file "charts/app-starter/templates/deployment.yaml" || ERRORS=$((ERRORS+1))
check_file "charts/app-starter/templates/service.yaml" || ERRORS=$((ERRORS+1))
check_file "charts/app-starter/templates/ingress.yaml" || ERRORS=$((ERRORS+1))
check_file "charts/app-starter/templates/configmap.yaml" || ERRORS=$((ERRORS+1))
check_file "charts/app-starter/templates/secret.yaml" || ERRORS=$((ERRORS+1))
check_file "charts/app-starter/templates/serviceaccount.yaml" || ERRORS=$((ERRORS+1))
check_file "charts/app-starter/templates/hpa.yaml" || ERRORS=$((ERRORS+1))
check_file "charts/app-starter/templates/_helpers.tpl" || ERRORS=$((ERRORS+1))

echo ""
echo "Checking Example Files..."
echo "-------------------------"

check_file "examples/values-dev.yaml" || ERRORS=$((ERRORS+1))
check_file "examples/values-staging.yaml" || ERRORS=$((ERRORS+1))
check_file "examples/values-prod.yaml" || ERRORS=$((ERRORS+1))

echo ""
echo "Validating Helm Chart..."
echo "------------------------"

if helm lint charts/app-starter &> /dev/null; then
    echo -e "${GREEN}✓${NC} Helm chart passes lint"
else
    echo -e "${RED}✗${NC} Helm chart has lint errors"
    ERRORS=$((ERRORS+1))
fi

if helm template test-release charts/app-starter &> /dev/null; then
    echo -e "${GREEN}✓${NC} Helm chart templates render successfully"
else
    echo -e "${RED}✗${NC} Helm chart has template errors"
    ERRORS=$((ERRORS+1))
fi

echo ""
echo "Checking Scripts..."
echo "-------------------"

if [ -x "scripts/create-kind-cluster.sh" ] || [ -f "scripts/create-kind-cluster.sh" ]; then
    echo -e "${GREEN}✓${NC} create-kind-cluster.sh exists"
else
    echo -e "${RED}✗${NC} create-kind-cluster.sh is missing or not executable"
    ERRORS=$((ERRORS+1))
fi

if [ -x "scripts/load-image-kind.sh" ] || [ -f "scripts/load-image-kind.sh" ]; then
    echo -e "${GREEN}✓${NC} load-image-kind.sh exists"
else
    echo -e "${RED}✗${NC} load-image-kind.sh is missing or not executable"
    ERRORS=$((ERRORS+1))
fi

echo ""
echo "======================================================"

if [ $ERRORS -eq 0 ]; then
    echo -e "${GREEN}✓ All checks passed! Repository is ready to use.${NC}"
    echo ""
    echo "Next steps:"
    echo "  1. Review and customize values files"
    echo "  2. Create a kind cluster: make kind-create"
    echo "  3. Install the chart: make install"
    echo "  4. Initialize git: git init && git add . && git commit -m 'Initial commit'"
    exit 0
else
    echo -e "${RED}✗ Found $ERRORS error(s). Please fix them before proceeding.${NC}"
    exit 1
fi
