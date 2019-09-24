
function DeployTemplate([string]$pathtotemplate,[string]$pathtoparameters,[string]$location)
{
 $random = Get-Random 
 $resourcegroupname = "rg-" + $random + "-" + ([Datetime]::Now).ToShortDateString().Replace("/","-")
 New-AzResourceGroup -Name $resourcegroupname -Location $location 
 $name = 'AzureTest' + $location + ([Datetime]::Now).ToShortDateString().Replace("/","-")
 $deploymentinfo = New-AzResourceGroupDeployment -Name $name -ResourceGroupName $resourcegroupname -TemplateParameterFile $pathtoparameters -TemplateFile $pathtotemplate 
 return $deploymentinfo
}
function GetRegion
{
    $allregions = Get-AzLocation |select Location
    $max = $allregions.location.count
    $randomindex = Get-Random -Maximum $max -Minimum 0
    return $allregions[$randomindex].Location
}

function GetDeploymentInfo([string]$deploymentname,[string]$resourcegroup,[string]$location)
{
  $results = Get-AzResourceGroupDeploymentOperation -ResourceGroupName $resourcegroup -DeploymentName $deploymentname
  $resultsArray = @()
  foreach($result in $results)
  {
     $obj = New-Object psobject    
     $resource = $result.properties.targetResource.id
     $deployResult = $result.properties.provisioningState
     $deployDuration = $result.properties.duration 


     $obj | Add-Member -MemberType NoteProperty -Name ResourceID -Value $resource
     $obj | Add-Member -MemberType NoteProperty -Name deploymentName -Value $deploymentname
     $obj | Add-Member -MemberType NoteProperty -Name Location -value $location
     $obj | Add-Member -MemberType NoteProperty -Name deployResult -Value $deployResult
     $obj | Add-Member -MemberType NoteProperty -Name deployDuration -Value $deployDuration
     $resultsArray += $obj 
  }
  return $resultsArray
}

### Paths for Templates
$rootpath = $home + "\psdeployment\"
$templateName = $rootpath + "azuredeploy.json"
$templateParameters = $rootpath + "azuredeploy.parameters.json"
###

$location = GetRegion

$info = DeployTemplate $templateName $templateParameters $location

$output = GetDeploymentInfo $info[1].DeploymentName $info[1].ResourceGroupName $info[0].Location
