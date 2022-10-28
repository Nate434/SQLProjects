/*
Cleaning Nashville Housing Data
*/

SELECT *
FROM PortfolioProject.dbo.NashvilleHousing

-- Standarize the Sale Date Format
SELECT SaleDate, CONVERT(Date,SaleDate)
From PortfolioProject.dbo.NashvilleHousing

UPDATE NashvilleHousing
SET SaleDate = CONVERT(Date,SaleDate)

ALTER TABLE NashvilleHousing
ADD SaleDateConverted Date;

UPDATE NashvilleHousing
SET SaleDateConverted = CONVERT(Date,SaleDate)

SELECT SaleDateConverted, CONVERT(Date,SaleDate)
From PortfolioProject.dbo.NashvilleHousing



-- Populate the Property Address fields which are not populated (Null)
SELECT *
FROM PortfolioProject.dbo.NashvilleHousing
WHERE PropertyAddress IS NULL

SELECT *
FROM PortfolioProject.dbo.NashvilleHousing
ORDER BY ParcelID

SELECT nshone.ParcelID, nshone.PropertyAddress, nshtwo.ParcelID, nshtwo.PropertyAddress
FROM PortfolioProject.dbo.NashvilleHousing nshone
JOIN PortfolioProject.dbo.NashvilleHousing nshtwo
ON nshone.ParcelID = nshtwo.ParcelID
AND nshone.[UniqueID ] <> nshtwo.[UniqueID ]
WHERE nshone.PropertyAddress IS NULL

SELECT nshone.ParcelID, nshone.PropertyAddress, nshtwo.ParcelID, nshtwo.PropertyAddress, ISNULL(nshone.PropertyAddress, nshtwo.PropertyAddress)
FROM PortfolioProject.dbo.NashvilleHousing nshone
JOIN PortfolioProject.dbo.NashvilleHousing nshtwo
ON nshone.ParcelID = nshtwo.ParcelID
AND nshone.[UniqueID ] <> nshtwo.[UniqueID ]
WHERE nshone.PropertyAddress IS NULL

UPDATE nshone
SET PropertyAddress = ISNULL(nshone.PropertyAddress, nshtwo.PropertyAddress)
FROM PortfolioProject.dbo.NashvilleHousing nshone
JOIN PortfolioProject.dbo.NashvilleHousing nshtwo
ON nshone.ParcelID = nshtwo.ParcelID
AND nshone.[UniqueID ] <> nshtwo.[UniqueID ]
WHERE nshone.PropertyAddress IS NULL



-- Take Property Address and separate those into individual columns for Address, City
SELECT PropertyAddress
FROM PortfolioProject.dbo.NashvilleHousing

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) AS Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) AS City
FROM PortfolioProject.dbo.NashvilleHousing

ALTER TABLE NashvilleHousing
ADD PropertySplitAddress nvarchar(255);

UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)

ALTER TABLE NashvilleHousing
ADD PropertySplitCity nvarchar(255);

UPDATE NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))

SELECT *
FROM PortfolioProject.dbo.NashvilleHousing



-- Take Owner Address and separate those into individual columns for Address, City, and State
SELECT OwnerAddress
FROM PortfolioProject.dbo.NashvilleHousing

SELECT PARSENAME(REPLACE(OwnerAddress, ',', '.'),3),
PARSENAME(REPLACE(OwnerAddress, ',', '.'),2),
PARSENAME(REPLACE(OwnerAddress, ',', '.'),1)
FROM PortfolioProject.dbo.NashvilleHousing

ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress nvarchar(255);

UPDATE NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'),3)

ALTER TABLE NashvilleHousing
ADD OwnerSplitCity nvarchar(255);

UPDATE NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'),2)

ALTER TABLE NashvilleHousing
ADD OwnerSplitState nvarchar(255);

UPDATE NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'),1)

SELECT *
FROM PortfolioProject.dbo.NashvilleHousing



-- Change any SoldAsVacant values that are 'Y' or 'N' to 'Yes' & 'No' to achieve uniformity as those values appear more frequently
SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM PortfolioProject.dbo.NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2

SELECT SoldAsVacant,
	CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
		 WHEN SoldAsVacant = 'N' THEN 'No'
		 ELSE SoldAsVacant
		 END
FROM PortfolioProject.dbo.NashvilleHousing

UPDATE NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
				   WHEN SoldAsVacant = 'N' THEN 'No'
		           ELSE SoldAsVacant
		           END



-- Remove Duplicates
WITH RowNumberCTE AS (
SELECT *, 
ROW_NUMBER() OVER (PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference
				   ORDER BY UniqueID
				   ) row_num
FROM PortfolioProject.dbo.NashvilleHousing
)

--DELETE
--FROM RowNumberCTE
--WHERE row_num > 1

SELECT *
FROM RowNumberCTE
WHERE row_num > 1



-- Remove Columns that are not needed
SELECT *
FROM PortfolioProject.dbo.NashvilleHousing

ALTER TABLE NashvilleHousing
DROP COLUMN PropertyAddress, OwnerAddress, TaxDistrict

ALTER TABLE NashvilleHousing
DROP COLUMN SaleDate
