param([string]$SourcePath, [string]$BinariesPath)
[xml]$PropertiesFile = Get-Content $SourcePath"\TFSBuild\BuildProperties.XML"
$ServerName = $PropertiesFile.Project.BuildProperty.ServerName_STG
<#
try 
{
	invoke-sqlcmd -ServerInstance $ServerName -inputFile $SourcePath"\TFSBuild\PostDeployment\CIR-8626-0002-InsertSampleValues-ScotsCodeValues.sql"  -QueryTimeout 65535 -ErrorAction Stop
} 
catch 
{
	Write-Host($error)
	Write-Host("CIR-8626-0002-InsertSampleValues-ScotsCodeValues.sql")
	exit 1
}
#>

