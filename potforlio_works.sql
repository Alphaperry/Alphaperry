--this shows the percentage death per infectef population and percentage infected per population in  cameroon cameroon.

select location, date, total_cases, total_deaths, population, (total_deaths/total_cases)*100 as death_percentage, (total_cases/population)*100 as infected_population_percentage
from PotfolioProject..covid_deaths
where total_deaths > 0 and  total_cases > 0 and location like '%came%'
order by 1, 2
 
--this shows the highest total infected population and percentage infected  per population in every country

select location, population, max(total_cases) as total_infected_pop, max(total_cases/population)*100 as 
percent_pop_infected
from PotfolioProject..covid_deaths 
where continent is not null
group by location, population
order by total_infected_pop desc 

--this gives the total cases and total deaths per continent

select continent,  max(total_cases) as total_cases, max(cast(total_deaths as int)) as total_deaths
from PotfolioProject..covid_deaths 
where continent is not null 
group by  continent
order by total_deaths desc 

select *
from PotfolioProject..covd_vaccinations

--joining the two tables and calculating the number of new cases and vaccinated people over time

select deaths.date, deaths.location, deaths.population, deaths.new_cases, vacs.new_vaccinations,
sum(deaths.new_cases) over (partition by vacs.location order by vacs.location, vacs.date ) as total_cases_overTime, 
sum(cast(vacs.new_vaccinations as float)) over (partition by deaths.location order by deaths.location, deaths.date)
as total_vaccinations_overTime
from PotfolioProject..covid_deaths deaths
join PotfolioProject..covd_vaccinations vacs
on deaths.location = vacs.location
and deaths.date = vacs.date


--creating a TEMP table so that we can use a column created in the above work to perform calcultions.
drop table #percentPopulationVaccinated
create table #percentPopulationVaccinated
(date datetime,
location varchar,
population numeric,
newCases numeric,
newVaccination numeric,
totalCasesOvertime nvarchar,
totalVaccinationOvertime numeric  )

insert into #percentPopulationVaccinated
select deaths.date, deaths.location, deaths.population, deaths.new_cases, vacs.new_vaccinations,
sum(deaths.new_cases) over (partition by vacs.location order by vacs.location, vacs.date ) as total_cases_overTime, 
sum(cast(vacs.new_vaccinations as float)) over (partition by deaths.location order by deaths.location, deaths.date)
as total_vaccinations_overTime
from PotfolioProject..covid_deaths deaths
join PotfolioProject..covd_vaccinations vacs
on deaths.location = vacs.location
and deaths.date = vacs.date

select *--, (totalVaccinationOvertime/population)
from #percentPopulationVaccinated