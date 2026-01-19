#!/bin/bash

# Azure OpenAI Plugin - Deployment Script
# This script creates Azure resources, builds the application, and deploys it to Azure App Service
# Prerequisites: Azure CLI installed and logged in (az login)

set -e  # Exit on error

# ============================================
# CONFIGURATION VARIABLES
# ============================================
# Modify these variables according to your Azure setup

RESOURCE_GROUP="MoneyShop"
LOCATION="East US"
APP_SERVICE_PLAN_NAME="moneyshop-plan"
APP_SERVICE_NAME="moneyshop-app"
RUNTIME="DOTNET|6.0"
SKU="B1"  # Basic tier - change to F1 for free tier

# Azure OpenAI Configuration
AZURE_OPENAI_ENDPOINT="https://openaimoneyshop.openai.azure.com"
AZURE_OPENAI_API_KEY=""  # Will be prompted if empty
AZURE_OPENAI_DEPLOYMENT_NAME="gpt-4o-mini"
AZURE_OPENAI_API_VERSION="2024-02-15-preview"

# ============================================
# HELPER FUNCTIONS
# ============================================

print_header() {
    echo ""
    echo "=========================================="
    echo "$1"
    echo "=========================================="
    echo ""
}

print_success() {
    echo "✅ $1"
}

print_error() {
    echo "❌ $1" >&2
}

print_info() {
    echo "ℹ️  $1"
}

# ============================================
# PREREQUISITES CHECK
# ============================================

print_header "Checking Prerequisites"

# Check if Azure CLI is installed
if ! command -v az &> /dev/null; then
    print_error "Azure CLI is not installed. Please install it from https://aka.ms/installazurecliwindows"
    exit 1
fi
print_success "Azure CLI is installed"

# Check if logged in to Azure
if ! az account show &> /dev/null; then
    print_info "Not logged in to Azure. Logging in..."
    az login
fi
print_success "Logged in to Azure"

# Check if .NET SDK is installed
if ! command -v dotnet &> /dev/null; then
    print_error ".NET SDK is not installed. Please install it from https://dotnet.microsoft.com/download"
    exit 1
fi
print_success ".NET SDK is installed"

# ============================================
# PROMPT FOR AZURE OPENAI API KEY
# ============================================

if [ -z "$AZURE_OPENAI_API_KEY" ]; then
    echo ""
    read -sp "Enter Azure OpenAI API Key: " AZURE_OPENAI_API_KEY
    echo ""
    if [ -z "$AZURE_OPENAI_API_KEY" ]; then
        print_error "API Key is required"
        exit 1
    fi
fi

# ============================================
# CREATE RESOURCE GROUP
# ============================================

print_header "Creating Resource Group"

if az group show --name "$RESOURCE_GROUP" &> /dev/null; then
    print_info "Resource group '$RESOURCE_GROUP' already exists"
else
    az group create \
        --name "$RESOURCE_GROUP" \
        --location "$LOCATION" \
        --output none
    print_success "Resource group '$RESOURCE_GROUP' created"
fi

# ============================================
# CREATE APP SERVICE PLAN
# ============================================

print_header "Creating App Service Plan"

if az appservice plan show --name "$APP_SERVICE_PLAN_NAME" --resource-group "$RESOURCE_GROUP" &> /dev/null; then
    print_info "App Service Plan '$APP_SERVICE_PLAN_NAME' already exists"
else
    az appservice plan create \
        --name "$APP_SERVICE_PLAN_NAME" \
        --resource-group "$RESOURCE_GROUP" \
        --location "$LOCATION" \
        --sku "$SKU" \
        --is-linux \
        --output none
    print_success "App Service Plan '$APP_SERVICE_PLAN_NAME' created"
fi

# ============================================
# CREATE APP SERVICE
# ============================================

print_header "Creating App Service"

if az webapp show --name "$APP_SERVICE_NAME" --resource-group "$RESOURCE_GROUP" &> /dev/null; then
    print_info "App Service '$APP_SERVICE_NAME' already exists"
else
    az webapp create \
        --name "$APP_SERVICE_NAME" \
        --resource-group "$RESOURCE_GROUP" \
        --plan "$APP_SERVICE_PLAN_NAME" \
        --runtime "$RUNTIME" \
        --output none
    print_success "App Service '$APP_SERVICE_NAME' created"
fi

# ============================================
# CONFIGURE APP SETTINGS
# ============================================

print_header "Configuring App Settings"

az webapp config appsettings set \
    --name "$APP_SERVICE_NAME" \
    --resource-group "$RESOURCE_GROUP" \
    --settings \
        AzureOpenAI__Endpoint="$AZURE_OPENAI_ENDPOINT" \
        AzureOpenAI__ApiKey="$AZURE_OPENAI_API_KEY" \
        AzureOpenAI__DeploymentName="$AZURE_OPENAI_DEPLOYMENT_NAME" \
        AzureOpenAI__ApiVersion="$AZURE_OPENAI_API_VERSION" \
    --output none

print_success "App Settings configured"

# ============================================
# BUILD APPLICATION
# ============================================

print_header "Building Application"

# Navigate to HW4 directory (where the project files are)
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$SCRIPT_DIR" || exit 1

# Clean previous builds
if [ -d "publish" ]; then
    rm -rf publish
fi

# Build and publish
print_info "Running dotnet publish..."
dotnet publish MoneyShop/MoneyShop.csproj -c Release -o ./publish

if [ $? -ne 0 ]; then
    print_error "Build failed"
    exit 1
fi

print_success "Application built successfully"

# ============================================
# CREATE DEPLOYMENT PACKAGE
# ============================================

print_header "Creating Deployment Package"

cd publish || exit 1

# Create ZIP file
if [ -f "../publish.zip" ]; then
    rm ../publish.zip
fi

zip -r ../publish.zip . > /dev/null

cd "$SCRIPT_DIR" || exit 1

print_success "Deployment package created: publish.zip"

# ============================================
# DEPLOY APPLICATION
# ============================================

print_header "Deploying Application to Azure"

az webapp deployment source config-zip \
    --resource-group "$RESOURCE_GROUP" \
    --name "$APP_SERVICE_NAME" \
    --src publish.zip \
    --output none

if [ $? -ne 0 ]; then
    print_error "Deployment failed"
    exit 1
fi

print_success "Application deployed successfully"

# ============================================
# GET APPLICATION URL
# ============================================

print_header "Deployment Complete"

APP_URL=$(az webapp show \
    --name "$APP_SERVICE_NAME" \
    --resource-group "$RESOURCE_GROUP" \
    --query "defaultHostName" \
    --output tsv)

echo ""
echo "=========================================="
print_success "DEPLOYMENT COMPLETE!"
echo "=========================================="
echo ""
echo "Application URL: https://$APP_URL"
echo ""
echo "API Endpoints:"
echo "  - GET  https://$APP_URL/api/openai-plugin/info"
echo "  - POST https://$APP_URL/api/openai-plugin/prompt"
echo ""
echo "Web Interface:"
echo "  - https://$APP_URL/openai-plugin"
echo ""
echo "Next Steps:"
echo "  1. Wait 1-2 minutes for the application to start"
echo "  2. Test the API endpoints"
echo "  3. Access the web interface for easy testing"
echo ""
print_info "Note: The application may take a few moments to fully start"
echo ""

