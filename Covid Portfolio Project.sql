
Select *
From PortfolioProject1..CovidDeaths
--where continent is not null
order by 3,4

--Select *
--From PortfolioProject1..CovidVaccinations
--order by 3,4

--Select Date that we are going to be using

Select location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject1..CovidDeaths
order by 1,2


--Looking at total Cases vs total deaths
--Shows the likelihood of dying if you contract covid in your country
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject1..CovidDeaths
--Where location = 'India'
where continent is not null
order by 1,2

--Looking at Total cases vs Populations
--Shows what percentage of population got covid

Select location, date, population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
From PortfolioProject1..CovidDeaths
--Where location = 'India'
order by 1,2

--Looking at Countries with Highest Infection Rate compared to Population

Select location, population, Max(total_cases) as HighestInfectionCount, 
  Max(total_cases/population)*100 as PercentPopulationInfected
From PortfolioProject1..CovidDeaths
--Where location = 'India'
Group by location, population
order by PercentPopulationInfected desc

--Showing countries with Highest Death Count per populations

Select location, Max(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject1..CovidDeaths
--Where location = 'India'
where continent is not null
Group by location
order by TotalDeathCount desc

--Let's break things down by continent

Select location, Max(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject1..CovidDeaths
--Where location = 'India'
where continent is null
Group by location
order by TotalDeathCount desc


--Global Numbers

Select SUM(new_cases), SUM(cast(new_deaths as int)), (SUM(cast(new_deaths as int))/SUM(new_cases))*100 as DeathPercentage
From PortfolioProject1..CovidDeaths
--Where location = 'India'
where continent is not null
--Group by date
order by 1,2



--Looking at Total Populations vs Vaccinations

Select dea.continent, dea.location,dea.date, dea.population, vac.new_vaccinations
, SUM(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location
, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100 
From PortfolioProject1..CovidDeaths dea
join PortfolioProject1..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3


--Use CTE

with PopvsVac(Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location,dea.date, dea.population, vac.new_vaccinations
, SUM(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location
, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100 
From PortfolioProject1..CovidDeaths dea
join PortfolioProject1..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
Select * , (RollingPeopleVaccinated/population)*100 
From PopvsVac


--Temp Table

Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccination numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location,dea.date, dea.population, vac.new_vaccinations
, SUM(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location
, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100 
From PortfolioProject1..CovidDeaths dea
join PortfolioProject1..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null
--order by 2,3


Select * , (RollingPeopleVaccinated/population)*100 
From #PercentPopulationVaccinated


--Creating view to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location,dea.date, dea.population, vac.new_vaccinations
, SUM(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location
, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100 
From PortfolioProject1..CovidDeaths dea
join PortfolioProject1..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3


Select *
From PercentPopulationVaccinated