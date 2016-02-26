--=========================================
-- Author:		DR
-- Create date: 9-29-2015
-- Description:	Sends a service broker message with latest FSS score trends to CirrusOnline
-- =============================================
CREATE PROCEDURE [dataflow].[SendFinancialsToCirrusOnline]

AS
BEGIN
	SET NOCOUNT ON;
	SET XACT_ABORT ON;
	DECLARE 
			@InitDlgHandle			uniqueidentifier,
			@RequestMsg				nvarchar(100),
			@FinancialsXml			xml;


	DELETE 
			bfq
	FROM
			dataflow.BusinessFinancialQueue bfq
	WHERE
			NOT EXISTS (
						SELECT
								1
						FROM
								dataflow.CirrusOnlineBusiness 
						WHERE
								BusinessID = bfq.BusinessID);

	IF NOT EXISTS(
				SELECT 
						1
				FROM
						dataflow.BusinessFinancialQueue	)
		return;


	CREATE TABLE 
			#tblBusinessToProcess (
					BusinessID	bigint,
					DataSource	varchar(6));



	
	IF EXISTS(SELECT 1 FROM dataflow.BusinessFinancialQueue)
		BEGIN
			


			WHILE 1=1
				BEGIN
		

					IF NOT EXISTS(SELECT 1 FROM dataflow.BusinessFinancialQueue)
						BREAK;

					BEGIN TRANSACTION


					DELETE TOP (50000)
					FROM 
							dataflow.BusinessFinancialQueue
					OUTPUT 
							deleted.BusinessID,
							deleted.DataSource
					INTO #tblBusinessToProcess;


					BEGIN DIALOG @InitDlgHandle
						FROM SERVICE [DataFlowUniverseService]
						TO SERVICE N'DataFlowOnlineService'
					 ON CONTRACT [DataFlowContract]
					 WITH
						 ENCRYPTION = OFF;

		
					SET @FinancialsXml	= (
					SELECT
							ID,
							DN,
							CN,
							DS,
							SD,
							ST,
							STC,
							IPC,
							CCE,
							AR,
							TCA,
							NTA,
							I,
							NFA,
							TA,
							AP,
							TCL,
							TL,
							NW,
							IA,
							BD,
							IC,
							ICCC,
							TNW,
							GW,
							CC,
							SR,
							GP,
							EBIT,
							IE,
							EBT,
							OI,
							NI,
							CS,
							NL,
							NP,
							TOI,
							RD,
							SGA,
							NR,
							OOE,
							NDA,
							CFFA,
							CFIA,
							CCCE,
							CFOA,
							CE,
							TSO,
							ANS
					FROM	(
							SELECT
									cob.BusinessID																AS 'ID',
									cob.DunsNumber																AS 'DN',
									cob.ISOCountryAlpha2Code													AS 'CN',
									f.DataSource																AS 'DS',
									f.StatementDate																AS 'SD',
									f.StatementType																AS 'ST',
									f.StatementTypeCode															AS 'STC',
									ISNULL(CAST(f.IsPublicCompany AS varchar(25)),'-1')							AS 'IPC',
									ISNULL(CAST(f.CashAndCashEquivalents AS varchar(25)),'-1')					AS 'CCE',
									ISNULL(CAST(f.AccountsReceivables AS varchar(25)),'-1')						AS 'AR',
									ISNULL(CAST(f.TotalCurrentAssets AS varchar(25)),'-1')						AS 'TCA',
									ISNULL(CAST(f.NetTangibleAssets AS varchar(25)),'-1')						AS 'NTA',
									ISNULL(CAST(f.Inventory AS varchar(25)),'-1')								AS 'I',
									ISNULL(CAST(f.NetFixedAssets AS varchar(25)),'-1')							AS 'NFA',
									ISNULL(CAST(f.TotalAssets AS varchar(25)),'-1')								AS 'TA',
									ISNULL(CAST(f.AccountsPayable AS varchar(25)),'-1')							AS 'AP',
									ISNULL(CAST(f.TotalCurrentLiabilities AS varchar(25)),'-1')					AS 'TCL',
									ISNULL(CAST(f.TotalLiabilities AS varchar(25)),'-1')						AS 'TL',
									ISNULL(CAST(f.NetWorth AS varchar(25)),'-1')								AS 'NW',
									ISNULL(CAST(f.IntangibleAssets AS varchar(25)),'-1')						AS 'IA',
									ISNULL(CAST(f.BankDebt AS varchar(25)),'-1')								AS 'BD',
									ISNULL(CAST(f.IssuedCapital AS varchar(25)),'-1')							AS 'IC',
									ISNULL(f.IssuedCapitalCurrencyCode, '-1')									AS 'ICCC',
									ISNULL(CAST(f.TangibleNetWorth AS varchar(25)),'-1')						AS 'TNW',
									ISNULL(CAST(f.GoodWill AS varchar(25)),'-1')								AS 'GW',
									ISNULL(f.CurrencyCode, '-1')												AS 'CC',
									ISNULL(CAST(f.SalesRevenue AS varchar(25)),'-1')							AS 'SR',
									ISNULL(CAST(f.GrossProfit AS varchar(25)),'-1')								AS 'GP',
									ISNULL(CAST(f.EarningsBeforeInterestAndTaxes AS varchar(25)),'-1')			AS 'EBIT',
									ISNULL(CAST(f.InterestExpense AS varchar(25)),'-1')							AS 'IE',
									ISNULL(CAST(f.EarningBeforeTax AS varchar(25)),'-1')						AS 'EBT',
									ISNULL(CAST(f.OperatingIncome AS varchar(25)),'-1')							AS 'OI',
									ISNULL(CAST(f.NetIncome AS varchar(25)),'-1')								AS 'NI',
									ISNULL(CAST(f.CostOfSales AS varchar(25)),'-1')								AS 'CS',
									ISNULL(CAST(f.NetLoss AS varchar(25)),'-1')									AS 'NL',
									ISNULL(CAST(f.NetProfit AS varchar(25)),'-1')								AS 'NP',
									ISNULL(CAST(f.TotalOtherIncomeAndExpensesNet AS varchar(25)),'-1')			AS 'TOI',
									ISNULL(CAST(f.ResearchAndDevelopment AS varchar(25)),'-1')					AS 'RD',
									ISNULL(CAST(f.SellingGeneralAndAd AS varchar(25)),'-1')						AS 'SGA',
									ISNULL(CAST(f.NonRecurring AS varchar(25)),'-1')							AS 'NR',
									ISNULL(CAST(f.OtherOperatingExpenses AS varchar(25)),'-1')					AS 'OOE',
									ISNULL(CAST(f.NetDepreciationAndAmortizationExpense AS varchar(25)),'-1')	AS 'NDA',
									ISNULL(CAST(f.CashFlowFromFinancingActivities AS varchar(25)),'-1')			AS 'CFFA',
									ISNULL(CAST(f.CashFlowFromInvestingActivities AS varchar(25)),'-1')			AS 'CFIA',
									ISNULL(CAST(f.ChangeInCashAndCashEquivalents AS varchar(25)),'-1')			AS 'CCCE',
									ISNULL(CAST(f.CashFlowFromOperatingActivities AS varchar(25)),'-1')			AS 'CFOA',
									ISNULL(CAST(f.CapitalExpenditure AS varchar(25)),'-1')						AS 'CE',
									ISNULL(CAST(f.TotalSharesOutstanding AS varchar(25)),'-1')					AS 'TSO',
									ISNULL(CAST(f.AnnualSales AS varchar(25)),'-1')								AS 'ANS'
							FROM
									#tblBusinessToProcess t
							INNER JOIN
									dataflow.CirrusOnlineBusiness cob (nolock)
								ON
									t.BusinessID = cob.BusinessID
							INNER JOIN
									feed.Financial f (nolock)
								ON
									cob.DunsNumber = f.DunsNumber
								AND t.DataSource = f.DataSource
							) F
					FOR XML AUTO, ROOT('Dataflow'));
				
				
	
					IF @FinancialsXml IS NOT NULL
						BEGIN
							SET @FinancialsXml.modify('insert attribute Type {"Financials"} into (/Dataflow)[1]');
							
							SEND ON CONVERSATION @InitDlgHandle
							MESSAGE TYPE [DataFlowSendMessage]
								  (@FinancialsXml);
						END
				
					COMMIT TRANSACTION;

					IF NOT EXISTS(SELECT 1 FROM dataflow.BusinessFinancialQueue)
						BREAK;

					TRUNCATE TABLE #tblBusinessToProcess;

				END
		END
		
   
END