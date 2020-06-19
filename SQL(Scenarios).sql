INSERT INTO [dbo].[Accounts_GSTIN2A_B2B_Processed]
([GSTIN Of Supplier] ,
[Trade/Legal name of the Supplier],
[Invoice Number],
[Invoice Type],
[Invoice Date],  
[Invoice Value],
[Place of supply],
[Supply Attract Reverse Charge],
[Rate(In Percent)],
[Taxable Value],
[Integrated Tax],
[Central Tax],
[State\UT Tax],
[Cess],
[Counter Party Return status]
)
SELECT [dbo].[Accounts_GSTIN2A_B2B_src].[GSTIN of supplier] ,
       [dbo].[Accounts_GSTIN2A_B2B_src].[Trade/Legal name of the Supplier],
	   [dbo].[Accounts_GSTIN2A_B2B_src].[Invoice Number],
	   [dbo].[Accounts_GSTIN2A_B2B_src].[Invoice Type],
	   [dbo].[Accounts_GSTIN2A_B2B_src].[Invoice Date],
	   [dbo].[Accounts_GSTIN2A_B2B_src].[Invoice Value],
	   [dbo].[Accounts_GSTIN2A_B2B_src].[Place of supply],
	   [dbo].[Accounts_GSTIN2A_B2B_src].[Supply Attract Reverse Charge],
	   [dbo].[Accounts_GSTIN2A_B2B_src].[Rate (%)],
	   [dbo].[Accounts_GSTIN2A_B2B_src].[Taxable Value (₹)],
	   [dbo].[Accounts_GSTIN2A_B2B_src].[Integrated Tax],
	   [dbo].[Accounts_GSTIN2A_B2B_src].[Central Tax],
	   [dbo].[Accounts_GSTIN2A_B2B_src].[State\UT Tax],
	   [dbo].[Accounts_GSTIN2A_B2B_src].[Cess],
	   [dbo].[Accounts_GSTIN2A_B2B_src].[Counter Party Return status]
	   FROM [Accounts_GSTIN2A_B2B_src]

Update [Accounts_GSTIN2A_B2B_Processed]
SET [Invoice Date (F)] =
Cast(SUBSTRING([Invoice Date],7,4) + '-' + SUBSTRING([Invoice Date],4,2) + '-' + SUBSTRING([Invoice Date],1,2) as date)


UPDATE [dbo].[Accounts_GSTIN2A_B2B_Processed]
SET [Accounts_GSTIN2A_B2B_Processed].[Invoice Date] = [dbo].[Accounts_GSTINB2B_Amendments_Processed].[Invoice Date (Revised)]
FROM [Accounts_GSTIN2A_B2B_Processed]
INNER JOIN [dbo].[Accounts_GSTINB2B_Amendments_Processed]
ON [Accounts_GSTIN2A_B2B_Processed].[GSTIN Of Supplier] = [dbo].[Accounts_GSTINB2B_Amendments_Processed].[GSTIN of Supplier]
AND [Accounts_GSTIN2A_B2B_Processed].[Invoice Number] = [dbo].[Accounts_GSTINB2B_Amendments_Processed].[Invoice number (Revised)]

TRUNCATE TABLE Accounts_Mismatching_PurchASe_Register_src
INSERT INTO Accounts_Mismatching_PurchASe_Register_src
SELECT 
PR_ID = ROW_NUMBER()OVER(ORDER BY [Invoice Date (F)],[Revised Invoice Number],[Partner GSTIN]),
[Revised Invoice Number] ,
[Invoice Date (F)],
[Department],
[Cost Center],
[Vendor Number],
[Vendor Name],
[MIRO NO#],
[Order & CC],
[St# Loc Desc],
[Partner GSTIN],
[BASe Amount] ,
[Intra GST] ,
[Inter GST]  
FROM [dbo].[Accounts_PurchASe_Register_Processed] 

UPDATE [dbo].[Accounts_Mismatching_PurchASe_Register_src]
SET Accounts_Mismatching_PurchASe_Register_src.[BASe Amount] = T2.SUMFIELD
FROM [Accounts_Mismatching_PurchASe_Register_src] 
INNER JOIN (SELECT [Partner GSTIN],[Invoice no] ,ROUND(SUM([Base Amount]),2) AS SUMFIELD
FROM [Accounts_Mismatching_PurchASe_Register_src]
GROUP by [Partner GSTIN] ,[Invoice no] ) AS T2
ON T2.[Partner GSTIN] = [Accounts_Mismatching_PurchASe_Register_src].[Partner GSTIN] 
AND T2.[Invoice no] = [Accounts_Mismatching_PurchASe_Register_src].[Invoice no]


UPDATE
[dbo].[Accounts_Mismatching_Processed]
SET 
[Accounts_Mismatching_Processed].[Remarks]  =  'All Match',
[Accounts_Mismatching_Processed].[GST_GSTIN_SUpplier]   = [Accounts_Mismatching_GSTIN2A_src].[GSTIN of Supplier],
[Accounts_Mismatching_Processed].[GST_InvoiceDate]		= [Accounts_Mismatching_GSTIN2A_src].[Invoice Date],
[Accounts_Mismatching_Processed].[GST_InvoiceNumber]	= [Accounts_Mismatching_GSTIN2A_src].[Invoice Number],
[Accounts_Mismatching_Processed].[GST_InvoiceValue]	    = [Accounts_Mismatching_GSTIN2A_src].[Invoice Value],
[Accounts_Mismatching_Processed].[GST_TaxableValue]  	= [Accounts_Mismatching_GSTIN2A_src].[Taxable Value],
[Accounts_Mismatching_Processed].[GST_IntraGST]		    = [Accounts_Mismatching_GSTIN2A_src].[Intra GST],
[Accounts_Mismatching_Processed].[GST_InterGST]         = [Accounts_Mismatching_GSTIN2A_src].[Inter GST],
[Accounts_Mismatching_Processed].[GST_ID]		        = [Accounts_Mismatching_GSTIN2A_src].GST_ID
FROM [dbo].[Accounts_Mismatching_Processed] 
INNER JOIN [dbo].[Accounts_Mismatching_GSTIN2A_src]  
ON [Accounts_Mismatching_Processed].[Invoice Date] = [Accounts_Mismatching_GSTIN2A_src].[Invoice Date] 
AND Accounts_Mismatching_Processed.[Invoice No]    = [Accounts_Mismatching_GSTIN2A_src].[Invoice NUmber]
AND Accounts_Mismatching_Processed.[Partner GSTIN] = [Accounts_Mismatching_GSTIN2A_src].[GSTIN of Supplier]

INSERT INTO [dbo].[IT_TCODE_Users_Processed]
([Name],
[Role],
[Level],
[Department],
[Personal Number],
[Authorization Value],
[Transaction Text])
SELECT A2.NAME , A2.Role , A2.LEVEL , A2.DEPT , A2.[Personal Number] , A2.[Authorization value] ,[dbo].[IT_Transaction_Summary_src].[Transaction Text]  FROM (
SELECT A1.NAME , A1.Role , A1.LEVEL , A1.DEPT , A1.[Personal Number] ,[dbo].[IT_AGR_src].[Authorization value]  FROM (
SELECT [dbo].[IT_EOR_src].[name],
       [dbo].[IT_AGR_USERS_src].[role],
	   [dbo].[IT_EOR_src].[level],
	   [dbo].[IT_EOR_src].[dept],
	   [dbo].[IT_EOR_src].[Personal Number]
	   from [dbo].[IT_AGR_USERS_src] 
	   INNER JOIN [dbo].[IT_EOR_src]
	   ON [dbo].[IT_AGR_USERS_src].[User Name] = [dbo].[IT_EOR_src].[personal number]) A1
	   INNER JOIN [dbo].[IT_AGR_src] 
	   ON A1.Role = [dbo].[IT_AGR_src].[Role] ) A2 
	   INNER JOIN [dbo].[IT_Transaction_Summary_src]
	   ON A2.[Authorization value] = [dbo].[IT_Transaction_Summary_src].[TCode]
	   WHERE NOT EXISTS ( SELECT [Name],
                                 [Role],
                                 [Level],
                                 [Department],
                                 [Personal Number],
                                 [Authorization Value],
								 [Transaction Text]
								 FROM [dbo].[IT_TCODE_Users_Processed]
								 WHERE [dbo].[IT_TCODE_Users_Processed].[Personal Number] = A2.[Personal Number])
							     

Update [Accounts_GSTIN2A_B2B_Processed]
SET [Invoice Date (F)] =
Cast(SUBSTRING([Invoice Date],7,4) + '-' + SUBSTRING([Invoice Date],4,2) + '-' + SUBSTRING([Invoice Date],1,2) as date)

UPDATE [dbo].[Accounts_GSTIN2A_B2B_Processed]
SET [Invoice Number] = SUBSTRING([Invoice Number],PATINDEX('%[1-9]% , %[A-Z]% , %[-,/,\]%' ,[Invoice Number]) ,50)
WHERE LEFT([Invoice Number] , 1) = '0'

Insert into [dbo].[PSD_Energy_Security_processed] 
select [Business Partner] ,
       [dbo].[PSD_Energy_Security_src].[Energy Security] ,
	   [BG] ,
	   [Total] 
	   from [dbo].[PSD_Energy_Security_src]
	   where NOT EXISTS 
	   (SELECT * FROM [dbo].[PSD_Energy_Security_processed] 
	    WHERE [dbo].[PSD_Energy_Security_src].[Business Partner] = [dbo].[PSD_Energy_Security_processed].[Business Partner Number]
		AND   [dbo].[PSD_Energy_Security_src].BG = [dbo].[PSD_Energy_Security_processed].[Bank Gurantee]
		AND   [dbo].[PSD_Energy_Security_src].[Energy Security] = [dbo].[PSD_Energy_Security_processed].[Energy Security]
		AND   [dbo].[PSD_Energy_Security_src].Total = [dbo].[PSD_Energy_Security_processed].[Total Security])
	


INSERT INTO [dbo].[PSD_HT_Bank_Gurantee_Info_Processed]
([Business Partner Number] ,
[Bank Gurantee])
SELECT [dbo].[PSD_HT_Data_Processed].[Business Partner Number] ,
       [dbo].[PSD_HT_Data_Processed].[Outstanding]
	   FROM [PSD_HT_Data_Processed]
	   WHERE NOT EXISTS ( SELECT [Business Partner Number] , [Bank Gurantee]
	   FROM [PSD_HT_Bank_Gurantee_Info_Processed]
	   WHERE [dbo].[PSD_HT_Data_Processed].[Business Partner Number] = [dbo].[PSD_HT_Bank_Gurantee_Info_Processed].[Business Partner Number])
	   AND [dbo].[PSD_HT_Data_Processed].Outstanding > 1000000


INSERT INTO [dbo].[PSD_Calculated_Energy_Security_Categorisation_Processed]
([Business Partner Number] ,
[Name] ,
[Bill Month] ,
[Bill Year] ,
[Total Bill],
[Category(Internal)]
)
SELECT 
[dbo].[PSD_HT_Data_Processed].[Business Partner Number],
[dbo].[PSD_HT_Data_Processed].[Customer Name],
[dbo].[PSD_HT_Data_Processed].[Bill Month],                                                  
[dbo].[PSD_HT_Data_Processed].[Bill Year],
[dbo].[PSD_HT_Data_Processed].[Final Bill],
[dbo].[PSD_HT_Data_Processed].[Category]
FROM [dbo].[PSD_HT_Data_Processed] 
WHERE NOT EXISTS (SELECT [Business Partner Number] ,
[Name] ,
[Bill Month] ,
[Bill Year] ,
[Total Bill] ,
[Category(Internal)] 
FROM 
[dbo].[PSD_Calculated_Energy_Security_Categorisation_Processed]
WHERE [dbo].[PSD_HT_Data_Processed].[Business Partner Number] = [PSD_Calculated_Energy_Security_Categorisation_Processed].[Business Partner Number]
AND [dbo].[PSD_HT_Data_Processed].[Bill Month] = [PSD_Calculated_Energy_Security_Categorisation_Processed].[Bill Month] 
AND [dbo].[PSD_HT_Data_Processed].[Bill Year] = [PSD_Calculated_Energy_Security_Categorisation_Processed].[Bill Year] )


UPDATE [dbo].[PSD_Calculated_Energy_Security_CategorisatiON_Processed]
SET [Date For 12 MONths] = CAST(CONCAT([Bill Year],'-',[Bill MONth(Numerical)],'-','01') AS DATE )

UPDATE [dbo].[PSD_Calculated_Energy_Security_CategorisatiON_Processed]
SET [Average Of 12 MONths] = A1.AVERAGE
FROM [PSD_Calculated_Energy_Security_CategorisatiON_Processed] C1
INNER JOIN 
(SELECT [Business Partner Number] , [Date For 12 MONths] , [Total Bill] ,
Round(AVG([Total Bill]) OVER (PARTITION BY [Business Partner Number]
Order by  [Business Partner Number],year([Date For 12 MONths]), MONth([Date For 12 MONths]) 
ROWS BETWEEN 12 PRECEDING AND 0 FOLLOWING ) ,2) AS AVERAGE
FROM [PSD_Calculated_Energy_Security_CategorisatiON_Processed]) A1
ON A1.[Business Partner Number] = C1.[Business Partner Number]
and A1.[Date For 12 MONths] = C1.[Date For 12 MONths]
and A1.[Total Bill] = C1.[Total Bill]


DELETE FROM [dbo].[PSD_HT_Data_src]
WHERE [dbo].[PSD_HT_Data_src].[Business Partner No.] IN (
SELECT [dbo].[PSD_LT_Data_src].[Business Part] FROM [dbo].[PSD_LT_Data_src])

MERGE [dbo].[PSD_HT_Data_Processed]
USING [dbo].[PSD_HT_Data_src]
ON (  [dbo].[PSD_HT_Data_src].[Business Partner No.] = [dbo].[PSD_HT_Data_Processed].[Business Partner Number]
   AND [dbo].[PSD_HT_Data_src].[Post Date C] = [dbo].[PSD_HT_Data_Processed].[Posting Date]
	)
WHEN NOT MATCHED BY TARGET
THEN INSERT 
([Serial Number],
[Business Partner Number],
[Customer Name],
[Print Doc No.],
[Posting Date],
[Connection Date],
[Sanctioned Load],
[Act Demand],
[Billing Md],
[Highest Md Fy],
[Category],
[Units Kwh],
[Units Kvah],
[Mul Factor],
[Net Units],
[Mrnote],
[Energy Charge],
[Fixed Charge],
[Energy & Fix Charges(SUM)],
[PF],
[PF Surcharge],
[PF Rebate],
[% Load Fact],
[LF Rebate],
[Vol Rebate],
[FPPPA Charg],
[Total],
[Meter Rent],
[E Duty],
[Outstanding],
[LPC],
[Interest On Sd],
[TDS],
[Rebate Early],
[Rebate Digital],
[Others],
[Final Bill])
VALUES ([dbo].[PSD_HT_Data_src].[SL. No],
	    [dbo].[PSD_HT_Data_src].[Business Partner No.],
	    [dbo].[PSD_HT_Data_src].[Customer Name],
		[dbo].[PSD_HT_Data_src].[Print Doc No.],
		[dbo].[PSD_HT_Data_src].[Post Date C],
		[dbo].[PSD_HT_Data_src].[Conn Date C],
		[dbo].[PSD_HT_Data_src].[Sanc Load],
		[dbo].[PSD_HT_Data_src].[Act Demand],
		[dbo].[PSD_HT_Data_src].[Billing Md],
		[dbo].[PSD_HT_Data_src].[Highest Md Fy],
		[dbo].[PSD_HT_Data_src].[Category],
		[dbo].[PSD_HT_Data_src].[Units Kwh],
		[dbo].[PSD_HT_Data_src].[Units Kvah],
		[dbo].[PSD_HT_Data_src].[Mul Factor],
		[dbo].[PSD_HT_Data_src].[Net Units],
		[dbo].[PSD_HT_Data_src].[Mrnote],
		[dbo].[PSD_HT_Data_src].[Energy Charge],
		[dbo].[PSD_HT_Data_src].[Fixed Charge],
		[dbo].[PSD_HT_Data_src].[Energy+Fix Charge],
		[dbo].[PSD_HT_Data_src].[PF],
		[dbo].[PSD_HT_Data_src].[PF Surcharge],
		[dbo].[PSD_HT_Data_src].[PF Rebate],
		[dbo].[PSD_HT_Data_src].[% Load Fact],
		[dbo].[PSD_HT_Data_src].[LF Rebate],
		[dbo].[PSD_HT_Data_src].[Vol Rebate],
		[dbo].[PSD_HT_Data_src].[FPPPA Charg],
		[dbo].[PSD_HT_Data_src].[Total],
		[dbo].[PSD_HT_Data_src].[Meter Rent],
		[dbo].[PSD_HT_Data_src].[E Duty],
		[dbo].[PSD_HT_Data_src].[Outstanding],
		[dbo].[PSD_HT_Data_src].[LPC],
		[dbo].[PSD_HT_Data_src].[Interest On Sd],
		[dbo].[PSD_HT_Data_src].[TDS],
		[dbo].[PSD_HT_Data_src].[Rebate Early],
		[dbo].[PSD_HT_Data_src].[Rebate Digital],
		[dbo].[PSD_HT_Data_src].[Others],
		[dbo].[PSD_HT_Data_src].[Final Bill]);

Insert into [dbo].[PSD_Energy_Security_processed] 
select [Business Partner] ,
       [dbo].[PSD_Energy_Security_src].[Energy Security] ,
	   [BG] ,
	   [Total] 
	   from [dbo].[PSD_Energy_Security_src]
	   WHERE NOT EXISTS 
	   (SELECT * FROM [dbo].[PSD_Energy_Security_processed] 
	    WHERE [dbo].[PSD_Energy_Security_src].[Business Partner] = [dbo].[PSD_Energy_Security_processed].[Business Partner Number]
		AND   [dbo].[PSD_Energy_Security_src].BG = [dbo].[PSD_Energy_Security_processed].[Bank Gurantee]
		AND   [dbo].[PSD_Energy_Security_src].[Energy Security] = [dbo].[PSD_Energy_Security_processed].[Energy Security]
		AND   [dbo].[PSD_Energy_Security_src].Total = [dbo].[PSD_Energy_Security_processed].[Total Security])

