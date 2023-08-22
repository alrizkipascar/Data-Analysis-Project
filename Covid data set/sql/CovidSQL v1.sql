SELECT *
FROM YoutubeProject..CovidDeaths
WHERE continent is not null
ORDER BY 3,4


SELECT *
FROM YoutubeProject..CovidVaccinations
ORDER BY 3,4


SELECT location, date, total_cases, new_cases, total_deaths, population
FROM YoutubeProject..CovidDeaths
WHERE location like '%indo%'
AND continent IS NOT NULL
ORDER BY 1,2

--percentage Indo
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM YoutubeProject..CovidDeaths
WHERE location like '%indo%'
AND continent is not null
ORDER BY 1,2


--total cases vs population
SELECT location, date, population, total_cases,  (total_cases/population)*100 as DeathPercentage
FROM YoutubeProject..CovidDeaths
WHERE location like '%indo%'
ORDER BY 1,2


--infection rate
SELECT location, population, MAX(total_cases) as HighestInfectionCount,  MAX((total_cases/population))*100 as 
PercentagePopulationInfected
FROM YoutubeProject..CovidDeaths
GROUP BY location, population
--WHERE location like '%indo%'
ORDER BY PercentagePopulationInfected desc


--showing countries with highest death count per population

SELECT location,  MAX(cast(total_deaths as int)) as HighestDeathCount
FROM YoutubeProject..CovidDeaths
WHERE continent is not null
GROUP BY location
--WHERE location like '%indo%'
ORDER BY HighestDeathCount desc

-- death count by location
SELECT location,  MAX(cast(total_deaths as int)) as HighestDeathCount
FROM YoutubeProject..CovidDeaths
WHERE continent is null
GROUP BY location
--WHERE location like '%indo%'
ORDER BY HighestDeathCount desc

-- death continent by continent
SELECT continent,  MAX(cast(total_deaths as int)) as HighestDeathCount
FROM YoutubeProject..CovidDeaths
WHERE continent is not null
GROUP BY continent
--WHERE location like '%indo%'
ORDER BY HighestDeathCount desc


--global number
SELECT  date, SUM(new_cases) as TotalCases, SUM(CAST(new_deaths as int)) as TotalDeath, 
(SUM(CAST(new_deaths as int))/SUM(new_cases))*100 as DeathPercentage  --, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM YoutubeProject..CovidDeaths
WHERE continent is not null
GROUP BY date
ORDER BY 1,2


--Total Global Number
SELECT SUM(new_cases) as TotalCases, SUM(CAST(new_deaths as int)) as TotalDeath, 
(SUM(CAST(new_deaths as int))/SUM(new_cases))*100 as DeathPercentage  --, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM YoutubeProject..CovidDeaths
WHERE continent is not null
--GROUP BY date
ORDER BY 1,2


-- looking at total population vs vaccination
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations as int)) 
		OVER(Partition BY dea.location 
		ORDER BY dea.location,dea.date) as RollingPeopleVaccinated
FROM YoutubeProject..CovidDeaths as dea
JOIN YoutubeProject..CovidVaccinations as vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3




--CTE
WITH PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as (
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations as bigint)) 
		OVER(Partition BY dea.location 
		ORDER BY dea.location,dea.date) as RollingPeopleVaccinated
FROM YoutubeProject..CovidDeaths as dea
JOIN YoutubeProject..CovidVaccinations as vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3
)

SELECT *,(RollingPeopleVaccinated/Population)*100
From PopvsVac



-- Using Temp Table to perform Calculation on Partition By in previous query

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
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM YoutubeProject..CovidDeaths as dea
JOIN YoutubeProject..CovidVaccinations as vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated


DROP VIEW if exists PercentPopulationVaccinated
USE YoutubeProject
GO

CREATE VIEW PercentPopulationVaccinated AS 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM YoutubeProject..CovidDeaths as dea
JOIN YoutubeProject..CovidVaccinations as vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3


Select *
From PercentPopulationVaccinated