## CREATE DATABASE PortfolioProject_COVID19;
## Data imported from Excel
## SHOW TABLES;

SELECT 
	location, 
	date, 
	total_cases, 
    new cases, 
    total_deaths, 
    population 
FROM covid_deaths
ORDER BY 1,2;

## Looking at Total Cases vs Total Deaths
## Shows likelihood of dying if you contract COVID in your country
SELECT 
	location, 
    date, 
    total_cases, 
    total_deaths,
    (total_deaths/total_cases)*100 AS Death_Percentage
FROM covid_deaths 
## WHERE location like '%kingdom%'
WHERE continent <> ''
ORDER BY 1,2;

## Looking at Total Cases vs Population
## Shows what percentage of the population got COVID
SELECT 
	location, 
    date, 
    population,
    total_cases, 
    (total_cases/population)*100 AS Infected_Percentage
FROM covid_deaths 
## WHERE location like '%kingdom%'
WHERE continent <> ''
ORDER BY 4;

## Looking at Countries with Highest Infection Rate compared to Population
SELECT 
	location, 
    population,
    MAX(total_cases) AS Highest_Infection_Count, 
    MAX((total_cases/population))*100 AS Infected_Percentage
FROM covid_deaths 
## WHERE location like '%kingdom%'
WHERE continent <> ''
GROUP BY location, population
ORDER BY Infected_Percentage DESC;

## Showing Countries with Highest Death Count per Population
SELECT 
    location,
    MAX(CAST(NULLIF(total_deaths, '') AS UNSIGNED)) AS Total_Death_Count
FROM covid_deaths
WHERE continent <> ''
GROUP BY location
ORDER BY Total_Death_Count DESC;

## LET'S BREAK THINGS DOWN BY CONTINENT
## Showing the Continents with the Highest Death Count
SELECT 
    continent,
    MAX(CAST(NULLIF(total_deaths, '') AS UNSIGNED)) AS Total_Death_Count
FROM covid_deaths
WHERE continent <> ''
GROUP BY continent
ORDER BY Total_Death_Count DESC;

## GLOBAL NUMBERS
SELECT 
	date,
    SUM(new_cases) AS total_cases,
    SUM(CAST(NULLIF(new_deaths, '') AS UNSIGNED)) AS total_deaths,
    SUM(new_cases)/SUM(CAST(NULLIF(new_deaths, '') AS UNSIGNED))*100 AS Death_Percentage
FROM covid_deaths 
## WHERE location like '%kingdom%'
WHERE continent <> ''
GROUP BY date
ORDER BY 1,2;

SELECT 
	SUM(new_cases) AS total_cases,
    SUM(CAST(NULLIF(new_deaths, '') AS UNSIGNED)) AS total_deaths,
    SUM(new_cases)/SUM(CAST(NULLIF(new_deaths, '') AS UNSIGNED))*100 AS Death_Percentage
FROM covid_deaths 
## WHERE location like '%kingdom%'
WHERE continent <> ''
## GROUP BY date
ORDER BY 1,2;

## Looking at Total Population vs Vaccinations
SELECT
    d.continent,
    d.location,
    d.date,
    d.population,
    v.new_vaccinations,
    SUM(CAST(NULLIF(v.new_vaccinations, '') AS UNSIGNED))
        OVER (
            PARTITION BY d.location
            ORDER BY d.location, d.date
        ) AS rolling_vaccinations
FROM covid_deaths d
JOIN covid_vacc v
    ON d.location = v.location
   AND d.date = v.date
WHERE d.continent <> ''
ORDER BY 2,3;

WITH PopvsVac (continent, location, date, population, new_vaccinations, Rolling_People_Vaccinated) 
AS
(
SELECT
    d.continent,
    d.location,
    d.date,
    d.population,
    v.new_vaccinations,
    SUM(CAST(NULLIF(v.new_vaccinations, '') AS UNSIGNED))
        OVER (
            PARTITION BY d.location
            ORDER BY d.location, d.date
        ) AS rolling_vaccinations
FROM covid_deaths d
JOIN covid_vacc v
    ON d.location = v.location
   AND d.date = v.date
WHERE d.continent <> ''
ORDER BY 2,3
)
SELECT
	*,
    (Rolling_People_Vaccinated/population)*100 AS Vaccinated_Percentage
FROM PopvsVac
ORDER BY location, date;

## TEMP TABLE

DROP TABLE IF EXISTS percent_population_vaccinated;
CREATE TABLE percent_population_vaccinated
(
Continent VARCHAR(255),
Location VARCHAR(255),
Date DATE,
Population INT,
New_Vaccinations INT,
Rolling_People_Vaccinated INT
);

## Creating View to store data for later visualisations

CREATE VIEW total_continent_death_count AS
SELECT 
    continent,
    MAX(CAST(NULLIF(total_deaths, '') AS UNSIGNED)) AS Total_Death_Count
FROM covid_deaths
WHERE continenttotal_continent_death_count <> ''
GROUP BY continent
ORDER BY Total_Death_Count DESC;

CREATE VIEW death_count_percentage AS
SELECT 
	location, 
    date, 
    total_cases, 
    total_deaths,
    (total_deaths/total_cases)*100 AS Death_Percentage
FROM covid_deaths 
WHERE continent <> ''
ORDER BY 1,2;

CREATE VIEW infection_rate_percentage AS
SELECT 
	location, 
    date, 
    population,
    total_cases, 
    (total_cases/population)*100 AS Infected_Percentage
FROM covid_deaths 
WHERE continent <> ''
ORDER BY 4;

CREATE VIEW population_vs_vaccinations AS
SELECT
    d.continent,
    d.location,
    d.date,
    d.population,
    v.new_vaccinations,
    SUM(CAST(NULLIF(v.new_vaccinations, '') AS UNSIGNED))
        OVER (
            PARTITION BY d.location
            ORDER BY d.location, d.date
        ) AS rolling_vaccinations
FROM covid_deaths d
JOIN covid_vacc v
    ON d.location = v.location
   AND d.date = v.date
WHERE d.continent <> ''
ORDER BY 2,3;