select *
from PortfolioProject.dbo.covid_deaths
where location = 'world' 





--select *
--from PortfolioProject.dbo.covid_vaccination
--order by 3,4

select location,date,new_cases,total_cases,total_deaths,population
from PortfolioProject..covid_deaths
--where 
--total_deaths IS NOT NULL
order by 1,2

-- Looking at total cases vs total deaths

select location,date,new_cases,total_cases,total_deaths,population,(total_deaths/total_cases)*100 as deaths_vs_cases
from PortfolioProject..covid_deaths
where
--location like '%indi%' and
total_deaths is not null
order by 1,2

-- Looking at total cases vs population

select location,date,new_cases,total_cases,total_deaths,population,(total_cases/population)*100 as cases_vs_population
from PortfolioProject..covid_deaths
order by 1,2

-- looking at countries with highest infection rate compared to population

select location,MAX(total_cases) as highest_infection_count,population,(MAX(total_cases)/population)*100 as Highest_infection_rate
from PortfolioProject..covid_deaths

group by location,population
order by 4 DESC

-- looking at highest death count country wise
select location,MAX(cast(total_deaths as int)) as highest_death_count,population
from PortfolioProject..covid_deaths
where continent is not null
group by location,population
order by  2 DESC



-- Looking at highest death rate vs population

select location,MAX(cast(total_deaths as int)) as highest_death_count,population,(MAX(cast (total_deaths as int))/population)*100 as Highest_death_rate
from PortfolioProject..covid_deaths
where continent is not null
group by location,population
order by  2 DESC

--Looking at total death count continents wise 

select continent,SUM(cast(total_deaths as int)) as total_death_count
from PortfolioProject..covid_deaths
where continent is not null
group by continent
order by  2 DESC

-- Looking at death percentage wrt population continent wise

select continent,SUM(cast(total_deaths as int)) as total_death_count, sum(population) as total_population, (sum(cast(total_deaths as int))/sum(population)) as death_percentage
from PortfolioProject..covid_deaths
where continent is not null
group by continent
order by  2 DESC

-- Looking at Global Numbers (Death rate)

select location,max(cast(total_deaths as bigint)) as max_death_count,max(population) as max_world_population, (max(cast(total_deaths as bigint))/max(population))*100 as max_death_rate,
max(cast(total_cases as bigint)) as total_cases_count, (max(cast(total_cases as bigint))/max(population))*100 as cases_rate
from PortfolioProject..covid_deaths
where location = 'World'
group by location
order by  2 DESC

-- Looking at Global Numbers (total cases)

select location,max(cast(total_cases as bigint)) as total_cases_count,max(population) as max_world_population, (max(cast(total_cases as bigint))/max(population))*100 as cases_rate
from PortfolioProject..covid_deaths
where location = 'World'
group by location
order by  2 DESC

-- Looking at global numbers by date wise

select date,sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths,(sum(cast(new_deaths as int))/sum(new_cases))*100 as death_vs_cases
from PortfolioProject..covid_deaths
where continent is not null and
new_cases != 0
group by date
order by date

-- Looking at total population and total vaccination

select dea.date,dea.location,population,new_vaccinations,total_vaccinations,
sum(convert(bigint,new_vaccinations)) over (partition by dea.location order by dea.date) as new_vaccination_sum
from PortfolioProject..covid_deaths as dea
join PortfolioProject..covid_vaccination as vac
on dea.location = vac.location and
dea.date = vac.date

where dea.continent is not null
 order by 2,1

 -- looking at percentage of population vaccinated
 
 with population_vac_percent(date,location,population,new_vaccination,total_vaccinations,new_vaccination_sum) as
 (
 select dea.date,dea.location,population,new_vaccinations,total_vaccinations,
sum(convert(bigint,new_vaccinations)) over (partition by dea.location order by dea.date) as new_vaccination_sum
from PortfolioProject..covid_deaths as dea
join PortfolioProject..covid_vaccination as vac
on dea.location = vac.location and
dea.date = vac.date

where dea.continent is not null
 )
 select *,(new_vaccination_sum/population)*100 as percentage_vaccinated
 from population_vac_percent
 where new_vaccination is not null
 order by 2,1

drop table if exists population_vs_vaccination
create table population_vs_vaccination
(date datetime,
location nvarchar(255),
population numeric,
new_vaccination numeric,
total_vaccination numeric,
new_vaccination_sum numeric)

insert into population_vs_vaccination
select dea.date,dea.location,population,new_vaccinations,total_vaccinations,
sum(convert(bigint,new_vaccinations)) over (partition by dea.location order by dea.date) as new_vaccination_sum
from PortfolioProject..covid_deaths as dea
join PortfolioProject..covid_vaccination as vac
on dea.location = vac.location and
dea.date = vac.date

where dea.continent is not null

select *,(new_vaccination_sum/population)*100 as percentage_of_vaccination
from population_vs_vaccination
where new_vaccination is not null
order by 2,1

-- creating view for visualization
drop View if exists populationVSvaccination
create View populationVSvaccination as 
select dea.date,dea.location,vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date) as percentage_vaccinated
from PortfolioProject..covid_deaths as dea
join PortfolioProject..covid_vaccination as vac
on dea.location = vac.location and
dea.date = vac.date
where dea.continent is not null

