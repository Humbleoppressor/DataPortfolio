SELECT  location, date,population , total_cases,new_cases, total_deaths,
FROM `portfolio1-384911.Covid19.covid_deaths`
WHERE continent is NOT NULL 
ORDER BY 1,2

--total cases vs total death--
--chances of death in different locations, just change the value of lopcation--
SELECT  location, date,population , total_cases, total_deaths,(total_deaths/total_cases)*100 AS death_percent,
FROM `portfolio1-384911.Covid19.covid_deaths`
WHERE continent is NOT NULL
AND location ='India'
ORDER BY 1,2

--total people affected in a location--
SELECT  location, date,population , total_cases,(total_cases/population)*100 AS infected_percent,
FROM `portfolio1-384911.Covid19.covid_deaths`
WHERE continent is NOT NULL
AND location ='India'
ORDER BY 1,2

--most effected location wrt to population in a day --
SELECT  location,population , MAX(total_cases) AS highest_case,MAX((total_cases/population))*100 AS infected_percent,
FROM `portfolio1-384911.Covid19.covid_deaths`
GROUP BY population, location 
WHERE continent is NOT NULL
ORDER BY infected_percent DESC

--most effected in terms of death in a day wrt to population--
SELECT  location,population , MAX(total_deaths) AS highest_case,MAX((total_deaths/population))*100 AS death_percent,
FROM `portfolio1-384911.Covid19.covid_deaths`
WHERE continent is NOT NULL
GROUP BY population, location 
ORDER BY death_percent DESC

--highest death in a country in a day--
SELECT location, MAX(total_deaths) AS deaths
FROM `portfolio1-384911.Covid19.covid_deaths`
WHERE continent is NOT NULL
GROUP BY location
Order By deaths DESC

--highest deaths by continent in a day--
SELECT continent, MAX(total_deaths) AS deaths
FROM `portfolio1-384911.Covid19.covid_deaths`
WHERE continent is NULL
GROUP BY continent
Order By deaths DESC

--death by continent--
SELECT location, MAX(total_deaths) AS deaths
FROM `portfolio1-384911.Covid19.covid_deaths`
WHERE continent is NULL
GROUP BY location
Order By deaths DESC

--world wide--
SELECT SUM(new_cases) AS total_case,SUM(new_deaths) AS total_deaths,(SUM(new_deaths)/SUM(new_cases))*100 AS death_percent
FROM `portfolio1-384911.Covid19.covid_deaths`
WHERE continent is NOT NULL
--GROUP by date
ORDER BY 1,2

--covid vaccine--
--total population VS total vaccination, also using rolling count--
SELECT dea.continent, dea.location,dea.date,dea.population,vac.new_vaccinations, SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeople
FROM `portfolio1-384911.Covid19.covid_deaths` dea
JOIN `portfolio1-384911.Covid19.covid_vaccine` vac
 ON dea.location=vac.location
 AND dea.date=vac.date
WHERE dea.continent is NOT NULL
ORDER by 2,3

--Using with and temp tables--
--usinh with--
WITH popvsvac (continent,location,date,population,new_vaccinations,RollingPeople) AS
(
SELECT dea.continent, dea.location,dea.date,dea.population,vac.new_vaccinations, SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeople
FROM `portfolio1-384911.Covid19.covid_deaths` dea
JOIN `portfolio1-384911.Covid19.covid_vaccine` vac
 ON dea.location=vac.location
 AND dea.date=vac.date
WHERE dea.continent is NOT NULL
--ORDER by 2,3--
)
SELECT*,(RollingPeople/population)*100 
FROM popvsvac

--Temp Table--
CREATE TEMP TABLE Perecent_Populated_Vaccine (
  continent STRING,
  location STRING,
  date DATE,
  population INT64,
  new_vaccination INT64,
  RollingPeople FLOAT64
);

INSERT INTO Perecent_Populated_Vaccine (continent, location, date, population, new_vaccination, RollingPeople)
SELECT 
  dea.continent, 
  dea.location, 
  dea.date, 
  dea.population, 
  vac.new_vaccinations, 
  SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeople
FROM `portfolio1-384911.Covid19.covid_deaths` dea
JOIN `portfolio1-384911.Covid19.covid_vaccine` vac
ON dea.location=vac.location
AND dea.date=vac.date
WHERE dea.continent is NOT NULL;

SELECT *, (RollingPeople/population)*100 
FROM Perecent_Populated_Vaccine;

--Dropping table--
DROP TABLE IF EXISTS Perecent_Populated_Vaccine;

--creating VIEWS tio store later for visualtions--
CREATE VIEW Perecent_Populated_Vaccine.covid_deaths_vaccinations AS 
SELECT 
  dea.continent, 
  dea.location,
  dea.date,
  dea.population,
  vac.new_vaccinations,
  SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeople
FROM `portfolio1-384911.Covid19.covid_deaths` dea
JOIN `portfolio1-384911.Covid19.covid_vaccine` vac
 ON dea.location=vac.location
 AND dea.date=vac.date
WHERE dea.continent is NOT NULL;

--ORDER by 2,3--