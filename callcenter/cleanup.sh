#!/bin/bash
set -euo pipefail

# =============================================================================
# Foundry Hackathon — Resource Cleanup Script (Call Center)
# Deletes the resource group and all resources created by deploy.sh
# =============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ENV_FILE="$SCRIPT_DIR/.env"

# Load .env if it exists
if [[ -f "$ENV_FILE" ]]; then
  # shellcheck disable=SC1090
  source "$ENV_FILE"
  echo "Loaded environment from: $ENV_FILE"
else
  echo "Warning: .env file not found at $ENV_FILE"
  echo "Set RESOURCE_GROUP manually, or re-run challenge-0-setup/deploy.sh to write callcenter/.env."
fi

RESOURCE_GROUP="${RESOURCE_GROUP:-}"

if [[ -z "$RESOURCE_GROUP" ]]; then
  echo ""
  echo "Error: RESOURCE_GROUP is not set."
  echo "Usage: RESOURCE_GROUP=foundry-hackathon-rg-<suffix> bash callcenter/cleanup.sh"
  exit 1
fi

echo ""
echo "=============================================="
echo "  Foundry Hackathon — Resource Cleanup"
echo "=============================================="
echo ""
echo "  Resource Group: $RESOURCE_GROUP"
echo ""
echo "  This will permanently delete the resource group and ALL resources inside it:"
echo "    - Microsoft Foundry Resource + project"
echo "    - GPT model deployment"
echo "    - Log Analytics workspace"
echo "    - Application Insights instance"
echo ""
read -r -p "  Are you sure you want to delete '$RESOURCE_GROUP'? (yes/no): " CONFIRM

if [[ "$CONFIRM" != "yes" ]]; then
  echo "Cancelled. No resources were deleted."
  exit 0
fi

echo ""
echo "Deleting resource group '$RESOURCE_GROUP'..."
az group delete --name "$RESOURCE_GROUP" --yes --no-wait

echo ""
echo "=============================================="
echo "  ✅ Deletion initiated"
echo "=============================================="
echo ""
echo "  The resource group is being deleted in the background."
echo "  It may take a few minutes to fully remove all resources."
echo ""
echo "  Verify in the Azure Portal:"
echo "  https://portal.azure.com/#view/HubsExtension/BrowseResourceGroups"
echo ""
