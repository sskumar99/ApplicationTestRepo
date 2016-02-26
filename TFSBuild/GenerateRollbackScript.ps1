param([string]$SourcePath, [string]$DropLocation, [string]$ServerType)
[xml]$PropertiesFile = Get-Content $SourcePath"\TFSBuild\BuildProperties.XML"

Write-Host($SourcePath)
$DatabaseName = $PropertiesFile.Project.BuildProperty.DatabaseName

If ($ServerType -Match "QA") 
{
	$ServerName = $PropertiesFile.Project.BuildProperty.ServerName_QA
}
ElseIf ($ServerType -Match "STG")
{
	$ServerName = $PropertiesFile.Project.BuildProperty.ServerName_STG
}
ElseIf ($ServerType -Match "PROD")
{
	$ServerName = $PropertiesFile.Project.BuildProperty.ServerName_PROD
}

$Path=$SourcePath
$Command = '&"C:\Program Files (x86)\Red Gate\SQL Compare 11\sqlcompare.exe" /Server1:' + $ServerName + ' /database1:"' + $DatabaseName + '" /makesnapshot:"' + $Path + '\' + $DatabaseName + '.Rollback' + '.snp" /force'   
Write-Host($Command)
Invoke-Expression $Command
Start-Sleep -s 15
