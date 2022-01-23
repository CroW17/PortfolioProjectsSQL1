Select *
FROM PortfolioProject..CovidDeaths
Where continent is not null
order by 3,4

--Select *
--FROM PortfolioProject..CovidVaccinations
--order by 3,4


-- Select Data that we are going to be using

Select location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
Where continent is not null
order by 1,2


-- Looking at the Total Cases vs Total Deaths
-- Showing likelihood of dying if you contract Covid in South Africa
Select location, date, total_cases, total_deaths, (CONVERT(decimal, total_deaths)/CONVERT(decimal,total_cases))*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
Where location like 'South Africa'
and continent is not null
order by 1,2


-- Looking at Total Cases vs Population
-- Shows what percentage of the population got Covid

Select location, date, population, total_cases, (CONVERT(decimal, total_cases)/CONVERT(decimal, population))*100 as PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
Where location like 'South Africa'
and continent is not null
order by 1,2

-- Looking at Countries with Highest Infection Rate compared to Population

Select Location, Population, MAX(CONVERT(decimal, total_cases)) as HighestInfectionCount, Max((CONVERT(decimal, total_cases)/CONVERT(decimal, population)))*100 as PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
--Where location like 'South Africa'
Where continent is not null
Group by Location, Population
order by PercentPopulationInfected desc


-- Showing Countries with Highest Death Count per Population

Select Location, MAX(cast(total_deaths as decimal)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
--Where location like 'South Africa'
Where continent is not null
Group by Location
order by TotalDeathCount desc


-- Lets break things down by Continent

-- Showing the Continents with the Highest Death Count per Population

Select continent, MAX(cast(total_deaths as decimal)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
--Where location like 'South Africa'
Where continent is not null
Group by continent
order by TotalDeathCount desc


-- Global Numbers
-- Daily Total New Cases vs Total New Deaths vs Death Percentage

Select date, SUM(CONVERT(decimal, new_cases)) as total_cases, SUM(CONVERT(decimal, new_deaths)) as  total_deaths, SUM(CONVERT(decimal, new_deaths))/SUM(CONVERT(decimal, new_cases))*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
--Where location like 'South Africa'
Where continent is not null
Group by date
order by 1,2


--Total New Cases vs Total New Deaths vs Death Percentage

Select SUM(CONVERT(decimal, new_cases)) as total_cases, SUM(CONVERT(decimal, new_deaths)) as  total_deaths, SUM(CONVERT(decimal, new_deaths))/SUM(CONVERT(decimal, new_cases))*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
--Where location like 'South Africa'
Where continent is not null
--Group by date
order by 1,2


-- Looking at Total Population vs Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(DECIMAL, vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) --as RollingPeopleVaccinated, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
	where dea.continent is not null
	order by 2,3


-- Use CTE

With POPvsVAC (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(DECIMAL, vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
	where dea.continent is not null
	--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From POPvsVAC


-- Temp Table

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(DECIMAL, vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) 
as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
	--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated



-- Creating View to store data for later vizualizations

Create View PercentPopulationVaccinated as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(DECIMAL, vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) 
as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

Select *
From PercentPopulationVaccinated