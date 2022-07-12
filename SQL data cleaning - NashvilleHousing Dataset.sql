USE [Nashville_Housing]
GO


SELECT *
FROM [dbo].[Nashville]

--Standardize SaleDate format

ALTER TABLE [dbo].[Nashville]
ADD Updated_SaleDate DATE

UPDATE[dbo].[Nashville]
SET Updated_SaleDate = CONVERT (DATE, SaleDate)

--Checking duplicated values

Select ParcelID, Updated_SaleDate, SalePrice, LegalReference, count(*)
from [dbo].[Nashville]
group by  ParcelID, Updated_SaleDate, SalePrice, LegalReference
Having count (*) >1

--Remove Duplicate Values
WITH cte AS(
	SELECT *,
		ROW_NUMBER() OVER (PARTITION BY ParcelID, 
								Updated_SaleDate, 
								SalePrice, 
								LegalReference
							ORDER BY ParcelID, 
									Updated_SaleDate, 
									SalePrice, 
									LegalReference
							) Row_num
	FROM [dbo].[Nashville]
	)
	DELETE
	FROM cte
	WHERE Row_num >1

--Inspecting the null values in property address and why null? 
SELECT * 
FROM [dbo].[Nashville]
WHERE PropertyAddress is null

SELECT * 
FROM [dbo].[Nashville]
WHERE ParcelID = '041 03 0A 100.00' --Randomly check the parcelID of null propertyAddress value

--Fill in the null values in property address

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM [dbo].[Nashville] a
JOIN [dbo].[Nashville] b 
	ON a.ParcelID = b.ParcelID
	AND a.UniqueID != b.UniqueID
WHERE a.PropertyAddress IS NULL

--Split Property address  into address,city, state
ALTER TABLE [dbo].[Nashville]
ADD Property_Address VARCHAR (100), 
	Property_City VARCHAR (100)

UPDATE [dbo].[Nashville]
SET Property_Address =PARSENAME(REPLACE ((PropertyAddress),',','.'),2)

UPDATE [dbo].[Nashville]
SET Property_City = PARSENAME(REPLACE ((PropertyAddress),',','.'),1)

--Split owner address into address,city, state

ALTER TABLE [dbo].[Nashville]
ADD Owner_Address VARCHAR (100), 
	Owner_City VARCHAR (100),
	Owner_State VARCHAR (100)

UPDATE [dbo].[Nashville]
SET Owner_Address = PARSENAME(REPLACE ((OwnerAddress),',','.'),3)

UPDATE [dbo].[Nashville]
SET Owner_City = PARSENAME(REPLACE ((OwnerAddress),',','.'),2)

UPDATE [dbo].[Nashville]
SET Owner_State = PARSENAME(REPLACE ((OwnerAddress),',','.'),1)


--Changing Yes, No in SoldAsVacant to Y and N accordingly

UPDATE [dbo].[Nashville]
SET SoldAsVacant =  CASE WHEN SoldASVacant = 'Yes' THEN 'Y'
						WHEN SoldASVacant = 'No' THEN 'N'
						ELSE SoldAsVacant
					END

--Delete unnecessary data

ALTER TABLE [dbo].[Nashville]
DROP COLUMN PropertyAddress, SaleDate, OwnerAddress 