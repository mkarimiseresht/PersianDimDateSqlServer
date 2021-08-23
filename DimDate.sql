CREATE OR ALTER PROCEDURE dim_date_creator AS
BEGIN

SET NOCOUNT ON

DECLARE @startyear AS INT
DECLARE @startdayofweek INT
DECLARE @startmonth AS INT
DECLARE @startdayofmonth AS INT
DECLARE @startweek AS INT
DECLARE @startdayofyear AS INT
DECLARE @startGeDate AS DATETIME
DECLARE @startseason AS INT
DECLARE @qtymonthday AS INT

SET @startyear = 1391
SET @startdayofweek = 4
SET @startmonth = 1
SET @startweek = 1
SET @startdayofmonth = 1
SET @startdayofyear = 1
SET @startGeDate = CONVERT(DATETIME,'2012-03-20T00:00:00.000',127)
SET @startseason = 1
SET @qtymonthday = 31

CREATE TABLE #tbl_week (
	weekNo INT,
	weekDesc NVARCHAR(20)
)

INSERT INTO #tbl_week VALUES (1,N'شنبه')
							,(2,N'یکشنبه')
							,(3,N'دوشنبه')
							,(4,N'سه شنبه')
							,(5,N'چهارشنبه')
							,(6,N'پنجشنبه')
							,(7,N'جمعه')


CREATE TABLE #tbl_month (
	monthNo INT,
	monthDesc NVARCHAR(20)
)

INSERT INTO #tbl_month VALUES (1,  N'01 - فروردین')
							 ,(2,  N'02 - اردیبهشت')
							 ,(3,  N'03 - خرداد')
							 ,(4,  N'04 - تیر')
							 ,(5,  N'05 - مرداد')
							 ,(6,  N'06 - شهریور')
							 ,(7,  N'07 - مهر')
							 ,(8,  N'08 - آبان')
							 ,(9,  N'09 - آذر')
							 ,(10, N'10 - دی')
							 ,(11, N'11 - بهمن')
							 ,(12, N'12 - اسفند')


CREATE TABLE #tbl_season (
	seasonNo INT,
	seasonDesc NVARCHAR(20)
)

INSERT INTO #tbl_season VALUES (1,  N'1 - بهار')
							  ,(2,  N'2 - تابستان')
							  ,(3,  N'3 - پاییز')
							  ,(4,  N'4 - زمستان')

IF EXISTS (SELECT * FROM dbo.sysobjects where id = OBJECT_ID(N'[dbo].[DimDate]'))
BEGIN
	DROP TABLE [dbo].[DimDate]
END

CREATE TABLE [DimDate] (
	dateKey			INT PRIMARY KEY,
	dateDesc		NVARCHAR(10),
	dateGe			DATETIME,
	QtyMonthDay		INT,
	yearNo			INT,
	dayOfWeekNo		INT,
	monthNo			INT,
	ShamsiWeekNo	INT,
	GeWeekNo		INT,
	dayOfMonthNo	INT,
	dayOfYearNo		INT,
	seasonNo		INT,
	dayOfWeekDesc   NVARCHAR(20),
	monthDesc		NVARCHAR(20),
	seasonDesc		NVARCHAR(20)
)


CREATE TABLE #tbl_dimdate (
	id bigint IDENTITY(1,1) PRIMARY KEY,
	dateGe       DATETIME,
	yearNo       INT,
	dayOfWeekNo  INT,
	monthNo      INT,
	ShamsiWeekNo INT,
	GeWeekNo	 INT,
	dayOfMonthNo INT,
	dayOfYearNo  INT,
	seasonNo     INT,
	QtyMonthDay  INT
)

INSERT INTO #tbl_dimdate 
	(dateGe
		,yearNo
			,dayOfWeekNo
				,monthNo
					,ShamsiWeekNo
						,GeWeekNo
							,dayOfMonthNo
								,dayOfYearNo
									,seasonNo
										,QtyMonthDay) 
VALUES                   
	(@startGeDate
		,@startyear
			,@startdayofweek
				,@startmonth
					,@startweek
						,@startweek
							,@startdayofmonth
								,@startdayofyear
									,@startseason
										,@qtymonthday)

DECLARE @iteration AS int
SET @iteration = 1

WHILE ( SELECT TOP 1 yearNo 
		FROM #tbl_dimdate 
		ORDER BY id DESC 
	  ) < 1450
BEGIN
	INSERT INTO #tbl_dimdate (dateGe
	                         ,yearNo
							 ,dayOfWeekNo
							 ,monthNo
							 ,ShamsiWeekNo
							 ,GeWeekNo
							 ,dayOfMonthNo
							 ,dayOfYearNo
							 ,seasonNo
							 ,QtyMonthDay)
	SELECT TOP 1
		   DATEADD( DAY, 1, dateGe ) AS dateGe
		  ,[yearNo]+(
						CASE 
							WHEN [dayOfYearNo] = 
								(CASE 
									WHEN ([yearNo])%33 IN (1,5,9,13,17,22,26,30) 
										THEN 366 
									ELSE 365 
								 END
								 ) 
							THEN 1 
							ELSE 0 
						END
					) AS yearNo
		  ,([dayOfWeekNo])%7 + 1 AS dayOfWeekNo
		  ,([monthNo]-1+(
							CASE 
								WHEN [dayOfMonthNo] = 
								(
									CASE 
										WHEN [dayOfYearNo] <= 186 
											THEN 31 
										WHEN [dayOfYearNo] <= 336 
											THEN 30 
										WHEN ([yearNo])%33 IN (1,5,9,13,17,22,26,30) 
											THEN 30 
										ELSE 29 
									END
								) 
								THEN 1 
								ELSE 0 
							END
						))%12+1 AS monthNo
						,CASE 
				WHEN [dayOfYearNo] = (
										CASE 
											WHEN ([yearNo])%33 IN (1,5,9,13,17,22,26,30) 
												THEN 366 
											ELSE 365 
										END
									) 
					THEN 1 
				ELSE (
					[ShamsiWeekNo]+(
								CASE 
									WHEN [dayOfWeekNo] = 7 
										THEN 1 
									ELSE 0 
								END
							)
					) 
			END AS ShamsiWeekNo
		  ,CASE 
				WHEN [dayOfYearNo] = (
										CASE 
											WHEN ([yearNo])%33 IN (1,5,9,13,17,22,26,30) 
												THEN 366 
											ELSE 365 
										END
									) 
					THEN 1 
				ELSE (
					[GeWeekNo]+(
								CASE 
									WHEN [dayOfWeekNo] = 2 
										THEN 1 
									ELSE 0 
								END
							)
					) 
			END AS GeWeekNo
		  ,([dayOfMonthNo])%(
							CASE 
								WHEN [dayOfYearNo] <= 186 
									THEN 31 
								WHEN [dayOfYearNo] <= 336 
									THEN 30 
								WHEN ([yearNo])%33 IN (1,5,9,13,17,22,26,30) 
									THEN 30 
								ELSE 29 
							END
							)+1 AS dayOfMonthNo
		  ,([dayOfYearNo])%(
							CASE 
								WHEN ([yearNo])%33 IN (1,5,9,13,17,22,26,30) 
									THEN 366 
								ELSE 365 
							END
							)+1 AS dayOfYearNo
		  ,CASE 
			WHEN [dayOfYearNo] < 93 
				THEN 1 
			WHEN [dayOfYearNo] < 186 
				THEN 2 
			WHEN [dayOfYearNo] < 276 
				THEN 3 
			WHEN [dayOfYearNo] = (
									CASE 
										WHEN ([yearNo])%33 IN (1,5,9,13,17,22,26,30) 
											THEN 366 
										ELSE 365 
									END
								) 
				THEN 1 
			ELSE 4 
		   END AS seasonNo
		   ,CASE 
				WHEN [dayOfYearNo] < 186 
					THEN 31 
				WHEN [dayOfYearNo] < 336 
					THEN 30 
				WHEN ([yearNo])%33 IN (1,5,9,13,17,22,26,30) 
					THEN 30 
				ELSE 29 
			END QtyMonthDay
	  FROM #tbl_dimdate
	  ORDER BY id DESC
	  SET @iteration +=1
END

  INSERT INTO [DimDate] (
	dateKey			,
	dateDesc		,
	dateGe			,
	QtyMonthDay		,
	yearNo			,
	dayOfWeekNo		,
	monthNo			,
	ShamsiWeekNo	,
	GeWeekNo		,
	dayOfMonthNo	,
	dayOfYearNo		,
	seasonNo		,
	dayOfWeekDesc   ,
	monthDesc		,
	seasonDesc		)
  SELECT 
	 md.yearNo*10000
			+md.monthNo*100
				+md.dayOfMonthNo AS DateKey
	,CONCAT(md.yearNo
		  ,CASE 
			WHEN md.monthNo<10 
				THEN '/0' 
			ELSE '/' 
		   END
		  ,md.monthNo
		  ,CASE 
			WHEN md.dayOfMonthNo<10 
				THEN '/0' 
			ELSE '/'
		   END
		  ,md.dayOfMonthNo) AS dateDesc
	,md.dateGe
	,MAX(md.dayOfMonthNo) OVER(PARTITION BY md.yearNo,md.monthNo) AS QtyMonthDay       
	,md.yearNo       
	,md.dayOfWeekNo  
	,md.monthNo      
	,md.ShamsiWeekNo
	,md.GeWeekNo       
	,md.dayOfMonthNo 
	,md.dayOfYearNo 
	,md.seasonNo     
  ,w.weekDesc
  ,m.monthDesc
  ,s.seasonDesc
  FROM #tbl_dimdate md
  LEFT JOIN #tbl_week w
  ON md.dayOfWeekNo = w.weekNo
  LEFT JOIN #tbl_month m
  ON md.monthNo = m.monthNo
  LEFT JOIN #tbl_season s
  ON md.seasonNo = s.seasonNo
  ORDER BY md.id
END
GO
