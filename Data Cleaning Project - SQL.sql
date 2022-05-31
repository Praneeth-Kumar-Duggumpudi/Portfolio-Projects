
/*

Data Cleaning in SQL - Housing Data

*/



select *
from PortfolioProject..HousingData


-----------------------------------------------------------------------------------------------


-- Standardizing Data Format

select SaleDate, convert(date, SaleDate)
from PortfolioProject..HousingData

update HousingData
set SaleDate = convert(date, SaleDate)


-- or


select SaleDateConverted, convert(date, SaleDate)
from PortfolioProject..HousingData

alter table HousingData
add SaleDateConverted date;

update HousingData
set SaleDateConverted = convert(date, SaleDate)

---------------------------------------------------------------------------------------------


-- Populate Property Address Data


select *
from PortfolioProject..HousingData
where PropertyAddress is null
order by ParcelID


select A.ParcelID, A.PropertyAddress, B.ParcelID, B.PropertyAddress, isnull(A.PropertyAddress, B.PropertyAddress)
from PortfolioProject..HousingData A
join PortfolioProject..HousingData B
	on A.ParcelID = B.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where A.PropertyAddress is null


Update A
set PropertyAddress = isnull(A.PropertyAddress, B.PropertyAddress)
from PortfolioProject..HousingData A
join PortfolioProject..HousingData B
	on A.ParcelID = B.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where A.PropertyAddress is null



------------------------------------------------------------------------------------


-- Breaking out Address into Individual Columns (Address, City, State)


select PropertyAddress
from PortfolioProject..HousingData

select
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) as Address
from PortfolioProject..HousingData

alter table HousingData
add Property_Split_Address nvarchar(250);

update HousingData
set Property_Split_Address = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)


alter table HousingData
add Property_Split_City nvarchar(250);

update HousingData
set Property_Split_City = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))


select * 
from PortfolioProject..HousingData



-- Another method of Breaking down the address is by using PARSENAME
-- Breaking down the Owner Address

select OwnerAddress
from PortfolioProject..HousingData

select 
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
from PortfolioProject..HousingData

alter table HousingData
add OwnerSplitAddress nvarchar(250);

update HousingData
set OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)


alter table HousingData
add OwnerSplitCity nvarchar(250);

update HousingData
set OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)


alter table HousingData
add OwnerSplitState nvarchar(250);

update HousingData
set OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)



select * 
from PortfolioProject..HousingData





--------------------------------------------------------------------------------------------------



-- Changing Y and N to Yes and No in the Column 'SoldasVacant'

select SoldAsVacant 
from PortfolioProject..HousingData


select distinct(SoldAsVacant), COUNT(SoldAsVacant)
from PortfolioProject..HousingData
group by SoldAsVacant
order by 2


select SoldAsVacant,
case when SoldAsVacant = 'Y' then 'Yes'
	when SoldAsVacant = 'N' then 'No'
	else SoldAsVacant
End
from PortfolioProject..HousingData

update HousingData
set SoldAsVacant = case when SoldAsVacant = 'Y' then 'Yes'
	when SoldAsVacant = 'N' then 'No'
	else SoldAsVacant
End



select distinct(SoldAsVacant), COUNT(SoldAsVacant)
from PortfolioProject..HousingData
group by SoldAsVacant
order by 2




--------------------------------------------------------------------------------------------------



-- Removing Duplicates - by using CTEs


select *
from PortfolioProject..HousingData

with RowNumCTE as 
(
select *,
ROW_NUMBER() over (
partition by ParcelID, PropertyAddress, SaleDate, SalePrice, LegalReference
order by UniqueID
) Row_num
from PortfolioProject..HousingData
)
select * 
from RowNumCTE
where Row_num > 1



-- the above query displays all the duplicates
-- to remove the duplicates, the following query can be used



with RowNumCTE as 
(
select *,
ROW_NUMBER() over (
partition by ParcelID, PropertyAddress, SaleDate, SalePrice, LegalReference
order by UniqueID
) Row_num
from PortfolioProject..HousingData
)
Delete 
from RowNumCTE
where Row_num > 1


select *
from PortfolioProject..HousingData




--------------------------------------------------------------------------------------------------



-- Deleting Unused Columns


select *
from PortfolioProject..HousingData

alter table PortfolioProject..HousingData
drop column OwnerAddress, PropertyAddress, TaxDistrict


alter table PortfolioProject..HousingData
drop column SaleDate
