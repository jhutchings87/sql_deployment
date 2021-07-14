##Writing this for when I need to deploy to anything because Im lazy and dont want to run this shit manually everytime!
##The paths 
#Import-Module dbatools

#This section asks for the server you want to connect to



$SqlInstance = Read-Host "Which server do you want to deploy to? 1 for RW 2 for Discovery"


Switch($SqlInstance)
{

1{
$SqlInstance = 'DWReadWriteServerTest'
}
2{$SqlInstance = 'DWDiscovery'
} 
}

$ChangeNum = Read-Host "Please enter the change # for the ticket you are implementing"
Write-Host "Checking for approvals.."

$Status = Invoke-DbaQuery -SqlInstance $SqlInstance -Query "
USE SRC
SELECT Status
FROM Cherwell.Change
WHERE ChangeID = $ChangeNum" | Select-Object -ExpandProperty Status

If($Status -ne 'Reviewed and Approved')
{Write-Warning "This change has not been fully approved yet. Please check the ticket before deploying!"}
else{Write-Host -ForegroundColor Green "Change ticket is approved. Continuing..."}


$Path = 'C:\Temp\Deployments\*.sql'
foreach($p in $path)
{
Write-Host "Looking in $Path for SQL files" 

$FilesToDeploy = Get-ChildItem $Path | Out-GridView -OutputMode Multiple

Write-Host -ForegroundColor Green "$FilesToDeploy selected as deployable.." 

Write-Host -ForegroundColor Green "Running query checks..." 

#This only checks for USE statement at the top of the query.
$FilesToDeploy = Get-Content $FilesToDeploy -First 1
foreach ($line in $FilesToDeploy) {
if ($line -like "*USE*") 
{
Write-Host -ForegroundColor Green "Found USE statement in query successfully..."}
else{Write-Warning "No use statement in query!"
        }
}



#This actually parses the query against SQL server but doesnt actually run it. 

$Results = Get-ChildItem -Path $Path | C:\Temp\Deployments\Test-SQLScripts.ps1 | Select-Object -ExpandProperty HasParseErrors
If($Results -ccontains 'True'){Write-Warning "Parse errors identified"}



$Deploy = Read-Host "Do you want to deploy these files now? 1 for Yes 2 for No"

    if($Deploy -eq 1){

    Write-Host "Deploying $FilesToDeploy to $SqlInstance"

    Invoke-DbaQuery -SqlInstance $SqlInstance -File $FilesToDeploy 
    
    }
 
    else {Write-Host "Exiting Script..."}



}









