
/*
COVID-19 DATA EXPLORATION
The data set has been taken from https://ourworldindata.org/covid-deaths

Skills Used:- Joins, CTE's (Common Table Expression), Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

*/



select *
from PortfolioProject..CovidDeaths
where continent is not null
order by 3,4

select *
from PortfolioProject..CovidVaccinations
where continent is not null
order by 3,4



-- Selecting Data that we are going to start with

select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths
where continent is not null
order by 1,2




-- Total Cases vs Total Deaths
-- likelihood of dying if we contract COVID in the respective country

select location, date, population, total_cases, total_deaths, (total_deaths/total_cases)*100 as Death_Percentage
from PortfolioProject..CovidDeaths
where continent is not null
order by 1,2

-- likelihood of dying in Italy
select location, date, population, total_cases, total_deaths, (total_deaths/total_cases)*100 as Death_Percentage
from PortfolioProject..CovidDeaths
where location like '%italy%'
order by 1,2




-- Total Cases vs Total Population
-- It gives the percentage of population infected with COVID

select location, date, population, total_cases, (total_cases/population)*100 as Infected_Percentage
from PortfolioProject..CovidDeaths
where continent is not null
order by 1,2

-- Perentage of population infected with COVID in Italy

select location, date, population, total_cases, (total_cases/population)*100 as Infected_Percentage
from PortfolioProject..CovidDeaths
where location like '%italy%'
order by 1,2



-- Countries with Highest Infection Rates compared to Population

select location, population, max(total_cases) as Highest_Infection_Count, max((total_cases/population))*100 as Percent_Population_Infected
from PortfolioProject..CovidDeaths
group by location, population
order by Percent_Population_Infected desc



-- Countries with Highest Death Count per Population

select location, max(cast(total_deaths as int)) as Total_Death_Count
from PortfolioProject..CovidDeaths
where continent is not null
group by location
order by Total_Death_Count desc


-- Continents with highest Death count per population

select continent, max(cast(total_deaths as int)) as Total_Death_Count
from PortfolioProject..CovidDeaths
where continent is not null
group by continent
order by Total_Death_Count desc



-- Global Numbers

select date, sum(new_cases) as Total_cases, sum(cast(new_deaths as int)) as Total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as Death_Percentage
from PortfolioProject..CovidDeaths
where continent is not null
group by date
order by 1,2

-- Overall Death Percentage in the world

select sum(new_cases) as Total_cases, sum(cast(new_deaths as int)) as Total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as Death_Percentage
from PortfolioProject..CovidDeaths
where continent is not null




-- Percentage of Population that received Covid Vaccine
-- Total Population vs Vaccinations

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as Rolling_People_Vaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3



-- Using CTE (Common Table Expression) to perform calculation on Partition in the previous query

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, Rolling_People_Vaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as Rolling_People_Vaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
)
Select *, (Rolling_People_Vaccinated/Population)*100
From PopvsVac



-- Using Temp Table to perform calculation on Partition By in previous query

Drop table if exists #PercentofPopulationVaccinated
create table #PercentofPopulationVaccinated
(
Continent nvarchar(250),
Location nvarchar(50),
Date datetime,
Population int,
New_Vaccinatioons int,
Rolling_People_Vaccinated int
)

Insert into #PercentofPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as Rolling_People_Vaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null

select *, (Rolling_People_Vaccinated/Population)*100
from #PercentofPopulationVaccinated



-- Creating View to store data for later visulaization

create view PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as Rolling_People_Vaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null


select *
from PercentPopulationVaccinated