-- Cleaning Data

--We have a database of 4 tables contains data about job posting in 2023

-- 1 Remove Duplicates
-- 2 Standardize the Data
-- 3 Null Values or Blank Values


--Let's start with looking at Duplicates in all four tables

SELECT *
FROM job_posting_fact;

SELECT *
FROM company_dim;

SELECT *
FROM skills_dim;

SELECT *
FROM skills_job_dim;


with job_posting_CTE AS
(
SELECT *,
ROW_NUMBER() OVER(PARTITION BY 
					job_id,
                    job_title_short,
                    job_location
                    order by job_id) as Row_num
FROM job_posting_fact
)
SELECT *
FROM job_posting_CTE
WHERE Row_num > 1;

--So There is no Duplicates in the job_posting_fact table.
--let's check the sencond table

with company_CTE AS
(
SELECT *,
ROW_NUMBER() OVER(PARTITION BY 
					company_id,
                    ('name')
                    order by company_id) as Row_num
FROM company_dim
)
SELECT *
FROM company_CTE
WHERE Row_num > 1;

--the same for the third table of skills_dim there is no duplcates
with skills_CTE AS
(
SELECT *,
ROW_NUMBER() OVER(PARTITION BY 
					skill_id,
                    skills
                    order by skill_id) as Row_num
FROM skills_dim
)
SELECT *
FROM skills_CTE
WHERE Row_num > 1;

-- the Fourth table

with skills_job_CTE AS
(
SELECT *,
ROW_NUMBER() OVER(PARTITION BY 
                    job_id,
					skill_id
                    order by job_id) as Row_num
FROM skills_job_dim
)
SELECT *
FROM skills_job_CTE
WHERE Row_num > 1;

--Ok, there is some duplicates in the fourth table, we need to remove them.

with skills_job_CTE AS
(
SELECT *,
ROW_NUMBER() OVER(PARTITION BY 
                    job_id,
					skill_id
                    order by job_id) as Row_num
FROM skills_job_dim
)
DELETE
FROM skills_job_CTE
WHERE Row_num > 1;

-- however, we just need to keep in mind that Each job may require more than one skill.
-- count the number of skills for each job.

SELECT job_id, COUNT(DISTINCT skill_id) AS skill_count
FROM skills_job_dim
GROUP BY job_id
ORDER BY skill_count;

-- we can check for example where job_id = 2

SELECT job_id, COUNT(DISTINCT skill_id) AS skill_count
FROM skills_job_dim
where job_id=2
GROUP BY job_id
ORDER BY skill_count;

-- which are:

SELECT *
FROM skills_job_dim
where job_id =10000;


-- 2 Standardize the Data
-- Trim the space in company column

SELECT job_location, TRIM(job_location)
FROM job_posting_fact;

UPDATE job_posting_fact
SET Job_location = TRIM(job_location);

--Capitalize the first letter in columns

select skills, Upper(left(skills,1)) + substring(LOWER(skills), 2, len(skills))
from skills_dim;

UPDATE skills_dim
SET skills = Upper(left(skills,1)) + substring(LOWER(skills), 2, len(skills));

select salary_rate, Upper(left(salary_rate,1)) + substring(LOWER(salary_rate), 2, len(salary_rate))
from job_posting_fact;

UPDATE job_posting_fact
SET salary_rate = Upper(left(salary_rate,1)) + substring(LOWER(salary_rate), 2, len(salary_rate));


-- 3 Null Values or Blank Values

--looking for NULL and Empty rows

SELECT *
FROM company_dim
WHERE link = ' ';

-- we should set the blanks to nulls since those are typically easier to work with, in company_dim table.

SELECT DISTINCT(job_location)
FROM job_posting_fact
ORDER BY job_location;

SELECT *
FROM job_posting_fact
WHERE job_location = ' ';

UPDATE job_posting_fact
SET job_location = NULL
WHERE job_location = ' ';

SELECT *
FROM job_posting_fact
WHERE job_via = ' '
ORDER BY job_via;

UPDATE job_posting_fact
SET job_via = NULL
WHERE job_via = ' ';


SELECT *
FROM job_posting_fact
WHERE job_schedule_type = ' '
ORDER BY job_schedule_type;

UPDATE job_posting_fact
SET job_schedule_type = NULL
WHERE job_schedule_type = ' ';


UPDATE company_dim
SET link= NULL
WHERE link = ' ';
  
SELECT *
FROM company_dim
WHERE thumbnail = ' ';

UPDATE company_dim
SET thumbnail= NULL
WHERE thumbnail = ' ';






