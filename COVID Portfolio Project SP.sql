
Select *
From PortfolioProject..CovidDeaths
order by 3,4 

Select *
From PortfolioProject..CovidVaccinations
order by 3,4

Select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths

--Looking at Total cases vs Total Deaths
-- Shows likehood of dying if you contract in your country
Select location, date, total_cases,  total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where location like '%canada%'
order by 1,2

-- Looking at Total cases vs Population
-- Show what percentage of poplulation got Covid
Select Location, Date,   Population, Total_cases, (Total_cases/Population)*100 as PopluationPercentage
from PortfolioProject..CovidDeaths
where location like '%canada%'
order by 1,2

-- Looking at countries with Highest Infection rate compared to Infection rate

Select Location, Population, MAX(total_cases) as HighestInfectionCount, Max(total_cases/population)*100 as PercentPopluationInfected
From PortfolioProject..CovidDeaths
Group by Location, Population
order by PercentPopluationInfected desc

Select Location, Population, MAX(total_cases) as HighestInfectionCount, Max(total_cases/population)*100 as PercentPopluationInfected
From PortfolioProject..CovidDeaths
where location like '%Marino%'
Group by Location, Population
order by PercentPopluationInfected desc

-- Looking at Country with highest Death Count per population

Select Location, MAX(total_deaths) as TotalDeathCount
From PortfolioProject..CovidDeaths
where continent is not null
Group by Location
order by TotalDeathCount desc

Select Location, MAX(total_deaths) as TotalDeathCount
From PortfolioProject..CovidDeaths
where location like '%dia%'
Group by Location
order by TotalDeathCount desc

Select Location, MAX(total_deaths) as TotalDeathCount
From PortfolioProject..CovidDeaths
where location like '%canada%'
Group by Location

-- Let's Break things down by Continent

Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--where location like '%canada%'
where continent is not null
Group by continent
order by TotalDeathCount desc

-- Let's Break things down by Location with conitnent is null

Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--where location like '%canada%'
where continent is null
Group by Location
order by TotalDeathCount desc

-- Showing continents with the Highest death as perr population

Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--where location like '%canada%'
where continent is not null
Group by continent
order by TotalDeathCount desc


-- Global numbers

Select continent, date, total_cases,  total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
--where location like '%canada%'
where continent is not null
order by 1,2

Select date, SUM(new_cases) as total_cases,  SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
--where location like '%canada%'
where continent is not null
Group by date
order by 1,2

--Table Covid Vaccination

Select* 
From PortfolioProject..CovidVaccinations

--Join tables on location, date
Select *
from PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date


-- Looking at Total population vs vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
from PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

-- Looking as rolling count

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location,
  dea.Date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3


-- USE CTE

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as 
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location,
  dea.Date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
from PopvsVac

-- Creating a Temp Table
Drop table if exists #PercentPopulatedVaccinated
Create Table #PercentPopulatedVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)
-- Insert in Temp Table 
Insert into #PercentPopulatedVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location,
  dea.Date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
from #PercentPopulatedVaccinated


-- View Creating View to Store data for late visualisation

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location,
  dea.Date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

Create View GlobalNumbers as
Select continent, date, total_cases,  total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
--where location like '%canada%'
where continent is not null
