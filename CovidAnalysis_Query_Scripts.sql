-- Verifying and viewning both tables before analysis
-- (ordered by location and date for convinience)
select * 
from coviddeaths
order by 3,4

select * 
from covidvaccinations
order by 3,4

-- selecting out the columns for analysis
select location, date, total_cases, new_cases, total_deaths, population
from coviddeaths
order by 1,2

--checking total cases vs total deaths
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as death_percentage
from coviddeaths
where location like '%States'
order by 1,2

--checking total cases vs population
--percentage of the population that got covid
select location, date, total_cases, population, 
TO_CHAR((total_cases / population) * 100, '9.9999EEEE') as PopulationPercent
from coviddeaths
where location like '%States'
order by 1,2

--countries with highest infection rates
select location, population , max(total_cases) as HighestInfectionCount,
max((total_cases / population)) * 100 as InfectedPopulationPercent
from coviddeaths
where total_cases IS NOT NULL AND population IS NOT NULL
group by location, population
order by InfectedPopulationPercent desc

--countries with highest death rates
select location, population, max(total_deaths) as highest_death_count, 
max((total_deaths/total_cases))*100 as death_percentage
from coviddeaths
where total_deaths IS NOT NULL AND population IS NOT NULL
group by location, population
order by highest_death_count desc

--countries with highest death count per population
select location, max(total_deaths) as total_death_count
from coviddeaths
where total_deaths IS NOT NULL AND continent IS NOT NULL
group by location
order by total_death_count desc

--now by continent (inaccurate from database)
select continent, max(total_deaths) as total_death_count
from coviddeaths
where total_deaths IS NOT NULL 
group by continent
order by total_death_count desc

--by continent
select location, max(total_deaths) as total_death_count
from coviddeaths
where total_deaths IS NOT NULL AND continent IS NULL
group by location
order by total_death_count desc

--Global Death Percent
select date, sum(new_cases) as new_cases, sum(new_deaths)as new_deaths, 
sum(new_deaths)/sum(new_cases)*100 as death_percentage
from coviddeaths
where new_cases<>0
group by date
order by 1,2

--total population vs vaccination
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(new_vaccinations) over (partition by dea.location order by dea.date) as Cumulative_People_Vaccinated,
--max(Cumulative_People_Vaccinated)/population*100 as Vaccinated_Population_Percent
from coviddeaths dea
join covidvaccinations vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null
order by 2,3

--Use CTE
with popvsvac(continent, location, date, population, new_vac, cumulative_people_vaccinated)
as
(
	select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(new_vaccinations) over (partition by dea.location order by dea.date) as Cumulative_People_Vaccinated

from coviddeaths dea
join covidvaccinations vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null
--order by 2,3 (cannot use order by in cte)
	)
	select *, Cumulative_People_Vaccinated/population*100 as Vaccinated_Population_Percent
	from popvsvac
	
--creating views for storing data for visualization
create view percent_population_vaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(new_vaccinations) over (partition by dea.location order by dea.date) as Cumulative_People_Vaccinated
--max(Cumulative_People_Vaccinated)/population*100 as Vaccinated_Population_Percent
from coviddeaths dea
join covidvaccinations vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null

select *
from percent_population_vaccinated



