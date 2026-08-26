@description('Azure region for the lab resources.')
param location string = 'swedencentral'

@description('Unique suffix used in globally unique resource names.')
param suffix string = take(uniqueString(resourceGroup().id), 8)

param foundryResourceName string = 'foundry-hack-${suffix}'
param projectName string = 'callcenter-project'
param modelDeploymentName string = 'gpt-5.4'
param modelName string = 'gpt-5.4'
param modelVersion string = '2026-03-05'
param logAnalyticsName string = 'foundry-hack-logs-${suffix}'
param appInsightsName string = 'foundry-hack-insights-${suffix}'
param tags object = {
  environment: 'hack'
}

resource foundry 'Microsoft.CognitiveServices/accounts@2025-06-01' = {
  name: foundryResourceName
  location: location
  kind: 'AIServices'
  sku: { name: 'S0' }
  identity: { type: 'SystemAssigned' }
  properties: {
    customSubDomainName: foundryResourceName
    allowProjectManagement: true
    disableLocalAuth: false
    publicNetworkAccess: 'Enabled'
  }
}

resource project 'Microsoft.CognitiveServices/accounts/projects@2025-06-01' = {
  parent: foundry
  name: projectName
  location: location
  identity: { type: 'SystemAssigned' }
  properties: { displayName: projectName }
}

resource modelDeployment 'Microsoft.CognitiveServices/accounts/deployments@2025-06-01' = {
  parent: foundry
  name: modelDeploymentName
  sku: {
    name: 'GlobalStandard'
    capacity: 10
  }
  properties: {
    model: {
      format: 'OpenAI'
      name: modelName
      version: modelVersion
    }
  }
  dependsOn: [project]
}

resource logAnalytics 'Microsoft.OperationalInsights/workspaces@2023-09-01' = {
  name: logAnalyticsName
  location: location
  tags: tags
  properties: { retentionInDays: 30 }
}

resource appInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: appInsightsName
  location: location
  kind: 'web'
  tags: tags
  properties: {
    Application_Type: 'web'
    WorkspaceResourceId: logAnalytics.id
  }
}

resource appInsightsConnection 'Microsoft.CognitiveServices/accounts/connections@2025-06-01' = {
  parent: foundry
  name: 'appinsights-conn'
  properties: {
    category: 'AppInsights'
    target: appInsights.id
    authType: 'ApiKey'
    credentials: { key: appInsights.properties.ConnectionString }
    isSharedToAll: true
    metadata: {
      ApiType: 'Azure'
      ResourceId: appInsights.id
    }
  }
}

output subscriptionId string = subscription().id
output resourceGroupName string = resourceGroup().name
output foundryResourceName string = foundry.name
output projectName string = project.name
output foundryEndpoint string = foundry.properties.endpoint
output projectConnectionString string = 'https://${foundry.name}.services.ai.azure.com/api/projects/${project.name}'
output modelDeploymentName string = modelDeployment.name
output appInsightsConnectionString string = appInsights.properties.ConnectionString
output appInsightsInstrumentationKey string = appInsights.properties.InstrumentationKey