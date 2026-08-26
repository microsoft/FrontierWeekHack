$ErrorActionPreference = 'Stop'

function Get-AzdValue([string] $Name) {
    $value = azd env get-value $Name 2>$null
    if ([string]::IsNullOrWhiteSpace($value)) { throw "azd value '$Name' was not produced." }
    return $value.Trim()
}

$subscriptionId = Get-AzdValue 'subscriptionId'
$resourceGroupName = Get-AzdValue 'resourceGroupName'
$foundryResourceName = Get-AzdValue 'foundryResourceName'
$projectName = Get-AzdValue 'projectName'
$foundryEndpoint = Get-AzdValue 'foundryEndpoint'
$projectConnectionString = Get-AzdValue 'projectConnectionString'
$modelDeploymentName = Get-AzdValue 'modelDeploymentName'
$appInsightsConnectionString = Get-AzdValue 'appInsightsConnectionString'
$appInsightsInstrumentationKey = Get-AzdValue 'appInsightsInstrumentationKey'
$envFile = Join-Path $PSScriptRoot '..\.env'

@"
AZURE_SUBSCRIPTION_ID=$subscriptionId
RESOURCE_GROUP=$resourceGroupName
FOUNDRY_RESOURCE_NAME=$foundryResourceName
PROJECT_NAME=$projectName
FOUNDRY_ENDPOINT=$foundryEndpoint
PROJECT_CONNECTION_STRING=$projectConnectionString
MODEL_DEPLOYMENT_NAME=$modelDeploymentName
APPLICATIONINSIGHTS_CONNECTION_STRING=$appInsightsConnectionString
APPINSIGHTS_INSTRUMENTATION_KEY=$appInsightsInstrumentationKey
AZURE_EXPERIMENTAL_ENABLE_GENAI_TRACING=true
OTEL_INSTRUMENTATION_GENAI_CAPTURE_MESSAGE_CONTENT=true
"@ | Set-Content -Path $envFile -Encoding utf8NoBOM

Write-Host "Environment file written to $envFile"