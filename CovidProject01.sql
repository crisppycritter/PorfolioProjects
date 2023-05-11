--Covid 19 Data Exloration

--Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Converting Data Types, Creating Views

-- Making sure all data is correct in CovidDeaths

Select * 
From CovidProject01..CovidDeaths
where continent is not null
Order By 3,4

--Select * 
--From CovidProject01..CovidVaccinations
--Order By 3,4

-- Select Data that I will be starting with

Select location, date, total_cases, new_cases, total_deaths, population
From CovidProject01..CovidDeaths
Where continent is not null
Order By 1,2

-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From CovidProject01..CovidDeaths
Where location like '%states%'
and continent is not null
Order By 1,2

-- Looking at the Total Cases vs Population
-- Shows what percentage of population contracted covid

Select location, date, population, total_cases, (total_deaths/population)*100 as PercentPopulationInfected
From CovidProject01..CovidDeaths
Order By 1,2

--Looking at Countries with Highest Infection Rate vs Population

Select location, population, MAX(total_cases) as HighestInfectionCount, Max((total_deaths/population))*100 as PercentPopulationInfected
From CovidProject01..CovidDeaths
Group by location, population
Order By PercentPopulationInfected desc

-- Showing Countries with Highest Death Count per Population

Select location, Max(cast(total_deaths as int)) as TotalDeathCount
From CovidProject01..CovidDeaths
where continent is not null
Group by location
Order By TotalDeathCount desc

--Showing Continents with Highest Death count per Populaiton

Select continent, Max(cast(total_deaths as int)) as TotalDeathCount
From CovidProject01..CovidDeaths
where continent is not null
Group by continent
Order By TotalDeathCount desc

-- GLOBAL NUMBERS

--Global by date

Select date, SUM(new_cases) as total_cases, Sum(cast(new_deaths as int)) as total_deaths
, SUM(cast(new_deaths as int))/Sum(new_cases)*100 as DeathPercentage 
From CovidProject01..CovidDeaths
Where continent is not null
group by date
Order By 1,2

--Global total

Select SUM(new_cases) as total_cases, Sum(cast(new_deaths as int)) as total_deaths
, SUM(cast(new_deaths as int))/Sum(new_cases)*100 as DeathPercentage 
From CovidProject01..CovidDeaths
Where continent is not null
Order By 1,2

--Joining CovidDeaths and CovidVaccines
--Total Population Vs Vaccinations
-- Shows Percentage of Population that has received at least one covid Vaccine

Select *
From CovidProject01..CovidDeaths
Join CovidProject01..CovidVaccinations
	On CovidDeaths.location = CovidVaccinations.location
	and CovidDeaths.date = CovidVaccinations.date

--Looking at Total Population vs Vaccinations

Select CovidDeaths.continent, CovidDeaths.location, CovidDeaths.date, CovidDeaths.population, CovidVaccinations.new_vaccinations
, SUM(Cast(CovidVaccinations.new_vaccinations as int)) OVER (partition by CovidDeaths.location Order By CovidDeaths.location
, CovidDeaths.date) as RollingPeopleVaccinated
From CovidProject01..CovidDeaths
Join CovidProject01..CovidVaccinations
	On CovidDeaths.location = CovidVaccinations.location
	and CovidDeaths.date = CovidVaccinations.date
Where CovidDeaths.continent is not null
Order By 1,2,3

-- Using CTE to preform Calculation on Partition By in previous query

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select CovidDeaths.continent, CovidDeaths.location, CovidDeaths.date, CovidDeaths.population, CovidVaccinations.new_vaccinations
, SUM(Cast(CovidVaccinations.new_vaccinations as int)) OVER (partition by CovidDeaths.location Order By CovidDeaths.location
, CovidDeaths.date) as RollingPeopleVaccinated
From CovidProject01..CovidDeaths
Join CovidProject01..CovidVaccinations
	On CovidDeaths.location = CovidVaccinations.location
	and CovidDeaths.date = CovidVaccinations.date
Where CovidDeaths.continent is not null
)
Select *, (RollingPeopleVaccinated/Population)*100 as Persensent_of_Vacc
From PopvsVac

-- Using Temp Table to preform Calculation on Partition By in previous querry

Drop Table if exists #PercentPopulaionVaccinated
Create Table #PercentPopulaionVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulaionVaccinated
Select CovidDeaths.continent, CovidDeaths.location, CovidDeaths.date, CovidDeaths.population, CovidVaccinations.new_vaccinations
, SUM(Cast(CovidVaccinations.new_vaccinations as int)) OVER (partition by CovidDeaths.location Order By CovidDeaths.location
, CovidDeaths.date) as RollingPeopleVaccinated
From CovidProject01..CovidDeaths
Join CovidProject01..CovidVaccinations
	On CovidDeaths.location = CovidVaccinations.location
	and CovidDeaths.date = CovidVaccinations.date
Where CovidDeaths.continent is not null

Select *, (RollingPeopleVaccinated/Population)*100 as Persensent_of_Vacc
From #PercentPopulaionVaccinated

--Creating view to store data for later visualization

Create View PerventPopulationVaccinated as
Select CovidDeaths.continent, CovidDeaths.location, CovidDeaths.date, CovidDeaths.population, CovidVaccinations.new_vaccinations
, SUM(Cast(CovidVaccinations.new_vaccinations as int)) OVER (partition by CovidDeaths.location Order By CovidDeaths.location
, CovidDeaths.date) as RollingPeopleVaccinated
From CovidProject01..CovidDeaths
Join CovidProject01..CovidVaccinations
	On CovidDeaths.location = CovidVaccinations.location
	and CovidDeaths.date = CovidVaccinations.date
Where CovidDeaths.continent is not null

