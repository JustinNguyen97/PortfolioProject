
Select * 
From [Portfolio Project]..CovidVaccination$
order by 3,4

Select location, date, total_cases, new_cases, total_deaths, population
From [Portfolio Project]..['Covid Death$']
order by 1,2

-- Total cases vs total deaths
Select location, date, total_cases, new_cases, total_deaths,(total_deaths/total_cases)*100 as ratio
From [Portfolio Project]..['Covid Death$']
Where location like '%state%'
order by 1,2

-- Total cases vs population
Select location, date, total_cases, new_cases, population,(total_cases/population)*100 as ratio
From [Portfolio Project]..['Covid Death$']
Where location like '%state%'
order by 1,2

-- Countries with highest infection rate
Select location, population, MAX(total_cases) as HighestInfectionCount, MAX(total_cases/population)*100 as ratio
From [Portfolio Project]..['Covid Death$']
Group by location, population
order by ratio desc

-- Showing Countries with the highest death count per population
Select continent, MAX(cast(total_deaths as int)) as TotalDeathCounts
From [Portfolio Project]..['Covid Death$']
where continent is not null
Group by continent
order by TotalDeathCounts desc

-- Global Number
Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as TotalDeaths,
SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From [Portfolio Project]..['Covid Death$']
where continent is not null
Group by date
order by 1,2 

-- Vaccination data (Total population vs vaccination)
With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as 
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location order by dea.location, dea.date)
as RollingPeopleVaccinated
From [Portfolio Project]..['Covid Death$'] dea
Join [Portfolio Project]..CovidVaccination$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
-- USE CTE
Select *, (RollingPeopleVaccinated/Population)*100
as VaccinationPercentage
From PopvsVac

--Temp Table
Drop Table if exists #PercentPopulationVaccianted
Create Table #PercentPopulationVaccianted
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)
Insert into #PercentPopulationVaccianted
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location order by dea.location, dea.date)
as RollingPeopleVaccinated
From [Portfolio Project]..['Covid Death$'] dea
Join [Portfolio Project]..CovidVaccination$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
Select *, (RollingPeopleVaccinated/Population)*100
as VaccinationPercentage
From #PercentPopulationVaccianted

-- Create View to store data
Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location order by dea.location, dea.date)
as RollingPeopleVaccinated
From [Portfolio Project]..['Covid Death$'] dea
Join [Portfolio Project]..CovidVaccination$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null

Create View Total_death as 
Select location, date, total_cases, new_cases, total_deaths,(total_deaths/total_cases)*100 as ratio
From [Portfolio Project]..['Covid Death$']
Where location like '%state%'
