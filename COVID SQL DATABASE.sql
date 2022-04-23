SELECT *
FROM [COVID PROJECT]..['covid death$']
WHERE continent is not null
ORDER BY 3,4

--SELECT *
--FROM [COVID PROJECT]..['covid vaccine$']
--ORDER BY 3,4

--select Data that we are going to be using

SELECT location,date,total_cases,new_cases,total_deaths,population
FROM [COVID PROJECT]..['covid death$']
WHERE continent is not null
ORDER BY 1,2

--Looking at Total Cases vs Total Deaths
--shows likelihood of dying if you contract covid in your country

SELECT location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
FROM [COVID PROJECT]..['covid death$']
WHERE continent is not null
WHERE location like '%nigeria%'
ORDER BY 1,2

--Looking at Total Cases vs Population
--shows what percentage of population got coivd

SELECT location,date,total_cases,population,(total_cases/Population)*100 as PopulationInfected
FROM [COVID PROJECT]..['covid death$']
WHERE continent is not null
WHERE location like '%nigeria%'
ORDER BY 1,2

--Looking at Countries with highest infection rate compared to population

SELECT location,Population, MAX(total_cases) AS HighestInfectedCountry,MAX((total_cases/Population))*100 as PercentPopulationInfected
FROM [COVID PROJECT]..['covid death$']
--WHERE location like '%nigeria%'
WHERE continent is not null
GROUP BY location,Population
ORDER BY PercentPopulationInfected DESC

--Showing Countries with Highest Death Count per Population

SELECT location, MAX(CAST(total_deaths AS INT)) AS TotalDeathCount
FROM [COVID PROJECT]..['covid death$']
--WHERE location like '%nigeria%'
WHERE continent is not null
GROUP BY location
ORDER BY TotalDeathCount DESC

--LETS BREAK THINGS DOWN BY CONTINENT
--Showing Continents With Highest Death Count Per Population

SELECT continent, MAX(CAST(total_deaths AS INT)) AS TotalDeathCount
FROM [COVID PROJECT]..['covid death$']
--WHERE location like '%nigeria%'
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount DESC

--Global Numbers

--Showing Global Daily Cases,Deaths and Death Percentages

SELECT date, SUM(new_cases)AS Totalcases, sum(cast(new_deaths AS INT)) AS TotalDeaths, sum(cast(new_deaths AS INT))/sum(new_cases)*100 as DeathPercentage
FROM [COVID PROJECT]..['covid death$']
WHERE continent is not null
--WHERE location like '%nigeria%'
GROUP BY date
ORDER BY 1,2

--Showing Global Total Cases,Total Deaths and Death Percentages

SELECT SUM(new_cases)AS Totalcases, sum(cast(new_deaths AS INT)) AS TotalDeaths, sum(cast(new_deaths AS INT))/sum(new_cases)*100 as DeathPercentage
FROM [COVID PROJECT]..['covid death$']
WHERE continent is not null
--WHERE location like '%nigeria%'
--GROUP BY date
ORDER BY 1,2

--Looking at Total Population VS Vaccinations

SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(CONVERT(INT,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location,dea.date) AS RollingPeaopleVaccinated
--(RollingPeopleVaccinated/Population)*100
FROM [COVID PROJECT]..['covid death$'] dea
JOIN [COVID PROJECT]..['covid vaccine$'] vac
   ON dea.location = vac.location
   AND dea.date = vac.date
   WHERE dea.continent is not null
   ORDER BY 2,3

--USE CTE

WITH PopvsVac (continent,Location,date,population,new_vaccinations,RollingPeopleVaccinated)
AS
(
SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(CONVERT(INT,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location,dea.date) AS RollingPeaopleVaccinated
--(RollingPeopleVaccinated/Population)*100
FROM [COVID PROJECT]..['covid death$'] dea
JOIN [COVID PROJECT]..['covid vaccine$'] vac
   ON dea.location = vac.location
   AND dea.date = vac.date
   WHERE dea.continent is not null
   --ORDER BY 2,3
)
SELECT *, (RollingPeopleVaccinated/Population)*100
FROM PopvsVac

--Term Table

DROP TABLE if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccination numeric,
RollingPeopleVaccinated numeric
)

Insert Into #PercentPopulationVaccinated
SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(CONVERT(INT,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location,dea.date) AS RollingPeaopleVaccinated
--(RollingPeopleVaccinated/Population)*100
FROM [COVID PROJECT]..['covid death$'] dea
JOIN [COVID PROJECT]..['covid vaccine$'] vac
   ON dea.location = vac.location
   AND dea.date = vac.date
   --WHERE dea.continent is not null
   --ORDER BY 2,3

SELECT *, (RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated


--Creating View To store Data for later Visualization

CREATE VIEW PercentPopulationVaccinated AS 
SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(CONVERT(INT,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location,dea.date) AS RollingPeaopleVaccinated
--(RollingPeopleVaccinated/Population)*100
FROM [COVID PROJECT]..['covid death$'] dea
JOIN [COVID PROJECT]..['covid vaccine$'] vac
   ON dea.location = vac.location
   AND dea.date = vac.date
   WHERE dea.continent is not null
   --ORDER BY 2,3
