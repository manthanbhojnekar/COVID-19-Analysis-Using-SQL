-- Creating tables to export the .csv file into
CREATE TABLE covid_deaths(
	iso_code VARCHAR(20),
	continent VARCHAR(20),
	location VARCHAR(50),
	date DATE,
	population BIGINT,
	total_cases INTEGER,
	new_cases INTEGER,
	new_cases_smoothed DOUBLE PRECISION,
	total_deaths INTEGER,
	new_deaths INTEGER,
	new_deaths_smoothed DOUBLE PRECISION,
	total_cases_per_million DOUBLE PRECISION,
	new_cases_per_million DOUBLE PRECISION,
	new_cases_smoothed_per_million DOUBLE PRECISION,
	total_deaths_per_million DOUBLE PRECISION,
	new_deaths_per_million DOUBLE PRECISION,
	new_deaths_smoothed_per_million DOUBLE PRECISION,
	reproduction_rate DOUBLE PRECISION,
	icu_patients INTEGER,
	icu_patients_per_million DOUBLE PRECISION,
	hosp_patients INTEGER,
	hosp_patients_per_million DOUBLE PRECISION,
	weekly_icu_admissions DOUBLE PRECISION,
	weekly_icu_admissions_per_million DOUBLE PRECISION,
	weekly_hosp_admissions DOUBLE PRECISION,
	weekly_hosp_admissions_per_million DOUBLE PRECISION

)

SELECT * FROM covid_deaths

CREATE TABLE covid_vaccinations(
	iso_code VARCHAR(20),
	continent VARCHAR(20),
	location VARCHAR(50),
	date DATE,
	population BIGINT,	
	total_tests BIGINT,
	new_tests BIGINT,
	total_tests_per_thousand DOUBLE PRECISION,
	new_tests_per_thousand DOUBLE PRECISION,
	new_tests_smoothed DOUBLE PRECISION,
	new_tests_smoothed_per_thousand DOUBLE PRECISION,
	positive_rate DOUBLE PRECISION,
	tests_per_case DOUBLE PRECISION,
	tests_units VARCHAR(30),
	total_vaccinations BIGINT,
	people_vaccinated BIGINT,
	people_fully_vaccinated BIGINT,
	total_boosters BIGINT,
	new_vaccinations BIGINT,
	new_vaccinations_smoothed DOUBLE PRECISION,
	total_vaccinations_per_hundred DOUBLE PRECISION,
	people_vaccinated_per_hundred DOUBLE PRECISION,
	people_fully_vaccinated_per_hundred DOUBLE PRECISION,
	total_boosters_per_hundred DOUBLE PRECISION,
	new_vaccinations_smoothed_per_million DOUBLE PRECISION,
	new_people_vaccinated_smoothed DOUBLE PRECISION,
	new_people_vaccinated_smoothed_per_hundred DOUBLE PRECISION,
	stringency_index DOUBLE PRECISION,
	population_density DOUBLE PRECISION,
	median_age DOUBLE PRECISION,
	aged_65_older DOUBLE PRECISION,
	aged_70_older DOUBLE PRECISION,
	gdp_per_capita DOUBLE PRECISION,
	extreme_poverty DOUBLE PRECISION,
	cardiovasc_death_rate DOUBLE PRECISION,
	diabetes_prevalence DOUBLE PRECISION,
	female_smokers DOUBLE PRECISION,
	male_smokers DOUBLE PRECISION,
	handwashing_facilities DOUBLE PRECISION,
	hospital_beds_per_thousand DOUBLE PRECISION,
	life_expectancy DOUBLE PRECISION,
	human_development_index DOUBLE PRECISION,
	excess_mortality_cumulative_absolute DOUBLE PRECISION,
	excess_mortality_cumulative DOUBLE PRECISION,
	excess_mortality DOUBLE PRECISION,
	excess_mortality_cumulative_per_million DOUBLE PRECISION

)

-- Taking a look at data to check if everything was imported successfully
SELECT * FROM covid_vaccinations
ORDER BY location, date


-- Selecting data that we'll be using
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM covid_deaths
ORDER BY location, date


-- Looking at total cases vs total deaths
-- Shows the likelihood of dying if you get infected in Canada
SELECT location, date, total_cases, total_deaths, 
(CAST(total_deaths AS DECIMAL) / total_cases) * 100 AS death_percent
FROM covid_deaths
WHERE location = 'Canada'
ORDER BY location, date


-- Looking at total cases vs Population
-- Shows the percentage of the population that got infected
SELECT location, date, total_cases, population, 
(CAST(total_deaths AS DECIMAL) / population) * 100 AS percent_pop_infected
FROM covid_deaths
WHERE location = 'Canada'
ORDER BY location, date 


-- Countries with the highest infection rate compared to the population
SELECT location, population, MAX(total_cases) AS highest_infec_count, 
MAX(CAST(total_cases AS DECIMAL) / population) * 100 AS percent_pop_infected
FROM covid_deaths
GROUP BY location, population
ORDER BY percent_pop_infected DESC


-- Countries with the highest death count
SELECT location, MAX(total_deaths) AS highest_death_count 
FROM covid_deaths
WHERE continent IS NOT NULL 
GROUP BY location
HAVING MAX(total_deaths) IS NOT NULL
ORDER BY highest_death_count DESC


-- Continents with the highest death count
SELECT location, MAX(total_deaths) AS highest_death_count 
FROM covid_deaths
WHERE continent IS NULL 
GROUP BY location
ORDER BY highest_death_count DESC


-- Total global cases and deaths
SELECT date, SUM(new_cases) AS total_cases, SUM(new_deaths) AS total_deaths,
NULLIF(CAST(SUM(new_deaths) AS DECIMAL),0)/NULLIF(SUM(new_cases),0) * 100 AS death_percent
FROM covid_deaths
GROUP BY date
ORDER BY date

-- CUMULATIVE VACCINATION
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date)
AS cumulative_vac
FROM covid_deaths AS dea
JOIN covid_vaccinations AS vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY location, date

