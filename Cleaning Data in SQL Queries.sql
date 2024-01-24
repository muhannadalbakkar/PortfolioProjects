/*

Cleaning Data in SQL Queries

*/

Select *
From PortfolioProject..NashvilleHousing

-- Standardize Date Format

Select SaleDateConverted, CONVERT(date, SaleDate)
From PortfolioProject..NashvilleHousing

Update NashvilleHousing
set SaleDate = CONVERT(date, SaleDate)

Alter Table NashvilleHousing
add SaleDateConverted Date;

Update NashvilleHousing
set SaleDateConverted = CONVERT(date, SaleDate)

------------------------------------------------------------------------------------------------------------------


-- Populate Property Address data


Select *
From PortfolioProject..NashvilleHousing
--where PropertyAddress is null
order by ParcelID

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
from PortfolioProject..NashvilleHousing a
join PortfolioProject..NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

update a
set a.PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
from PortfolioProject..NashvilleHousing a
join PortfolioProject..NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null


----------------------------------------------------------------------------------------------------------------


-- Breaking out Address into Individual Columns (Address, City, State)


Select PropertyAddress
From PortfolioProject..NashvilleHousing
--where PropertyAddress is null
--order by ParcelID

Select 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address
,SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) as Address
from PortfolioProject..NashvilleHousing

Alter Table PortfolioProject..NashvilleHousing
add PropertySplitAddress nvarchar(255);

Update PortfolioProject..NashvilleHousing
set PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

Alter Table PortfolioProject..NashvilleHousing
add PropertySplitCity nvarchar(255);

Update PortfolioProject..NashvilleHousing
set PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))

Select *
From PortfolioProject..NashvilleHousing

-------------------

Select OwnerAddress
From PortfolioProject..NashvilleHousing

select
PARSENAME(REPLACE(OwnerAddress,',','.'),3),
PARSENAME(REPLACE(OwnerAddress,',','.'),2),
PARSENAME(REPLACE(OwnerAddress,',','.'),1)
From PortfolioProject..NashvilleHousing

Alter Table PortfolioProject..NashvilleHousing
add OwnerSplitAddress nvarchar(255);

Update PortfolioProject..NashvilleHousing
set OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'),3)

Alter Table PortfolioProject..NashvilleHousing
add OwnerSplitCity nvarchar(255);

Update PortfolioProject..NashvilleHousing
set OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2)

Alter Table PortfolioProject..NashvilleHousing
add PropertySplitState nvarchar(255);

Update PortfolioProject..NashvilleHousing
set PropertySplitState = PARSENAME(REPLACE(OwnerAddress,',','.'),1)

Select *
From PortfolioProject..NashvilleHousing


----------------------------------------------------------------------------------------------------------


-- Change Y and N to Yes and No in "Sold as Vacant" field

select distinct(SoldAsVacant), Count(SoldAsVacant)
From PortfolioProject..NashvilleHousing
Group by SoldAsVacant
order by 2

select SoldAsVacant
,
CASE When SoldAsVacant = 'Y' THEN 'YES'
	 When SoldAsVacant = 'N' THEN 'No'
	 ELSE SoldAsVacant
	 END
From PortfolioProject..NashvilleHousing

UPDATE PortfolioProject..NashvilleHousing
SET SoldAsVacant = 
	CASE When SoldAsVacant = 'Y' THEN 'YES'
		 When SoldAsVacant = 'N' THEN 'No'
		 ELSE SoldAsVacant
		 END

----------------------------------------------------------------------------------------------------------------

-- Remove Duplicates
WITH RowNumCTE as(
select *, 
	ROW_NUMBER()Over(
	Partition by 
	ParcelID,
	PropertyAddress,
	SaleDate,
	SalePrice,
	LegalReference 
	Order by
	UniqueID
	) row_num

From PortfolioProject..NashvilleHousing
--order by ParcelID

)

DELETE
From RowNumCTE
where row_num > 1
--order by PropertyAddress


------------------------------------------------------------------------------------------

-- Delete unused Columns


Select *
From PortfolioProject..NashvilleHousing

Alter Table PortfolioProject..NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate