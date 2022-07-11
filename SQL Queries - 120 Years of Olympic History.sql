USE [AthleteDB]
GO

--How many olympic games (OG) have been held

SELECT COUNT (DISTINCT Games) AS total_num_of_OG
FROM [dbo].[athlete_events]

--list all the OG held

SELECT DISTINCT year,
	season,
	city
FROM[dbo].[athlete_events]
ORDER BY 1 ASC

--Total number of nations joined in each OG

SELECT DISTINCT a.Games,
	COUNT(DISTINCT n.region) as Total_countries
FROM[dbo].[athlete_events] a
JOIN [dbo].[noc_regions] n ON a.NOC = n.NOC
GROUP BY a.Games
ORDER BY 1 ASC

--Which year with highest and lowest number of coutries participating

WITH Tot_countries(OG,Total_countries) AS (
	SELECT  a.Games ,
		COUNT(DISTINCT n.region)
	FROM[dbo].[athlete_events] a
	JOIN [dbo].[noc_regions] n ON a.NOC = n.NOC
	GROUP BY a.Games
	)
	SELECT DISTINCT
		CONCAT(first_value(OG) OVER(ORDER BY Total_countries), '-', first_value(Total_countries) OVER (ORDER BY Total_countries)) as Lowest_countries,
		CONCAT(first_value(OG) OVER(ORDER BY Total_countries DESC), '-', first_value(Total_countries) OVER (ORDER BY Total_countries DESC)) as Highest_countries
	FROM Tot_countries
	
--the nation that attend in all OG
WITH Tot_games (Total_OG) AS (
	SELECT COUNT (DISTINCT Games)
	FROM [dbo].[athlete_events]
	),
	Tot_participated_games (Countries, Total_participated_OG) AS(
	SELECT DISTINCT n.region,
		COUNT (DISTINCT a.Games) 
	FROM [dbo].[athlete_events] a
	JOIN [dbo].[noc_regions] n ON a.NOC=n.NOC
	GROUP BY n.region
	)
	SELECT Countries, Total_OG
	FROM Tot_games tg
	JOIN Tot_participated_games tp ON tg.Total_OG = tp.Total_participated_OG

--the total number of sports play in each OG

SELECT DISTINCT Games,
	COUNT (DISTINCT Sport) as Total_sport
FROM [dbo].[athlete_events]
GROUP BY Games
ORDER BY 2 DESC

--the sport was played in all summer OG
WITH Tol_summer_games (Total_games) AS (
	SELECT COUNT (DISTINCT Games)
	FROM [dbo].[athlete_events]
	WHERE Season = 'Summer'
	),
	Tol_sport(Sport, Num_of_Games) AS(
	SELECT DISTINCT Sport,
		COUNT (DISTINCT Games) 
	FROM [dbo].[athlete_events]
	GROUP BY Sport
	)
	SELECT Sport,
		Num_of_games,
		Total_games
	FROM Tol_summer_games tg
	JOIN Tol_sport ts ON tg.Total_games = ts.Num_of_Games

--the sport was played in only 1 OG
WITH Games (Games, Sport) AS (
		SELECT DISTINCT Games, Sport
		FROM [dbo].[athlete_events]
	),
	Tol_sport (Sport, Num_of_games) AS (
		SELECT DISTINCT Sport,
			COUNT (Games)
		FROM Games
		GROUP BY Sport
	)
	SELECT t.Sport, t.Num_Of_Games, g.Games
	FROM Games g
	JOIN Tol_sport t ON g.Sport = t.Sport
	WHERE t.Num_of_games =1

--the oldest athletes to win a gold medal
WITH t1 AS (
	SELECT *
	FROM [dbo].[athlete_events]
	WHERE Medal = 'Gold'
		AND Age != 'NA'
	),
	t2 AS (
	SELECT *,RANK () OVER (ORDER BY Age DESC) as Ranking
	FROM t1
	)
	SELECT Name, Sex, Age, Team, Games,City, Sport, Event, Medal
	FROM t2
	WHERE ranking= 1

--top 5 athletes who won the most gold medals
WITH Tol_gold_medal AS (
	SELECT Name, Team,
		COUNT(Medal) as Num_of_medal
	FROM [dbo].[athlete_events]
	WHERE Medal = 'Gold'
	GROUP BY Name, Team
	),
	Ranking AS (
	SELECT *, DENSE_RANK()OVER (ORDER BY Num_of_medal DESC) as rnk
	FROM Tol_gold_medal
	)
	SELECT *
	FROM Ranking
	WHERE rnk<=5

--top 5 athletes who won the most medals (gold/silver/bronze)

WITH Tol_medal AS (
	SELECT Name, Team,
		COUNT(Medal) as Num_of_medal
	FROM [dbo].[athlete_events]
	WHERE Medal != 'NA'
	GROUP BY Name, Team
	),
	Ranking AS (
	SELECT *, DENSE_RANK()OVER (ORDER BY Num_of_medal DESC) as rnk
	FROM Tol_medal
	)
	SELECT *
	FROM Ranking
	WHERE rnk<=5

--top 5 successful countries in OG with the highest numbers of medals won

SELECT TOP 5 n.region,
	COUNT(a.Medal) as Num_of_medal
FROM [dbo].[athlete_events] a,[dbo].[noc_regions] n
WHERE a.NOC = n.NOC AND Medal != 'NA'
GROUP BY n.region
ORDER BY 2 DESC
	
--list total medals won by each country

SELECT n.region,
		COUNT(a.Medal) as Num_of_medal
	FROM [dbo].[athlete_events] a,[dbo].[noc_regions] n
	WHERE a.NOC = n.NOC AND Medal != 'NA'
	GROUP BY n.region

--which country won the most gold/ silver/bronze

/*using Pivot (SQL Server) or Crosstab (postgresql)*/
SELECT country,
	[Gold] as Gold,
	[Silver] as Silver,
	[Bronze] as Bronze
FROM (
	SELECT n.region as country,
		Medal
	FROM [dbo].[athlete_events] a, [dbo].[noc_regions] n 
	WHERE a.NOC = n.NOC and Medal !='NA'
	)ps
PIVOT (
	COUNT (Medal)
	FOR medal IN ([Gold],[Silver],[Bronze])
	) as pvt
ORDER BY 2 DESC

--which country won the most gold/ silver/bronze medals and the most medals in each OG
WITH Temp AS (
SELECT Games, country,
	[Gold] as Gold,
	[Silver] as Silver,
	[Bronze] as Bronze
FROM (
	SELECT  Games, n.Region as country,
		Medal
	FROM [dbo].[athlete_events] a, [dbo].[noc_regions] n 
	WHERE a.NOC = n.NOC and Medal !='NA'
	)ps
PIVOT (
	COUNT (Medal)
	FOR medal IN ([Gold],[Silver],[Bronze])
	) as pvt
)
SELECT DISTINCT Games,
	CONCAT (first_value (Country) OVER (PARTITION BY Games ORDER BY Gold DESC),'-',
		first_value (Gold) OVER (PARTITION BY Games ORDER BY Gold DESC)) AS Max_Gold,
	CONCAT (first_value (Country) OVER (PARTITION BY Games ORDER BY Silver DESC),'-',
		first_value (Silver) OVER (PARTITION BY Games ORDER BY Silver DESC)) AS Max_Silver,
	CONCAT (first_value (Country) OVER (PARTITION BY Games ORDER BY Bronze DESC),'-',
		first_value (Bronze) OVER (PARTITION BY Games ORDER BY Bronze DESC)) AS Max_Bronze
FROM Temp

--which country has never won gold medal but have silver/bronze medals
WITH Temp AS (
SELECT Games, country,
	[Gold] as Gold,
	[Silver] as Silver,
	[Bronze] as Bronze
FROM (
	SELECT  Games, n.Region as country,
		Medal
	FROM [dbo].[athlete_events] a, [dbo].[noc_regions] n 
	WHERE a.NOC = n.NOC and Medal !='NA'
	)ps
PIVOT (
	COUNT (Medal)
	FOR medal IN ([Gold],[Silver],[Bronze])
	) as pvt
)
SELECT DISTINCT Country, Gold, Silver, Bronze
FROM Temp
WHERE Gold = 0 AND (Silver != 0 OR Bronze !=0)

--which sport/event, China has won hihgest medals
SELECT TOP 1 a.Sport,
	Count (Medal) as Total_medals
FROM [dbo].[athlete_events] a
JOIN [dbo].[noc_regions] n  ON a.NOC = n.NOC
WHERE n.Region ='China' AND a.Medal!='NA'
GROUP BY Sport
ORDER BY 2 DESC

--which OG where China won gold medal for Hockey and how many medals each OG

SELECT n.Region as Country,
	a.Sport,
	a.Games,
	Count (Medal) as Total_medals
FROM [dbo].[athlete_events] a
JOIN [dbo].[noc_regions] n  ON a.NOC = n.NOC
WHERE n.Region ='China' AND a.Medal!='Gold' and Sport = 'Hockey'
GROUP BY n.Region, Sport, Games
ORDER BY 4 DESC


select * 
from [dbo].[athlete_events]

select * 
from [dbo].[noc_regions]