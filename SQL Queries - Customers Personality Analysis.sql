USE [Customer_personalityDB]
GO

----------------------------------------------------------------------------------------
--INSPECTING AND PRE- PROCESSING DATA

SELECT *
FROM Customers

-- Missing value 
/*There are few null value in Income column. 
Instead of deleting, the value will be filled in with the average income in the column.*/

----Select avarage income of the column
SELECT AVG(Income) as Avg_Income
FROM [dbo].[Customers]

----Create new updated_income column
ALTER TABLE [dbo].[Customers]
ADD Updated_Income INT

----Update income into new column
UPDATE [dbo].[Customers]
SET Updated_Income =COALESCE(Income, 52247)


-- Calculate customer Age and Create Age group

----Create new columns
ALTER TABLE Customers
ADD Age INT, Age_Group Varchar (50)

----Update data into new columns
UPDATE Customers
SET Age = (2022-Year_Birth),

UPDATE Customers
SET Age_Group = CASE WHEN Age <=30 THEN 'Under 30'
					 WHEN Age BETWEEN 31 AND 50 THEN '31-50'
					 WHEN Age BETWEEN 51 AND 70 THEN '51-70'
					 WHEN Age >70 THEN 'Over 70'
				END

-- Update Education information by grouping into 3 main categories: Undergraduate, Graduate, and Postgraduate

UPDATE Customers
SET Education = CASE WHEN Education = 'Basic' THEN ' Undergraduate'
					WHEN Education = '2n Cycle' THEN ' Undergraduate'
					WHEN Education = 'Graduation' THEN ' Graduate'
					WHEN Education = 'Master' THEN ' Postgraduate'
					WHEN Education = 'PhD' THEN ' Postgraduate'
				END


-- Update Marital status information by grouping into 2 main categories: Partner and Alone

UPDATE Customers
SET Marital_Status = CASE WHEN Marital_Status = 'Married' THEN 'Partner'
					WHEN Marital_Status = 'Together' THEN 'Partner'
					WHEN Marital_Status = 'Widow' THEN 'Alone'
					WHEN Marital_Status = 'YOLO' THEN 'Alone'
					WHEN Marital_Status = 'Absurd' THEN 'Alone'
					WHEN Marital_Status = 'Divorced' THEN 'Alone'
					WHEN Marital_Status = 'Single' THEN 'Alone'
					WHEN Marital_Status = 'Alone' THEN 'Alone'
					END

-- Create new Children column by Combining the number of kidhome and Teenhome information
ALTER TABLE Customers
ADD Children INT

UPDATE Customers
SET Children = Kidhome + Teenhome

--Sum the Spent and creat new total spent column
ALTER TABLE Customers
ADD Spent INT

UPDATE Customers
SET Spent = MntWines + MntFruits +MntGoldProds +MntMeatProducts + MntSweetProducts+MntFishProducts


--Select only necessary data and store into a new table
SELECT ID, 
	Age_Group,
	Education,
	Marital_Status,
	Children,
	Updated_Income,
	Dt_Customer,
	Spent,
	Complain,
	Response
INTO Cleaned_Customers
FROM [dbo].[Customers]

-----------------------------------------------------------------------------------------------
--CUSTOMER ANALYSIS
-- Customer by age group

SELECT Age_Group, 
	Count(*) as Total_Cust,
	COUNT(*)*100.0/(SELECT COUNT(*) FROM Cleaned_Customers) AS Perct_Cust
FROM Cleaned_Customers
GROUP BY Age_Group
ORDER BY 2 DESC

--Average income by Age group

SELECT Age_Group, 
	AVG (Updated_Income) AS Avg_Income
FROM Cleaned_Customers
GROUP BY Age_Group
ORDER BY 2 DESC

--Spent by age group

SELECT Age_Group, 
	SUM(Spent) as Total_Spent,
	SUM(Spent)*100.0/(SELECT SUM(Spent) FROM Cleaned_Customers) AS Perct_Spent
FROM Cleaned_Customers
GROUP BY Age_Group
ORDER BY 2 DESC

--Customer by Education Level

SELECT Education, 
	Count(*) as Total_Cust,
	COUNT(*)*100.0/(SELECT COUNT(*) FROM Cleaned_Customers) AS Perct_Cust
FROM Cleaned_Customers
GROUP BY Education
ORDER BY 2 DESC

--Average Income by Customer Education Level

SELECT Education, 
	AVG (Updated_Income) AS Avg_Income
FROM Cleaned_Customers
GROUP BY Education
ORDER BY 2 DESC

--Number of Children Vs Spent
SELECT Children, 
	SUM(Spent) as Total_Spent,
	SUM(Spent)*100.0/(SELECT SUM(Spent) FROM Cleaned_Customers) AS Perct_Spent
FROM Cleaned_Customers
GROUP BY Children
ORDER BY 2 DESC