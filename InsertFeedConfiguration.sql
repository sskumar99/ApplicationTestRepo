/*
Post-Deployment Script Template							
--------------------------------------------------------------------------------------
 This file contains SQL statements that will be appended to the build script.		
 Use SQLCMD syntax to include a file in the post-deployment script.			
 Example:      :r .\myfile.sql								
 Use SQLCMD syntax to reference a variable in the post-deployment script.		
 Example:      :setvar TableName MyTable							
               SELECT * FROM [$(TableName)]					
--------------------------------------------------------------------------------------
*/
;


WITH cte
AS (
	SELECT 1 AS ConfigurationID
		,'PaydexDaily' AS FeedName
		,'PaydexDaily.dtsx' AS SSISPackageName
		,1 AS IsActive
		,'DailyUSA' AS GroupName
		,'1' AS SortOrder
		,'0' AS GroupSortOrder
		,'Aug  6 2015  8:43PM' AS CreatedDate
		,'DR' AS CreatedBy
		,5 as DWConfigurationID
	UNION ALL
	
	SELECT 2 AS ConfigurationID
		,'DnBRatingDaily' AS FeedName
		,'DnBRatingDaily.dtsx' AS SSISPackageName
		,1 AS IsActive
		,'DailyUSA' AS GroupName
		,'2' AS SortOrder
		,'0' AS GroupSortOrder
		,'Aug  6 2015  8:43PM' AS CreatedDate
		,'DR' AS CreatedBy
		,5 as DWConfigurationID
	UNION ALL
	
	SELECT 3 AS ConfigurationID
		,'SASDaily' AS FeedName
		,'SASDaily.dtsx' AS SSISPackageName
		,1 AS IsActive
		,'DailyUSA' AS GroupName
		,'3' AS SortOrder
		,'0' AS GroupSortOrder
		,'Aug 20 2015 10:30PM' AS CreatedDate
		,'MT' AS CreatedBy
		,6 as DWConfigurationID
	UNION ALL
	
	SELECT 4 AS ConfigurationID
		,'PaydexDailyCA' AS FeedName
		,'PaydexDailyCA.dtsx' AS SSISPackageName
		,1 AS IsActive
		,'DailyCA' AS GroupName
		,'1' AS SortOrder
		,'1' AS GroupSortOrder
		,'Aug  6 2015  8:43PM' AS CreatedDate
		,'DR' AS CreatedBy
		,18 as DWConfigurationID
	UNION ALL
	
	SELECT 5 AS ConfigurationID
		,'DnBRatingDailyCA' AS FeedName
		,'DnBRatingDailyCA.dtsx' AS SSISPackageName
		,1 AS IsActive
		,'DailyCA' AS GroupName
		,'2' AS SortOrder
		,'1' AS GroupSortOrder
		,'Aug  6 2015  8:43PM' AS CreatedDate
		,'DR' AS CreatedBy
		,18 as DWConfigurationID
	UNION ALL
	
	SELECT 6 AS ConfigurationID
		,'SASDailyCA' AS FeedName
		,'SASDailyCA.dtsx' AS SSISPackageName
		,1 AS IsActive
		,'DailyCA' AS GroupName
		,'3' AS SortOrder
		,'1' AS GroupSortOrder
		,'Aug 20 2015 10:30PM' AS CreatedDate
		,'DR' AS CreatedBy
		,19 as DWConfigurationID
	UNION ALL
	
	SELECT 7 AS ConfigurationID
		,'PaydexTrendCA' AS FeedName
		,'PaydexTrendCA.dtsx' AS SSISPackageName
		,1 AS IsActive
		,'TrendCA' AS GroupName
		,'1' AS SortOrder
		,'3' AS GroupSortOrder
		,'Aug  6 2015  8:43PM' AS CreatedDate
		,'DR' AS CreatedBy
		,20 as  DWConfigurationID
	UNION ALL
	
	SELECT 8 AS ConfigurationID
		,'CCSTrendCA' AS FeedName
		,'CCSTrendCA.dtsx' AS SSISPackageName
		,1 AS IsActive
		,'TrendCA' AS GroupName
		,'2' AS SortOrder
		,'3' AS GroupSortOrder
		,'Aug  6 2015  8:43PM' AS CreatedDate
		,'DR' AS CreatedBy
		,22 as DWConfigurationID
	UNION ALL
	
	SELECT 9 AS ConfigurationID
		,'FSSTrendCA' AS FeedName
		,'FSSTrendCA.dtsx' AS SSISPackageName
		,1 AS IsActive
		,'TrendCA' AS GroupName
		,'3' AS SortOrder
		,'3' AS GroupSortOrder
		,'Aug  6 2015  8:43PM' AS CreatedDate
		,'DR' AS CreatedBy
		,22 as DWConfigurationID
	UNION ALL
	
	SELECT 10 AS ConfigurationID
		,'PaydexTrend' AS FeedName
		,'PaydexTrend.dtsx' AS SSISPackageName
		,1 AS IsActive
		,'TrendUSA' AS GroupName
		,'1' AS SortOrder
		,'2' AS GroupSortOrder
		,'Aug  6 2015  8:43PM' AS CreatedDate
		,'DR' AS CreatedBy
		,12 as DWConfigurationID
	UNION ALL
	
	SELECT 11 AS ConfigurationID
		,'CCSFSSTrend' AS FeedName
		,'CCSFSSTrend.dtsx' AS SSISPackageName
		,1 AS IsActive
		,'TrendUSA' AS GroupName
		,'2' AS SortOrder
		,'2' AS GroupSortOrder
		,'Aug  6 2015  8:43PM' AS CreatedDate
		,'DR' AS CreatedBy
		,11 as DWConfigurationID
	UNION ALL
	
	SELECT 12 AS ConfigurationID
		,'SubjectFeed' AS FeedName
		,'SubjectFeed.dtsx' AS SSISPackageName
		,1 AS IsActive
		,'DailyUSA' AS GroupName
		,'4' AS SortOrder
		,'0' AS GroupSortOrder
		,'Aug  6 2015  8:43PM' AS CreatedDate
		,'DR' AS CreatedBy
		,35 as DWConfigurationID
	UNION ALL
	
	SELECT 13 AS ConfigurationID
		,'SubjectFeedCA' AS FeedName
		,'SubjectFeedCA.dtsx' AS SSISPackageName
		,1 AS IsActive
		,'DailyCA' AS GroupName
		,'4' AS SortOrder
		,'1' AS GroupSortOrder
		,'Aug  6 2015  8:43PM' AS CreatedDate
		,'DR' AS CreatedBy
		,34 as DWConfigurationID
	UNION ALL
	
	SELECT 14 AS ConfigurationID
		,'SubjectFeedAcxiom' AS FeedName
		,'SubjectFeedAcxiom.dtsx' AS SSISPackageName
		,1 AS IsActive
		,'DailyAcxiom' AS GroupName
		,'5' AS SortOrder
		,'0' AS GroupSortOrder
		,'Aug  6 2015  8:43PM' AS CreatedDate
		,'DR' AS CreatedBy
	,17 as DWConfigurationID
	UNION ALL
	
	SELECT 15 AS ConfigurationID
		,'SubjectFeedDDR' AS FeedName
		,'SubjectFeedDDR.dtsx' AS SSISPackageName
		,1 AS IsActive
		,'DailyDDR' AS GroupName
		,'1' AS SortOrder
		,'4' AS GroupSortOrder
		,'Aug  6 2015  8:43PM' AS CreatedDate
		,'DR' AS CreatedBy
	,32 as DWConfigurationID
	UNION ALL
	
	SELECT 16 AS ConfigurationID
		,'CreditLimitRecDaily' AS FeedName
		,'CreditLimitRecDaily.dtsx' AS SSISPackageName
		,1 AS IsActive
		,'DailyUSA' AS GroupName
		,'4' AS SortOrder
		,'4' AS GroupSortOrder
		,'Aug  6 2015  8:43PM' AS CreatedDate
		,'DR' AS CreatedBy
	,30 as DWConfigurationID
	UNION ALL
	
	SELECT 17 AS ConfigurationID
		,'CorporateLinkage' AS FeedName
		,'CorporateLinkage.dtsx' AS SSISPackageName
		,1 AS IsActive
		,'Daily' AS GroupName
		,3 AS SortOrder
		,0 AS GroupSortOrder
		,GETUTCDATE() AS CreatedDate
		,'Chaitanya' AS CreatedBy
		,21 as DWConfigurationID
	)
INSERT INTO feed.Configuration (
	ConfigurationID
	,FeedName
	,SSISPackageName
	,ISActive
	,GroupName
	,SortOrder
	,GroupSortOrder
	,CreatedDate
	,CreatedBy
	,DWConfigurationID
	)
SELECT ConfigurationID
	,FeedName
	,SSISPackageName
	,ISActive
	,GroupName
	,SortOrder
	,GroupSortOrder
	,CreatedDate
	,CreatedBy
	,DWConfigurationID
FROM cte t
WHERE NOT EXISTS (
		SELECT 1
		FROM feed.Configuration
		WHERE SSISPackageName = t.SSISPackageName
		);