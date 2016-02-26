param([string]$SourcePath, [string]$BinariesPath)
[xml]$PropertiesFile = Get-Content $SourcePath"\TFSBuild\BuildProperties.XML"
$ServerName = $PropertiesFile.Project.BuildProperty.ServerName_STG

<#
try 
{
	invoke-sqlcmd -ServerInstance $ServerName -inputFile $SourcePath"\TFSBuild\PreDeployment\CIR_8816_table_dataflow_feedbookmark.sql"  -QueryTimeout 65535 -ErrorAction Stop
} 
catch 
{
	Write-Host($error)
	Write-Host("CIR_8816_table_dataflow_feedbookmark.sql")
	exit 1
}
#>

