param([string]$SourcePath, [string]$DropLocation)
[xml]$PropertiesFile = Get-Content $SourcePath"\TFSBuild\BuildProperties.XML"
$DatabaseName = $PropertiesFile.Project.BuildProperty.DatabaseName
$RollbackFileName = $SourcePath + "\" + $DatabaseName + ".Rollback.snp"
Copy-Item $RollbackFileName $DropLocation