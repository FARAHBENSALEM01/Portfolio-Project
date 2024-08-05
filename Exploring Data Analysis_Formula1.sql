/* Exploring Data Analysis */

select* 
from circuits;

/*How Many Races Max has won in 2023 in F1*/

SELECT COUNT(DISTINCT(wins))
FROM drivers a
JOIN driver_standings b
ON a.driverId = b.driverId
JOIN races c
ON b.raceId=c.raceId
WHERE (driverref = 'max_verstappen'
AND year = 2023)
AND wins>0;

-- lets look for duplicates in results table
 select* from results

 WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY resultid,
		     driverid
		     ORDER BY
		     resultid
		     ) row_num

From results
--order by ParcelID
)
Select *
From RowNumCTE
Where row_num > 1
Order by resultid;

select *
from results
where driverid = 1
and raceid= 18;

 -- Remove duplicates from results table

 WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY resultid,
	 	     driverid
		     ORDER BY
		     resultid
		     ) row_num

From results
--order by ParcelID
)
Delete
From RowNumCTE
Where row_num > 1;


/* how many years max participate in Formula 1*/ 

SELECT COUNT(DISTINCT(year))
FROM results a 
JOIN races b
ON a.raceId=b.raceId
WHERE driverid= 830
AND year BETWEEN 2015 AND 2023; 

/* how many  gps max have in his career */

SELECT COUNT(year)
FROM results a 
JOIN races b
ON a.raceId=b.raceId
WHERE driverid= 830;

/* how many times max verstappen won in every year from 2015 till 2024 (round11, 12 gps)*/

SELECT COUNT(DISTINCT(wins)), year
FROM drivers a
JOIN driver_standings b
ON a.driverId = b.driverId
JOIN races c
ON b.raceId=c.raceId
WHERE driverref = 'max_verstappen'
AND wins>0
GROUP BY year;

/*qualifying classification as P1 for max ver*/

SELECT name, driverRef, position, year
FROM qualifying a
JOIN races b 
ON a.raceId=b.raceId
JOIN drivers c 
ON a.driverId=c.driverId
WHERE a.driverid=830
AND position =1;

/* qualifying classification for max ver in f1 for every gp*/ 

SELECT name, driverRef, position, year
FROM qualifying a
JOIN races b 
ON a.raceId=b.raceId
JOIN drivers c 
ON a.driverId=c.driverId
WHERE a.driverid=830;

/*avg qualification performance per year*/ 
SELECT name, driverRef, ROUND(AVG(position), 0), year
FROM qualifying a
JOIN races b 
ON a.raceId=b.raceId
JOIN drivers c 
ON a.driverId=c.driverId
WHERE a.driverid=830
GROUP BY year
order by 3

/* the fastest Lap time per year*/ 

SELECT year, a.time, driverref
FROM lap_times a
JOIN drivers b 
ON a.driverId=b.driverId
JOIN races c 
ON a.raceId=c.raceId
GROUP BY year
ORDER BY 1;

/* max verstappen sprint races winner*/

SELECT name, year, driverref, position
FROM sprint_results a 
JOIN drivers b 
ON a.driverId= b.driverId
JOIN races c 
ON a.raceId=c.raceId
WHERE a.driverid=830;

/* sprint races winners by years starting from 2021*/ 

SELECT name, year, driverref, position
FROM sprint_results a 
JOIN drivers b 
ON a.driverId= b.driverId
JOIN races c 
ON a.raceId=c.raceId
WHERE position =1
ORDER BY  year;

/* count pit_stops of max verstappen per gp*/ 

SELECT name, year, driverref, COUNT(DISTINCT(stop)), a.raceid
FROM pit_stops a
FROM races b 
ON a.raceId = b.raceid
JOIN drivers c
ON a.driverId=c.driverId
WHERE a.driverid=830
GROUP BY a.raceId
ORDER BY year;

/* 3 fastes pit_stops of max verstappen per gp*/ 
SELECT name, year, driverref, min(duration) fast_pit
FROM pit_stops a
JOIN races b 
ON a.raceId = b.raceid
JOIN drivers c
ON a.driverId=c.driverId
WHERE a.driverid=830 
GROUP BY name
ORDER BY fast_pit ASC
LIMIT 3

/*10 fastest pit_stops in F1*/ 

WITH PitStopData AS (
    SELECT
        name,
        driverref,
        year,
        stop,
        duration
    FROM pit_stops a
    JOIN drivers b ON a.driverid = b.driverid
    JOIN races c ON a.raceId = c.raceId
)
SELECT *
FROM PitStopData
ORDER BY duration ASC
LIMIT 10;

/* ordering drivers in qualifying: top 10*/

WITH TOP_qualifying_drivers AS
(SELECT *,
   RANK() OVER(PARTITION BY raceid ORDER BY position DESC) AS Rank
FROM qualifying
  )
SELECT   	
	 year, name, driverid, position
FROM top_qualifying_drivers a
join races b
on a.raceid=b.raceId
WHERE position<=10
GROUP BY driverid;

/* constructors*/ 
/* Red_bull SUM of points per year */ /* is there any progress in red bull performance per year*/

SELECT constructorref, sum(points), year
FROM constructor_results a
JOIN constructors b
ON a.constructorId=b.constructorId
JOIN races c 
ON a.raceId=c.raceId
WHERE constructorref = 'red_bull'
GROUP BY year 
ORDER BY sum(points) DESC;

/* how many points every team got in  2023*/

SELECT b.name, SUM(points) AS total_points, year
FROM constructor_results a
JOIN constructors b ON a.constructorId = b.constructorId
JOIN races c ON a.raceId = c.raceId
WHERE year = 2023
GROUP BY b.name
ORDER BY total_points DESC;

