-- Remove duplicate row
-- Change SaleDate column data type from DATETIME TO DATE
-- Fill NULL in PropertyAddress column
-- Seperate PropertyAddress column into Property_Address column and Property_City column
-- Seperate OwnerAddress column into Owner_Address column and Owner_City column
-- Make SolAsVacant column into same format 'Yes' or 'No'
-- Drop unused column

CREATE DATABASE Portfolio;

USE Portfolio;

------------------------------------------------------------------------------------------------------------------------------

-- Import Excel file Nashville
-- Insert into new table

SELECT *
INTO Nashville_housing
FROM [dbo].[Sheet1$];

SELECT *
FROM Nashville_housing;

------------------------------------------------------------------------------------------------------------------------------

-- Remove duplicate row

WITH find_duplicate AS (
	
	SELECT *,
	ROW_NUMBER() OVER(PARTITION BY ParcelID, LandUse, PropertyAddress, SaleDate, SalePrice, LegalReference, SoldAsVacant ORDER BY ParcelId) AS row_num
	FROM Nashville_housing

)

SELECT *
FROM find_duplicate
WHERE row_num > 1;

--DELETE 
--FROM find_duplicate
--WHERE row_num > 1;

------------------------------------------------------------------------------------------------------------------------------

-- Change SaleDate column data type from DATETIME TO DATE

SELECT COLUMN_NAME, DATA_TYPE, IS_NULLABLE, COLUMN_DEFAULT
FROM INFORMATION_SCHEMA.COLUMNS 
WHERE TABLE_NAME = 'Nashville_housing';

ALTER TABLE Nashville_housing
ALTER COLUMN SaleDate DATE;

------------------------------------------------------------------------------------------------------------------------------

-- Fill NULL in PropertyAddress column

SELECT a.ParcelID, a.LandUse, a.PropertyAddress, b.PropertyAddress, ISNULL(b.PropertyAddress, a.PropertyAddress)
FROM Nashville_housing AS a
JOIN Nashville_housing AS b
ON a.ParcelId = b.ParcelId AND a.PropertyAddress IS NOT NULL AND b.PropertyAddress IS NULL

UPDATE b
SET PropertyAddress = ISNULL(b.PropertyAddress, a.PropertyAddress)
	FROM Nashville_housing AS a
	JOIN Nashville_housing AS b
	ON a.ParcelId = b.ParcelId AND a.PropertyAddress IS NOT NULL AND b.PropertyAddress IS NULL

------------------------------------------------------------------------------------------------------------------------------

-- Seperate PropertyAddress column into Property_Address column and Property_City column

SELECT PropertyAddress, LEFT(PropertyAddress, CHARINDEX(',', PropertyAddress) - 1) AS Property_Address, TRIM(RIGHT(PropertyAddress, (LEN(PropertyAddress) - CHARINDEX(',', PropertyAddress)))) AS Property_City
FROM Nashville_housing

ALTER TABLE Nashville_housing
ADD Property_Address NVARCHAR(250),
	Property_City NVARCHAR(250);

UPDATE Nashville_housing
SET Property_Address = LEFT(PropertyAddress, CHARINDEX(',', PropertyAddress) - 1),
	Property_City = TRIM(RIGHT(PropertyAddress, (LEN(PropertyAddress) - CHARINDEX(',', PropertyAddress))))

------------------------------------------------------------------------------------------------------------------------------

-- Seperate OwnerAddress column into Owner_Address column and Owner_City column

SELECT OwnerAddress
FROM Nashville_housing

SELECT OwnerAddress, PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3) AS Owner_Address, PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2) AS Owner_City, PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1) AS Owner_State 
FROM Nashville_housing
WHERE OwnerAddress IS NOT NULL

ALTER TABLE Nashville_housing
ADD Owner_Address NVARCHAR(250),
	Owner_City NVARCHAR(250),
	Owner_State NVARCHAR(250);

UPDATE Nashville_housing
SET Owner_Address = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
	Owner_City = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
	Owner_State = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1);

------------------------------------------------------------------------------------------------------------------------------

-- Make SoldAsVacant column into same format 'Yes' or 'No'

SELECT SoldAsVacant, COUNT(SoldAsVacant) AS count
FROM Nashville_housing
GROUP BY SoldAsVacant
ORDER BY count DESC

SELECT SoldAsVacant,
	CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END
	AS change_format
FROM Nashville_housing

UPDATE Nashville_housing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
				   WHEN SoldAsVacant = 'N' THEN 'No'
				   ELSE SoldAsVacant
				   END

------------------------------------------------------------------------------------------------------------------------------

-- Drop unused column
	-- PropertyAddress
	-- OwnerAddress

SELECT *
FROM Nashville_housing


ALTER TABLE Nashville_housing
DROP COLUMN PropertyAddress, OwnerAddress

