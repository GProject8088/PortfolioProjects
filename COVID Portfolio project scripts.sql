


SELECT LOCATION, DATE, TOTAL_CASES, NEW_CASES, TOTAL_DEATHS, POPULATION
FROM PortfolioProject..COVID_DEATHS
ORDER BY 1,2

-- Looking at Total Cases vs total Deaths
-- Shows likelihood of dying if you contract covid in your country

SELECT LOCATION, DATE, TOTAL_CASES, TOTAL_DEATHS, (Total_Deaths / Total_Cases)*100 as DeathPercentage
FROM PortfolioProject..COVID_DEATHS
Where location = 'United States'
ORDER BY 1,2 


-- Looking at Total Cases vs Population
-- Shows what percentage of population got Covid

SELECT LOCATION, DATE, Population, TOTAL_CASES,  (Total_Cases/Population) * 100 as PercentageOfPopulationInfected
FROM PortfolioProject..COVID_DEATHS
Where location = 'United States' 
ORDER BY 1,2 


-- Looking at countries with highest infection rate compared to population

SELECT LOCATION, Population, max(TOTAL_CASES) as HighestInfectionRate,   max((Total_Cases/Population) * 100) as PercentageOfPopulation
FROM PortfolioProject..COVID_DEATHS
where Continent is not null
group by LOCATION, Population
ORDER BY PercentageOfPopulation desc


-- Looking at countries with highest death rate 

SELECT LOCATION, max(cast(TOTAL_deaths as int)) as TotalDeathCount
FROM PortfolioProject..COVID_DEATHS
where Continent is not null
group by LOCATION
ORDER BY TotalDeathCount desc



-- Death count by continent
SELECT Continent, max(cast(TOTAL_deaths as int)) as TotalDeathCount
FROM PortfolioProject..COVID_DEATHS
where Continent is  not null
group by Continent
ORDER BY TotalDeathCount desc



-- Showing continents with highest death count

SELECT Continent, max(cast(TOTAL_deaths as int)) as TotalDeathCount
FROM PortfolioProject..COVID_DEATHS
where Continent is  not null
group by Continent
ORDER BY TotalDeathCount desc


-- Global numbers by day

SELECT  DATE, sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)* 100 as DeathPercentage
FROM PortfolioProject..COVID_DEATHS
Where Continent is  not null
group by date
ORDER BY 1,2 


-- Global numbers overall

SELECT   sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)* 100 as DeathPercentage
FROM PortfolioProject..COVID_DEATHS
Where Continent is  not null
ORDER BY 1,2 

-- Looking at Total Population vs Vaccinations
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations as vaccinationsPerDay, sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated,
from PortfolioProject..covid_deaths dea
join PortfolioProject..COVID_VACCINATIONS vac
  on dea.location = vac.location 
  and dea.date = vac.date
Where dea.Continent is  not null
order by 2,3


-- USE CTE
With PopVSVac (Continent, Location, date, population, New_Vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations as vaccinationsPerDay, sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
from PortfolioProject..covid_deaths dea
join PortfolioProject..COVID_VACCINATIONS vac
  on dea.location = vac.location 
  and dea.date = vac.date
Where dea.Continent is  not null
)
select *, (RollingPeopleVaccinated/Population) * 100 as PercentOfPopulationVaccinated
from PopVSVac



-- USE TEMP TABLE
Drop table if exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations as vaccinationsPerDay, sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
from PortfolioProject..covid_deaths dea
join PortfolioProject..COVID_VACCINATIONS vac
  on dea.location = vac.location 
  and dea.date = vac.date
Where dea.Continent is  not null

select *, (RollingPeopleVaccinated/Population) * 100 as PercentOfPopulationVaccinated
from #PercentPopulationVaccinated



-- Creating View to store data later visualizations
Create View PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations as vaccinationsPerDay, sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
from PortfolioProject..covid_deaths dea
join PortfolioProject..COVID_VACCINATIONS vac
  on dea.location = vac.location 
  and dea.date = vac.date
Where dea.Continent is  not null














