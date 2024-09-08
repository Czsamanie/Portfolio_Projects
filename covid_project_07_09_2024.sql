SELECT * 
FROM coviddeaths

SELECT * 
FROM coviddeaths dea
JOIN covidvaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date

--LOoking at total population versus vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location,
dea.date) AS RollingPeopleVaccinated
FROM coviddeaths dea
JOIN covidvaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2, 3

-- Creating a table from the lastest query result
-- Using CTE

WITH NewPopVac(continent, location, date, population,new_vaccinations, RollingPeopleVaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location,
dea.date) AS RollingPeopleVaccinated
FROM coviddeaths dea
JOIN covidvaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2, 3
)
SELECT *, (rollingpeoplevaccinated/population)*100 AS vaccperc
FROM NewPopVac


-- Using a Temp table

DROP TABLE IF EXISTS PercPopVacc
CREATE TABLE PercPopVacc
(
continent text,
location text,
date date,
population numeric,
new_vaccinations numeric,
rollingpeoplevaccinated numeric
)
INSERT INTO PercPopVacc
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location,
dea.date) AS RollingPeopleVaccinated
FROM coviddeaths dea
JOIN covidvaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2, 3

SELECT *, (rollingpeoplevaccinated/population)*100 AS vaccperc
FROM PercPopVacc

-- Creating View to store data for later visualizations

CREATE VIEW PercPopVacc_VIEW AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location,
dea.date) AS RollingPeopleVaccinated
FROM coviddeaths dea
JOIN covidvaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2, 3


-- View for continent and total death count

CREATE VIEW continentdeaths_view AS
SELECT continent, MAX(total_deaths) AS Total_death_count
FROM coviddeaths
WHERE continent IS NOT NULL
GROUP BY 1
ORDER BY 2 DESC NULLS LAST


-- View for countries and total/ max death count

CREATE VIEW countriesdeaths_view AS
SELECT location, MAX(total_deaths) AS Total_death_count
FROM coviddeaths
WHERE continent IS NOT NULL
GROUP BY 1
ORDER BY 2 DESC NULLS LAST