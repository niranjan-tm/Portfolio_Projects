/*
The data is from imaginary bike renting company Cyclistic.
I tried to find out how Casual members use bike different from annual members
*/



select *
from PortfolioProject..tripdata\


-- Calculating number of casual and annual members
select member_casual as type_of_member,count(member_casual) as count
from PortfolioProject..tripdata
group by member_casual

--Looking at type of bikes

select DISTINCT(rideable_type)
from PortfolioProject..tripdata

--Most used stations by casual members

select start_station_name,count(start_station_name) as start_station_used,end_station_name,count(end_station_name) as end_station_used
from PortfolioProject..tripdata
where member_casual = 'casual'
group by start_station_name,end_station_name
order by 2 DESC

--Most used stations by members

select start_station_name,count(start_station_name) as start_station_used,end_station_name,count(end_station_name) as end_station_used
from PortfolioProject..tripdata
where member_casual = 'member'
group by start_station_name,end_station_name
order by 2 DESC

-- Total bike usage time by casual members

with casual_total_time as 
(
select member_casual,(DATEDIFF(HH,started_at,ended_at)) as total_time ,ride_id
from PortfolioProject..tripdata
where member_casual = 'casual'
--group by member_casual
)
select member_casual,
(case
when total_time < 0 then 0 
else total_time
end) as total_time,ride_id

from casual_total_time
--group by member_casual
order by 2 DESC

-- Total bike usage time by members

select member_casual,ride_id,
(case when DATEDIFF(HH,started_at,ended_at) <0 then 0
else DATEDIFF(HH,started_at,ended_at)
end) as total_time
from PortfolioProject..tripdata
where member_casual  = 'member'
order by 3 DESC

--mean ride duration in minutes 

select member_casual,AVG(DATEDIFF(MI,started_at,ended_at)) as mean_ride_time_in_min
from PortfolioProject..tripdata
group by member_casual

--Maximum ride duration in days
select member_casual,MAX(DATEDIFF(D,started_at,ended_at)) as max_ride_time_in_days
from PortfolioProject..tripdata
group by member_casual





