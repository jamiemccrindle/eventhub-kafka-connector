  
@minLength(5)
@maxLength(50)
@description('Specifies the name of the azure container registry.')
param acrName string

@description('Enable admin user that have push / pull permission to the registry.')
param acrAdminUserEnabled bool = false

@description('The owner of this ACR.')
param ownerPrincipalId string

@description('Specifies the Azure location where the acr should be created.')
param location string = resourceGroup().location

@allowed([
  'Basic'
  'Standard'
  'Premium'
])
@description('Tier of your Azure Container Registry.')
param acrSku string = 'Premium'

// azure container registry
resource acr 'Microsoft.ContainerRegistry/registries@2019-12-01-preview' = {
  name: acrName
  location: location
  sku: {
    name: acrSku
  }
  properties: {
    adminUserEnabled: acrAdminUserEnabled
  }
}

// assign an owner role to the ACR
resource ownerRoleAssignment 'Microsoft.Authorization/roleAssignments@2018-01-01-preview' = {
  name: guid('${acr.id}/${ownerPrincipalId}/owner')
  scope: acr
  properties: {
    roleDefinitionId: '/subscriptions/${subscription().subscriptionId}/providers/Microsoft.Authorization/roleDefinitions/8e3af657-a8ff-443c-a75c-2fe8c4bcb635'
    principalId: ownerPrincipalId
  }
}

output acrLoginServer string = acr.properties.loginServer
output acrName string = acrName
