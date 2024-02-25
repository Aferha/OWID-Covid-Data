/*
Covid Cases Examination
Data gathered from "Our World In Data"
*/

--SELECT *
--FROM [OWID-CovidData]..CovidDeaths
--ORDER BY 3, 4

--SELECT *
--FROM [OWID-CovidData]..CovidVaccinations
--ORDER BY 3, 4

--------------------------------------------------------------------------------------------------------------------------
-- Select Data we are using

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM [OWID-CovidData]..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1, 2

--------------------------------------------------------------------------------------------------------------------------
-- Looking at Total Cases vs Total Deaths

SELECT LOCATION, date, total_cases, (total_deaths/total_cases)*100 AS DeathPercentage
FROM [OWID-CovidData]..CovidDeaths
WHERE location LIKE '%Mexico%' 
AND total_cases IS NOT NULL
AND continent IS NOT NULL
ORDER BY 1,2

--------------------------------------------------------------------------------------------------------------------------
-- Total Cases vs Population
-- Shows what percentage of population infected with Covid

SELECT location, date, Population, total_cases,  (total_cases/population)*100 AS PercentPopulationInfected
FROM [OWID-CovidData]..CovidDeaths
WHERE location LIKE '%states%' 
AND total_cases IS NOT NULL
AND continent IS NOT NULL
ORDER BY 1,2

--------------------------------------------------------------------------------------------------------------------------
-- Countries with Highest Infection Rate compared to Population

SELECT Location, Population, MAX(total_cases) AS HighestInfectionCount,  MAX((total_cases/population))*100 AS PercentPopulationInfected
FROM [OWID-CovidData]..CovidDeaths
--Where location like '%Mexico%'
WHERE total_cases IS NOT NULL
AND continent IS NOT NULL
GROUP BY Location, Population
ORDER BY PercentPopulationInfected DESC

--------------------------------------------------------------------------------------------------------------------------
-- Countries with Highest Death Count per Population

SELECT Location, MAX(Total_deaths) AS TotalDeathCount
--SELECT Location, MAX(CAST(Total_deaths AS INT)) AS TotalDeathCount
FROM [OWID-CovidData]..CovidDeaths
--WHERE location like '%Mexico%'
WHERE continent IS NOT NULL
GROUP BY Location
ORDER BY TotalDeathCount DESC

--------------------------------------------------------------------------------------------------------------------------
-- Continent Numbers

SELECT location, MAX(CAST(Total_deaths AS INT)) AS TotalDeathCount
FROM [OWID-CovidData]..CovidDeaths
--WHERE location LIKE '%Mexico%'
WHERE continent IS NULL
AND (location NOT LIKE '%income%'
AND location NOT LIKE '%union%')
GROUP BY location
ORDER BY TotalDeathCount DESC

--------------------------------------------------------------------------------------------------------------------------
-- Global Numbers

SELECT SUM(new_cases) AS total_cases, SUM(new_deaths) AS total_deaths, SUM(new_deaths)/SUM(New_Cases)*100 AS DeathPercentage
FROM [OWID-CovidData]..CovidDeaths
--WHERE location LIKE '%Mexico%'
WHERE continent IS NOT NULL 
--GROUP BY date
ORDER BY 1,2

--------------------------------------------------------------------------------------------------------------------------
-- Total Population vs Vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT (FLOAT,vac.new_vaccinations)) OVER (PARTITION BY dea.Location ORDER BY dea.location, dea.Date) AS RollingPeopleVaccinated
FROM [OWID-CovidData]..CovidDeaths dea
JOIN [OWID-CovidData]..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date 
WHERE new_vaccinations IS NOT NULL
AND dea.continent IS NOT NULL 
ORDER BY 2,3

--------------------------------------------------------------------------------------------------------------------------
-- Using CTE to perform Calculation on Partition By in previous query

WITH CTE_PopVsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT (FLOAT,vac.new_vaccinations)) OVER (PARTITION BY dea.Location ORDER BY dea.location, dea.Date) AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM [OWID-CovidData]..CovidDeaths dea
JOIN [OWID-CovidData]..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3
)
SELECT *, (RollingPeopleVaccinated/Population)*100 AS PopulationVaccinated
FROM CTE_PopVsVac

--------------------------------------------------------------------------------------------------------------------------
-- Using Temp Table to perform Calculation on Partition By in previous query

DROP TABLE IF EXISTS #Temp_PercentPopulationVaccinated
CREATE TABLE #Temp_PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #Temp_PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT (FLOAT,vac.new_vaccinations)) OVER (PARTITION BY dea.Location ORDER BY dea.location, dea.Date) AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM [OWID-CovidData]..CovidDeaths dea
JOIN [OWID-CovidData]..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
--WHERE dea.continent is not null 
--ORDER BY 2,3

SELECT *, (RollingPeopleVaccinated/Population)*100 AS PopulationVaccinated
FROM #Temp_PercentPopulationVaccinated

--------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------
-- Creating Views to store data for later visualizations

--------------------------------------------------------------------------------------------------------------------------
-- Global Numbers

CREATE VIEW GlobalNumbers AS
SELECT SUM(new_cases) AS total_cases, SUM(new_deaths) AS total_deaths, SUM(new_deaths)/SUM(New_Cases)*100 AS DeathPercentage
FROM [OWID-CovidData]..CovidDeaths
--WHERE location LIKE '%Mexico%'
WHERE continent IS NOT NULL 
--GROUP BY date
--ORDER BY 1,2

--------------------------------------------------------------------------------------------------------------------------
--Continents with Highest Death Count

CREATE VIEW ContinentNumbers AS
SELECT location, MAX(CAST(Total_deaths AS INT)) AS TotalDeathCount
FROM [OWID-CovidData]..CovidDeaths
--WHERE location LIKE '%Mexico%'
WHERE continent IS NULL
AND (location NOT LIKE '%income%'
AND location NOT LIKE '%union%')
GROUP BY location
--ORDER BY TotalDeathCount DESC

--------------------------------------------------------------------------------------------------------------------------
--
CREATE VIEW Temp_PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(FLOAT,vac.new_vaccinations)) OVER (PARTITION BY dea.Location ORDER BY dea.location, dea.Date) AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM [OWID-CovidData]..CovidDeaths dea
JOIN [OWID-CovidData]..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL

--------------------------------------------------------------------------------------------------------------------------
--
CREATE VIEW data AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT (FLOAT,vac.new_vaccinations)) OVER (PARTITION BY dea.Location ORDER BY dea.location, dea.Date) AS RollingPeopleVaccinated
FROM [OWID-CovidData]..CovidDeaths dea
JOIN [OWID-CovidData]..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date 
WHERE new_vaccinations IS NOT NULL
AND dea.continent IS NOT NULL 
--ORDER BY 2,3

