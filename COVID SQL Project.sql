-- Data quality check
SELECT * FROM [Portfolio Project]..CovidDeaths
order by 3,4

--SELECT * FROM [Portfolio Project]..CovidVaccinations
--order by 3,4

-- Selecting data that we are going to be using
SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM [Portfolio Project]..CovidDeaths
order by Location, date

-- Looking at total cases vs total deaths for Canada
SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS Death_Percentage
FROM [Portfolio Project]..CovidDeaths
where location = 'Canada'
and continent is NOT NULL
order by Location, date

-- Looking at Total cases vs Population
-- Shows what percentage of population got covid

SELECT Location, date, Population, total_cases, (total_cases/population)*100 AS Cases_Percentage
FROM [Portfolio Project]..CovidDeaths
where location = 'Canada'
and continent is NOT NULL
order by Location, date

-- Now lets look at total deaths vs population
-- shows the percentage of population who died from covid

SELECT Location, date, Population, total_deaths, (total_deaths/population)*100 AS Deaths_Percentage
FROM [Portfolio Project]..CovidDeaths
where location = 'Canada'
order by Location, date

-- Looking at countries with highest infection rate compared to population

SELECT Location, Population, MAX(total_cases) AS Highest_Infection_Cnt, 
MAX((total_cases/population))*100 AS Infected_Population_Percent
FROM [Portfolio Project]..CovidDeaths
--where location = 'Canada'
group by location, population
order by Infected_Population_Percent desc

-- Seeing countries with highest death count per population

SELECT Location, MAX(cast(total_deaths as int)) AS Total_Death_Cnt, 
MAX((total_deaths/population))*100 AS Total_Death_Percent
FROM [Portfolio Project]..CovidDeaths
--where location = 'Canada'
where continent is NOT NULL
group by location
order by Total_Death_Cnt desc

-- Breaking it down by continent
SELECT continent, MAX(cast(total_deaths as int)) AS Total_Death_Cnt, 
MAX((total_deaths/population))*100 AS Total_Death_Percent
FROM [Portfolio Project]..CovidDeaths
--where location = 'Canada'
where continent is NOT NULL
group by continent
order by Total_Death_Cnt desc

-- Looking at the numbers globally by date
SELECT date, SUM(new_cases) as Total_Cases, SUM(cast(new_deaths as int)) as Total_Deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 AS Death_Percentage
FROM [Portfolio Project]..CovidDeaths
where continent is NOT NULL
group by date
order by 1,2

-- Looking at the total number of cases and deaths globally
SELECT SUM(new_cases) as Total_Cases, SUM(cast(new_deaths as int)) as Total_Deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 AS Death_Percentage
FROM [Portfolio Project]..CovidDeaths
where continent is NOT NULL
order by 1,2


-- Seeing the total number of people vaccinated vs the population by date
-- Using CTE to calculate rolling_cnt_vaccinated
With PopvsVac (Continent, Location, Date, Population, new_vaccinations,Rolling_Cnt_Vaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vacc.new_vaccinations, 
SUM(cast(vacc.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location,
dea.date) as Rolling_Cnt_Vaccinated
--, (Rolling_Cnt_Vaccinated/population)*100
FROM [Portfolio Project]..[CovidVaccinations] vacc
JOIN [Portfolio Project]..[CovidDeaths] dea
ON dea.location = vacc.location 
and dea.date = vacc.date
where dea.continent is NOT NULL
--order by 2,3
)
select *, (Rolling_Cnt_Vaccinated/Population)*100
from PopvsVac

-- Seeing the total number of people vaccinated vs population by location
--Using CTE to calculate rolling_cnt_vaccinated
With PopvsVac (Continent, Location, Population, new_vaccinations,Rolling_Cnt_Vaccinated)
as
(
SELECT dea.continent, dea.location, dea.population, vacc.new_vaccinations, 
SUM(cast(vacc.new_vaccinations as bigint)) OVER (Partition by dea.location order by dea.location,
dea.date) as Rolling_Cnt_Vaccinated
--, (Rolling_Cnt_Vaccinated/population)*100
FROM [Portfolio Project]..[CovidVaccinations] vacc
JOIN [Portfolio Project]..[CovidDeaths] dea
ON dea.location = vacc.location 
and dea.date = vacc.date
where dea.continent is NOT NULL
--order by 2,3
)
select *, (Rolling_Cnt_Vaccinated/Population)*100
from PopvsVac

-- Creating TEMP Table
DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
Rolling_Cnt_Vaccinated numeric
)

Insert into #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vacc.new_vaccinations, 
SUM(cast(vacc.new_vaccinations as bigint)) OVER (Partition by dea.location order by dea.location,
dea.date) as Rolling_Cnt_Vaccinated
--, (Rolling_Cnt_Vaccinated/population)*100
FROM [Portfolio Project]..[CovidVaccinations] vacc
JOIN [Portfolio Project]..[CovidDeaths] dea
ON dea.location = vacc.location
and dea.date = vacc.date
where dea.continent is NOT NULL

select *, (Rolling_Cnt_Vaccinated/Population)*100 as percentage_vaccinated
from #PercentPopulationVaccinated

--Creating view to store data for visualization

Create view PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.population, vacc.new_vaccinations, 
SUM(cast(vacc.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location,
dea.date) as Rolling_Cnt_Vaccinated
--, (Rolling_Cnt_Vaccinated/population)*100
FROM [Portfolio Project]..[CovidVaccinations] vacc
JOIN [Portfolio Project]..[CovidDeaths] dea
ON dea.location = vacc.location 
--and dea.date = vacc.date
where dea.continent is NOT NULL
--order by 2,3
