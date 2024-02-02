-- select Data that we ar going to be using

Select location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
order by 1,2

-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country

Select location, date, total_cases, total_deaths, (CONVERT(float, total_deaths) / NULLIF(CONVERT(float, total_cases), 0)) * 100 AS Deathpercentage
From PortfolioProject..CovidDeaths
Where location like '%syria%' AND continent is not NULL
order by 1,2

-- Looking at Total Caces vs Population
-- Shows what Percentage of populations got Covid

Select location, date, total_cases, population,  (total_cases/population) * 100 AS PercentPopulationsInfected
From PortfolioProject..CovidDeaths
-- Where location like '%states%'
Where continent is not NULL
order by 1,2

-- Looking at Countries with Highest Infection Rate compared to Population

Select location, population, max(total_cases) as HighestInfectionCount, max((total_cases/population)) * 100 AS PercentPopulationsInfected
From PortfolioProject..CovidDeaths
--Where location like '%states%'
Where continent is not NULL
group by location, population
order by PercentPopulationsInfected DESC 

-- Showing Countries with Highest Death Count per Population

Select location, population, max(CONVERT(float, total_deaths)) as HighestDeathCount
From PortfolioProject..CovidDeaths
Where continent is NOT NULL
group by location, population
order by HighestDeathCount DESC 

-- Let's Break Things down by Continent
-- Showing Continent with Highest Death Count per Population

Select location, max(CONVERT(float, total_deaths)) as HighestDeathCount
From PortfolioProject..CovidDeaths
Where continent is NULL
group by location
order by HighestDeathCount DESC 

--Global Numbers

Select date, SUM(new_cases) as Case_Count , SUM(CONVERT(float, new_deaths)) as Death_Count, 
SUM(CONVERT(float, new_deaths))/SUM(new_cases) *100 as Death_Percentage
From PortfolioProject..CovidDeaths
Where continent is NOT NULL
group by date
order by 1,2

-- Looking at Total Population vs Vaccinations 

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(int,new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject.. CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on vac.location = dea.location AND vac.date = dea.date
Where dea.continent is NOT NULL
order by 2,3

--USE CTE

With PopvsVac (continent, location, date,population, new_vaccination, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(int,new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject.. CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on vac.location = dea.location AND vac.date = dea.date
Where dea.continent is NOT NULL
--order by 2,3
)

select *, (RollingPeopleVaccinated/population) *100
From PopvsVac

-- TEMP TABLE
Drop table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar (255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(int,new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject.. CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on vac.location = dea.location AND vac.date = dea.date
--Where dea.continent is NOT NULL
--order by 2,3
select*, (RollingPeopleVaccinated/population)*100
from #PercentPopulationVaccinated

-- Creating View to store data for later Visualizations

create view PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(int,new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject.. CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on vac.location = dea.location AND vac.date = dea.date
Where dea.continent is NOT NULL
--order by 2,3

select*
from PortfolioProject..PercentPopulationVaccinated
