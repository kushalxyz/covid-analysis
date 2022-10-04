use covid_19_data_analysis
select * from cdeaths

-- Firstly, I am converting the date column into the 'date' datatype because it has currently 'text' datatype .

alter table cdeaths 
modify date date ;

-- Now its showing error because actually the in the table is in the format of dd/mm/yyyy
-- but in mysql the default setting for the date is yyyy/mm/dd 
-- So firtly I should convert the format into yyy/mm/dd and then I will change the dataytype.

UPDATE cdeaths 
SET date = str_to_date(date,'%d-%m-%Y');  -- str_to_date convert any format to yyyy//mm/dd format  

alter table cdeaths 
modify date date ;

describe cdeaths

-- Now the date column has the datatype 'date'.


 -- Selecting the data that we'll be using.  

select Location , date , total_cases , new_cases, total_deaths , population 
from Cdeaths 

-- Total cases vs Total deaths
-- Now we wil be looking at the  total cases vs total deaths (divide the total deaths by the total cases and then *100 for percentage)

select Location , date , total_cases ,total_deaths, (total_deaths/total_cases)*100 as deathpercentage 
from Cdeaths

-- This shows the likelihood of you dying if you get covid in your country (eg: by the end of 2021 there was 1.1% chance of dying if 
-- someone would have infected with the covid at that time)


-- Analysing the data for India. 

select Location , date , total_cases ,total_deaths, (total_deaths/total_cases)*100 as deathpercentage 
from Cdeaths 
where Location like 'India'



-- Total cases vs population
-- Now we will look at the total cases vs population , which we will show that what percentage of population got covid in the India.   

select Location , date , Population , total_cases , (total_cases/population)*100 as percentagepopulationinfected 
from Cdeaths 
where Location like 'India'


-- Highest infection rate
-- Now we will check which country has the highest infection rate as compared to the population of the country. 

select Location , Population , MAX(total_cases) as highestinfectioncount ,max((total_cases/population))*100 as percentagepopulationinfected 
from Cdeaths 
group by Location , Population
order by percentagepopulationinfected desc


-- Death count
-- Showing the total death count of every country. 

select Location ,max(Total_deaths) as Totaldeathcount  
from Cdeaths 
group by Location
order by Totaldeathcount desc

-- Actually the above query is not giving the correct results because the type of total_deaths is 'text'.

describe cdeaths

-- Changing the datatype of this coloumn.
-- (the CAST() function converts a value (of any type) into a specified datatype.)

Select Location, max(cast(Total_deaths as signed)) as totaldeathcount -- use signed to change the data type to integer when int is not working
from Cdeaths 
group by Location
order by Totaldeathcount desc

-- Changed the datatype and the query is working.
-- But now there is a another issue which is in the location column, there are some locations which are not countires actually 
-- for example there is a location named as 'world' and also there are some locations which do not have any value for the continent column, 
--  actully this problem is in the table where the continent value is null and the location is actually the whole continent.
-- That is why some of the locations are named as 'Asia'.
 -- You can have a look from the table.
  
select * from cdeaths

 -- So actually to solve this issue we will now only focous on the data where continent value is not null,
-- for that we will use 'where continent is not null' in the every query we need.

Select Location, max(cast(Total_deaths as signed )) as totaldeathcount 
from Cdeaths 
where continent is not null 
group by Location 
order by Totaldeathcount desc

-- Finally this is giving the correct results for - the total death count of every country. 


-- Now lets break things wrt to the Continents. 
-- Let's check the continents with the highest death count.
 
Select continent, max(cast(Total_deaths as signed)) as totaldeathcount 
from Cdeaths 
where continent is not null 
group by continent
order by Totaldeathcount desc


-- Now let's break the things with respect to the Global numbers. 
-- Let's check how many new number of cases were listed across the world each day . 
 
 
Select date, sum(new_cases)
from Cdeaths 
where continent is not null 
group by date 
order by 1


-- New Deaths wrt to the Dates.
-- To check this out ,firstly we have to convert the new_deaths into 'int' datatype as the new_cases is already in the 'int' datatype format. 

Select date, sum(new_cases) , sum(cast(new_deaths as signed))
from Cdeaths 
where continent is not null 
group by date 
order by 1 


-- Calculating the death percentage 
  
Select date, sum(new_cases) , sum(new_deaths) , sum(new_deaths) / sum(new_cases) as deathpercentage  
from Cdeaths 
where continent is not null 
group by date 
order by 1 


-- Calculating the total no of cases across the world and the respective deaths and the death percentage.
-- By this we can analyse the chance of dying of a infected person wrt to the world data and also we can compare this data to the country data.

Select sum(new_cases) , sum(new_deaths) , sum(new_deaths) / sum(new_cases) as deathpercentage  
from Cdeaths 
where continent is not null 




-- Covid vaccinations  

select * from cvaccinations

UPDATE cvaccinations -- Changing the datatype of the date column. 
SET date = str_to_date(date,'%d-%m-%Y'); 

alter table cvaccinations 
modify date date ;

describe cvaccinations


-- Now lets join the cdeaths and cvaccinations tables together.

select* from cdeaths dea 
join cvaccinations vac
on dea.location = vac.location
and dea.date = vac.date 


-- Total population vs vaccinations 

select dea.continent, dea.location, dea.date, dea.population , vac.new_vaccinations from cdeaths dea 
join cvaccinations vac
on dea.location = vac.location
and dea.date = vac.date 
where dea.continent is not null 

-- We have calculated the new vaccination, let's calculate the total no of new vaccinations wrt to date and the location. 

select dea.continent, dea.location, dea.date, dea.population , vac.new_vaccinations , sum(cast(vac.new_vaccinations as signed ))
over(partition by dea.location)  from cdeaths dea 
join cvaccinations vac
on dea.location = vac.location
and dea.date = vac.date 
where dea.continent is not null 
order by 2,3 
-- (partition by location means the sum(vac.new_vaccination) will run wrt to the location , means it will display the count wrt to the location.)

-- Actually here the total no of vaccinations are displayed wrt to the location but what I actually wanted is the total vaccinations should be displayed 
-- by adding the previous the data of the previous date.
-- For that we will order it by the location and the date.

select dea.continent, dea.location, dea.date, dea.population , vac.new_vaccinations, sum(cast(vac.new_vaccinations as signed ))
over(partition by dea.location order by dea.location, dea.date ) as rollingpeoplevaccinated  from cdeaths dea 
join cvaccinations vac
on dea.location = vac.location
and dea.date = vac.date 
where dea.continent is not null 
order by 2,3 


-- Let's check out that how many persons in total in a country are actually vaccinated , we will do it with the help of total population of
-- that country with the rolling people vacccinated of that country
-- But actually we cannot run a query onto a column which we just created in the same line of the query 
-- (because rolling people vaccinated column is not in the table) (so we cannot do (rollingpeoplevaccinated/population)*100 directly 

select dea.continent, dea.location, dea.date, dea.population , vac.new_vaccinations, sum(cast(vac.new_vaccinations as signed ))
over(partition by dea.location order by dea.location, dea.date ) as rollingpeoplevaccinated ,(sum(cast(vac.new_vaccinations as signed ))
over(partition by dea.location order by dea.location, dea.date ) /population)*100 as percentagerollingvaccinated from cdeaths dea 
join cvaccinations vac
on dea.location = vac.location
and dea.date = vac.date 
where dea.continent is not null 
order by 2,3 






