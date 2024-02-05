SELECT *
FROM CovidDB..CovidDeaths$
ORDER by 3, 4

--SELECT *
--FROM CovidDB..CovidVaccinations$
--ORDER by 3, 4

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM CovidDB..CovidDeaths$
ORDER by 1, 2

-- Looking at Total Cases vs Total Deaths

SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as death_percentage
FROM CovidDB..CovidDeaths$
WHERE location = 'Portugal'
ORDER by 1, 2

-- Looking at Total Cases vs Population (% of population got Covid)

CREATE VIEW percent_population_infected as
	SELECT Location, date, total_cases, total_deaths, (total_cases/population)*100 as infection_percentage
	FROM CovidDB..CovidDeaths$
	WHERE location = 'Portugal'

-- Looking at Countries with Highest Infection Rate vs Population

SELECT Location, Population, MAX(total_cases) as highest_infection_count, MAX(total_cases/population)*100 as infection_percentage
FROM CovidDB..CovidDeaths$
GROUP by Location, Population
ORDER by infection_percentage desc

-- Looking at Countries with Highest Death Count vs Population

SELECT Location, Population, MAX(cast(total_deaths as int)) as total_death_count
FROM CovidDB..CovidDeaths$
WHERE continent is not null
GROUP by Location, Population
ORDER by total_death_count desc

-- Looking at Highest Death Count aggregated by Continent

SELECT Location, MAX(cast(total_deaths as int)) as total_death_count
FROM CovidDB..CovidDeaths$
WHERE continent is null
GROUP by Location
ORDER by total_death_count desc



SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations as int)) OVER (PARTITION by dea.location 
ORDER by dea.location, dea.date) as rolling_people_vaccinated
FROM CovidDB..CovidDeaths$ dea
JOIN CovidDB..CovidVaccinations$ vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
ORDER by 2,3