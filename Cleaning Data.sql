SELECT * FROM
[Portfolio Project]..NashvilleHousing

-- Standardizing date format
SELECT SaleDateNew, CONVERT(Date,SaleDate)
FROM [Portfolio Project].dbo.NashvilleHousing

UPDATE [Portfolio Project].dbo.NashvilleHousing
SET SaleDate = CONVERT(Date,SaleDate)

ALTER TABLE [Portfolio Project].dbo.NashvilleHousing
Add SaleDateNew Date;

UPDATE [Portfolio Project].dbo.NashvilleHousing
SET SaleDateNew = CONVERT(Date,SaleDate)

---------------------------------------------------------------------------------------------------------------
-- Populating property address
SELECT *
FROM [Portfolio Project].dbo.NashvilleHousing
order by ParcelID

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM [Portfolio Project].dbo.NashvilleHousing a
JOIN [Portfolio Project].dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID AND a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is NULL

Update a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM [Portfolio Project].dbo.NashvilleHousing a
JOIN [Portfolio Project].dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID AND a.[UniqueID ] <> b.[UniqueID ]

----------------------------------------------------------------------------------------------------------------

-- Breaking down address into individual columns (Address, City, State)
SELECT *
FROM [Portfolio Project].dbo.NashvilleHousing
order by ParcelID

SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) AS Address
,SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) AS Address
FROM [Portfolio Project].dbo.NashvilleHousing

-- 
ALTER TABLE [Portfolio Project].dbo.NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

UPDATE [Portfolio Project].dbo.NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )

ALTER TABLE [Portfolio Project].dbo.NashvilleHousing
Add PropertySplitCity Nvarchar(255);

UPDATE [Portfolio Project].dbo.NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))

SELECT * FROM 
[Portfolio Project].dbo.NashvilleHousing


SELECT OwnerAddress FROM 
[Portfolio Project].dbo.NashvilleHousing

Select 
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
FROM [Portfolio Project].dbo.NashvilleHousing

ALTER TABLE [Portfolio Project].dbo.NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

UPDATE [Portfolio Project].dbo.NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)

ALTER TABLE [Portfolio Project].dbo.NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

UPDATE [Portfolio Project].dbo.NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)

ALTER TABLE [Portfolio Project].dbo.NashvilleHousing
Add OwnerSplitState Nvarchar(255);

UPDATE [Portfolio Project].dbo.NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)

SELECT * FROM [Portfolio Project].dbo.NashvilleHousing

------------------------------------------------------------------------------------------------------------
-- Changing Y and N to Yes and No in 'Sold as Vacant' Field

SELECT Distinct(SoldAsVacant), count(SoldAsVacant)
FROM [Portfolio Project].dbo.NashvilleHousing
group by SoldAsVacant
order by 2

SELECT SoldAsVacant
, CASE when SoldAsVacant = 'Y' THEN 'Yes'
	when SoldAsVacant = 'N' THEN 'No'
ELSE SoldAsVacant
END
FROM [Portfolio Project].dbo.NashvilleHousing

Update [Portfolio Project].dbo.NashvilleHousing
SET SoldAsVacant = CASE when SoldAsVacant = 'Y' THEN 'Yes'
	when SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END
-----------------------------------------------------------------------------------------------------------

-- Removing Duplicates
WITH RowNum AS(
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
				ORDER BY
					UniqueID
					) row_num
FROM [Portfolio Project].dbo.NashvilleHousing
--order by ParcelID
)
SELECT * FROM RowNum
where row_num > 1
order by PropertyAddress

---------------------------------------------------------------------------------------------------------------------------------
-- Delete unused columns

Select * FROM [Portfolio Project].dbo.NashvilleHousing
order by ParcelID

ALTER TABLE [Portfolio Project].dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE [Portfolio Project].dbo.NashvilleHousing
DROP COLUMN SaleDate

