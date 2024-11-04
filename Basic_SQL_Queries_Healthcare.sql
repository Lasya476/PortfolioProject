-- This dataset follows HIPAA regulations and is downloaded from a platform called Synthea.

-- Retrieve all inpatient encounters with the description 'ICU Admission'
select *
from public.encounters
where encounterclass = 'inpatient'
   and description = 'ICU Admission'
   and stop between '2023-01-01 00:00' and '2023-12-31 00:00';

-- Retrieve encounters classified as 'outpatient' or 'ambulatory'
-- Ambulatory and outpatient are considered the same in this context.
select *
from public.encounters
where encounterclass = 'outpatient'
or encounterclass = 'ambulatory';

-- Another way to write the previous query using the 'IN' clause
select *
from public.encounters
where encounterclass in('outpatient', 'ambulatory');

-- View all records in the conditions table
select * from public.conditions;

-- Count the occurrences of each condition and order them by count in descending order
select description,
       count(*) as count_of_cond
from public.conditions
group by description 
order by 2 desc;

-- Count the occurrences of each condition, filtering for those with more than 5000 occurrences
select description,
       count(*) as count_of_cond
from public.conditions
group by description 
having count(*) > 5000
order by 2 desc;

-- Count occurrences of each condition while excluding 'Body Mass Index 30.0-30.9, adult'
select description,
       count(*) as count_of_cond
from public.conditions
where description != 'Body Mass Index 30.0-30.9, adult'
group by description 
having count(*) > 5000
order by 2 desc;

-- Practice Questions:

-- 1. Return all patients from Boston 

select first, 
       last, 
	   city
from public.patients
where city = 'Boston';

-- 2. Return all patients who have been diagnosed with Chronic Kidney Disease (use codes: 585.1, and so on)
select * from public.conditions
where code in ('585.1', '585.2', '585.3', '585.4');

---------------------------------------------------------
-- Write a query that does the following:
-- 1. Lists out number of patients per city in desc order
-- 2. Does not include Boston 
-- 3. Must have at least 100 patients from that city 
---------------------------------------------------------

select city, 
       count(id) 
from public.patients
where city != 'Boston'
group by city
having count(id) >= 100
order by 2 desc;

-- *place a relevant comment here*

select * from public.immunizations;


------------------------------------
-- 1. Having a starting table 
-- 2. Have a joining table 
-- 3. Pick the joining table
   -- A. Left Join 
   -- B. Inner Join 
   -- C. Right Join 
   -- D. Full Outer Join 
-- 4. Specify what you want to join on 
-- 4. Provide Aliases
-------------------------------------

select t1.*, 
       t2.first, 
	   t2.last, 
	   t2.birthdate
from public.immunizations as t1
left join public.patients as t2
    on t1.patient = t2.id;	   
	   