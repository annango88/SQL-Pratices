USE [NetflixDB]
GO

SELECT *
FROM [dbo].[netflix_data]

--Fill blank rows with 'Null'

UPDATE [dbo].[netflix_data]
SET director = NULLIF(director,' '),
	cast = NULLIF(cast,' '),
	country = NULLIF(country,' '),
	date_added = NULLIF(date_added,' '),
	release_year = NULLIF(release_year,' '),
	rating = NULLIF(rating,' '),
	duration = NULLIF(duration,' '),
	listed_in = NULLIF(listed_in,' '),
	description = NULLIF(description,' ')

--Inspecting null values in each column
SELECT *
FROM [dbo].[netflix_data]
WHERE director IS NULL  --Change the column accordingly

--Delete rows where type is blank and is 'William Wyler' since the data seems to mistankenly record
/* Note: The other missing value will be kept as it could be interesting to look at*/
DELETE FROM netflix_data
WHERE type = ' ' 

DELETE FROM netflix_data
WHERE type ='William Wyler'

--Checking Duplicates
/* Output: There is no duplicated value found*/
SELECT show_id,
	type,
	title,
	director,
	country, 
	release_year,
	count(*)
FROM [dbo].[netflix_data]
GROUP BY show_id, type,title,director,country,release_year
HAVING count(*)>1

--standardize date_added format
ALTER TABLE [dbo].[netflix_data]
ADD Converted_Date_Added DATE

UPDATE [dbo].[netflix_data]
SET Converted_Date_Added = CONVERT (DATE, date_added)

--Split Date_added to Month_added and Year_added

ALTER TABLE [dbo].[netflix_data]
ADD Month_added NVARCHAR(20), Year_added INT

UPDATE [dbo].[netflix_data]
SET Month_added = DATENAME(month,Converted_Date_Added),
	Year_Added = YEAR (Converted_Date_Added)

--Getting duration number from Duration column
---Create Dur_num column
ALTER TABLE [dbo].[netflix_data]
ADD dur_num INT

---Create get number function

create function GetNumber
(@input varchar (255))
returns varchar (255)
as
begin
	declare @alphabetIndex int = patindex('%[^0-9]%',@input)
	Begin 
		While @alphabetIndex >0
		begin
			set @input = stuff(@input,@alphabetIndex,1,'')
			set @alphabetIndex = Patindex('%[^0-9]%',@input)
		end
	end
	return @input
end

---update dur_num column with extracted duration number
UPDATE [dbo].[netflix_data]
SET dur_num = dbo.GetNumber(duration)

--split the listed_in value into different rows
/* Note: The Output will increase the total number of rows in the dataset
- Specifically, each Show_ID will have several listed_in values record in deferent rows*/

Select *, value updated_listed_in
into final_netflix_data
from [dbo].[netflix_data]
	cross apply string_split(listed_in,',')

-- Remove 'TV Shows' and 'Movies' words in Listed_in

UPDATE final_netflix_data
SET updated_listed_in = REPLACE(REPLACE(REPLACE(REPLACE(updated_listed_in,'TV Shows',''),' TV ',''),'Movies',''),'TV','')

--Remove the first space in Listed_in

UPDATE final_netflix_data
SET updated_listed_in = LTRIM(updated_listed_in)

--Create rating category

ALTER TABLE final_netflix_data
ADD rating_category VARCHAR (50)

UPDATE final_netflix_data
SET rating_category = case when rating in ('TV-Y','TV-Y7','G','TV-G','PG','TV-PG') then 'kids'
						when rating in ('PG-13','TV-14') then 'teens'
						when rating in ('R','NR','TV-MA','NC-17') then 'adults'
					end

--Drop unncecessary column

ALTER TABLE [dbo].[final_netflix_data]
DROP COLUMN date_added, listed_in, value, description



