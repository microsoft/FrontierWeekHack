$ErrorActionPreference = 'Stop'
function Get-AzdValue([string] $Name) { $value = azd env get-value $Name 2>$null; if ([string]::IsNullOrWhiteSpace($value)) { throw "azd value '$Name' was not produced." }; return $value.Trim() }
$envFile = Join-Path $PSScriptRoot '..\.env'
@"
AZURE_SUBSCRIPTION_ID=$(Get-AzdValue subscriptionId)
RESOURCE_GROUP=$(Get-AzdValue resourceGroupName)
FOUNDRY_RESOURCE_NAME=$(Get-AzdValue foundryResourceName)
PROJECT_NAME=$(Get-AzdValue projectName)
FOUNDRY_ENDPOINT=$(Get-AzdValue foundryEndpoint)
PROJECT_CONNECTION_STRING=$(Get-AzdValue projectConnectionString)
MODEL_DEPLOYMENT_NAME=$(Get-AzdValue modelDeploymentName)
APPLICATIONINSIGHTS_CONNECTION_STRING=$(Get-AzdValue appInsightsConnectionString)
APPINSIGHTS_INSTRUMENTATION_KEY=$(Get-AzdValue appInsightsInstrumentationKey)
AZURE_EXPERIMENTAL_ENABLE_GENAI_TRACING=true
OTEL_INSTRUMENTATION_GENAI_CAPTURE_MESSAGE_CONTENT=true
"@ | Set-Content -Path $envFile -Encoding utf8NoBOM
Write-Host "Environment file written to $envFile"