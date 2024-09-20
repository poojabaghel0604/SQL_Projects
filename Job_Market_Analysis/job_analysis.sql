use projects;
select * from salaries;

/* 1.You're a Compensation analyst employed by a multinational corporation.
 Your Assignment is to Pinpoint Countries who give work fully remotely,
 for the title 'managers’ Paying salaries Exceeding $90,000 USD */

select distinct(company_location) from salaries where remote_ratio = 100 and salary_in_usd > 90000 and job_title like "%manager%";

/*2.AS a remote work advocate Working for a progressive HR tech startup who place their freshers’
 clients IN large tech firms. you're tasked WITH Identifying top 5 Country Having greatest count 
 of large (company size) number of companies.*/
 
select company_location,count(company_size) as size from (
select * from salaries where company_size = 'L')t
group by company_location order by size desc limit 5;

 
 /*3.	Picture yourself AS a data scientist Working for a workforce management platform. Your objective is to calculate the percentage of employees.
 Who enjoy fully remote roles WITH salaries Exceeding $100,000 USD, Shedding light ON the attractiveness of high-paying remote positions IN today's job market.*/
 
set @total = (select count(*) from salaries);
set @find = (select count(*) from salaries where remote_ratio=100 and salary_in_usd > 100000);
set @ans = ((@find/@total) *100);
select @ans;

/*4.Imagine you're a data analyst Working for a global recruitment agency. 
Your Task is to identify the Locations where entry-level average salaries exceed the average salary 
for that job title IN market for entry level, helping your agency guide candidates towards lucrative opportunities.*/

select company_location,t.job_title,avg_by_country,avg_by_job from
(select company_location,job_title,avg(salary_in_usd) as avg_by_country from salaries where experience_level = 'EN' group by company_location,job_title) as t
inner join (select job_title,avg(salary_in_usd) as avg_by_job from salaries where experience_level = 'EN' group  by job_title) as p
on t.job_title = p.job_title where avg_by_country > avg_by_job;

/*5. You've been hired by a big HR Consultancy to look at how much people get paid IN different Countries. Your job is to Find out for each job title which
Country pays the maximum average salary. This helps you to place your candidates IN those countries.*/

select company_location,job_title, avg_by_country from(
select * , dense_rank() over (partition by job_title order by avg_by_country) as num from
(select company_location,job_title,avg(salary_in_usd) as avg_by_country from salaries  group by company_location,job_title)t)m where num = 1;

/*6.  AS a data-driven Business consultant, you've been hired by a multinational corporation to analyze salary trends across different company Locations.
 Your goal is to Pinpoint Locations WHERE the average salary Has consistently Increased over the Past few years (Countries WHERE data is available for 3 years Only(this and pst two years) 
 providing Insights into Locations experiencing Sustained salary growth.*/

WITH t AS
(
 SELECT * FROM  salaries WHERE company_locatiON IN
		(
			SELECT company_locatiON FROM
			(
				SELECT company_locatiON, AVG(salary_IN_usd) AS AVG_salary,COUNT(DISTINCT work_year) AS num_years FROM salaries WHERE work_year >= YEAR(CURRENT_DATE()) - 2
				GROUP BY  company_locatiON HAVING  num_years = 3 
			)m
		)
)  -- step 4
-- SELECT company_locatiON, work_year, AVG(salary_IN_usd) AS average FROM  t GROUP BY company_locatiON, work_year 
SELECT 
    company_locatiON,
    MAX(CASE WHEN work_year = 2022 THEN  average END) AS AVG_salary_2022,
    MAX(CASE WHEN work_year = 2023 THEN average END) AS AVG_salary_2023,
    MAX(CASE WHEN work_year = 2024 THEN average END) AS AVG_salary_2024
FROM 
(
SELECT company_locatiON, work_year, AVG(salary_IN_usd) AS average FROM  t GROUP BY company_locatiON, work_year 
)q GROUP BY company_locatiON  havINg AVG_salary_2024 > AVG_salary_2023 AND AVG_salary_2023 > AVG_salary_2022 -- step 3 and havINg step 4.

         --------------------------------------
select  company_locatiON, work_year, AVG(salary_IN_usd) AS AVG_salary  FROM salaries   group by company_location , work_year-- step 1
select  company_locatiON, work_year, AVG(salary_IN_usd) AS AVG_salary  FROM salaries  where work_year>=year(current_date())-2  group by company_location , work_year  -- step 2
SELECT company_locatiON, AVG(salary_IN_usd) AS AVG_salary,COUNT(DISTINCT work_year) AS num_years FROM salaries WHERE work_year >= YEAR(CURRENT_DATE()) - 2
				GROUP BY  company_locatiON HAVING  num_years = 3       -- STEP 3


 
 /* 7.	Picture yourself AS a workforce strategist employed by a global HR tech startup. Your missiON is to determINe the percentage of  fully remote work for each 
 experience level IN 2021 and compare it WITH the correspONdINg figures for 2024, highlightINg any significant INcreASes or decreASes IN remote work adoptiON
 over the years.*/
 WITH t1 AS 
 (
		SELECT a.experience_level, total_remote ,total_2021, ROUND((((total_remote)/total_2021)*100),2) AS '2021 remote %' FROM
		( 
		   SELECT experience_level, COUNT(experience_level) AS total_remote FROM salaries WHERE work_year=2021 and remote_ratio = 100 GROUP BY experience_level
		)a
		INNER JOIN
		(
		  SELECT  experience_level, COUNT(experience_level) AS total_2021 FROM salaries WHERE work_year=2021 GROUP BY experience_level
		)b ON a.experience_level= b.experience_level
  ),
  t2 AS
     (
		SELECT a.experience_level, total_remote ,total_2024, ROUND((((total_remote)/total_2024)*100),2)AS '2024 remote %' FROM
		( 
		SELECT experience_level, COUNT(experience_level) AS total_remote FROM salaries WHERE work_year=2024 and remote_ratio = 100 GROUP BY experience_level
		)a
		INNER JOIN
		(
		SELECT  experience_level, COUNT(experience_level) AS total_2024 FROM salaries WHERE work_year=2024 GROUP BY experience_level
		)b ON a.experience_level= b.experience_level
  ) 
  
 SELECT * FROM t1 INNER JOIN t2 ON t1.experience_level = t2.experience_level
 
 
 
/* 8. AS a compensatiON specialist at a Fortune 500 company, you're tASked WITH analyzINg salary trends over time. Your objective is to calculate the average 
salary INcreASe percentage for each experience level and job title between the years 2023 and 2024, helpINg the company stay competitive IN the talent market.*/

WITH t AS
(
SELECT experience_level, job_title ,work_year, round(AVG(salary_in_usd),2) AS 'average'  FROM salaries WHERE work_year IN (2023,2024) GROUP BY experience_level, job_title, work_year
)  -- step 1



SELECT *,round((((AVG_salary_2024-AVG_salary_2023)/AVG_salary_2023)*100),2)  AS changes
FROM
(
	SELECT 
		experience_level, job_title,
		MAX(CASE WHEN work_year = 2023 THEN average END) AS AVG_salary_2023,
		MAX(CASE WHEN work_year = 2024 THEN average END) AS AVG_salary_2024
	FROM  t GROUP BY experience_level , job_title -- step 2
)a WHERE (((AVG_salary_2024-AVG_salary_2023)/AVG_salary_2023)*100)  IS NOT NULL -- STEP 3




 
/* 9. You're a database administrator tasked with role-based access control for a company's employee database. Your goal is to implement a security measure where employees
 in different experience level (e.g.Entry Level, Senior level etc.) can only access details relevant to their respective experience_level, ensuring data 
 confidentiality and minimizing the risk of unauthorized access.*/
 select * from salaries
 select distinct experience_level from salaries
 Show privileges
 


CREATE USER 'Entry_level'@'%' IDENTIFIED BY 'EN';
CREATE USER 'Junior_Mid_level'@'%' IDENTIFIED BY ' MI '; 
CREATE USER 'Intermediate_Senior_level'@'%' IDENTIFIED BY 'SE';
CREATE USER 'Expert Executive-level '@'%' IDENTIFIED BY 'EX ';


CREATE VIEW entry_level AS
SELECT * FROM salaries where experience_level='EN'

GRANT SELECT ON campusx.entry_level TO 'Entry_level'@'%'

UPDATE view entry_level set WORK_YEAR = 2025 WHERE EMPLOYNMENT_TYPE='FT'




/* 10.	You are working with an consultancy firm, your client comes to you with certain data and preferences such as 
( their year of experience , their employment type, company location and company size )  and want to make an transaction into different domain in data industry
(like  a person is working as a data analyst and want to move to some other domain such as data science or data engineering etc.)
your work is to  guide them to which domain they should switch to base on  the input they provided, so that they can now update thier knowledge as  per the suggestion/.. 
The Suggestion should be based on average salary.*/

DELIMITER //
create PROCEDURE GetAverageSalary(IN exp_lev VARCHAR(2), IN emp_type VARCHAR(3), IN comp_loc VARCHAR(2), IN comp_size VARCHAR(2))
BEGIN
    SELECT job_title, experience_level, company_location, company_size, employment_type, ROUND(AVG(salary), 2) AS avg_salary 
    FROM salaries 
    WHERE experience_level = exp_lev AND company_location = comp_loc AND company_size = comp_size AND employment_type = emp_type 
    GROUP BY experience_level, employment_type, company_location, company_size, job_title order by avg_salary desc ;
END//
DELIMITER ;
-- Deliminator  By doing this, you're telling MySQL that statements within the block should be parsed as a single unit until the custom delimiter is encountered.

call GetAverageSalary('EN','FT','AU','M')


drop procedure Getaveragesalary;


/*1	As a market researcher, your job is to Investigate the job market for a company that analyzes workforce data.
 Your Task is to know how many people were employed IN different types of companies AS per their size IN 2021.*/
select company_size,count(*) from  
(select * from salaries where work_year = 2021)t group by company_size;

/* 2.Imagine you are a talent Acquisition specialist Working for an International recruitment agency. Your Task is to identify the top 3 job titles 
that command the highest average salary Among part-time Positions IN the year 2023. However, you are Only Interested IN Countries WHERE there are more than 50 employees,
 Ensuring a robust sample size for your analysis.*/


select job_title,avg(salary_in_usd) as a from salaries 
where work_year = 2023 and employment_type = 'PT' group by job_title order by a desc;


/*3.As a database analyst you have been assigned the task to Select Countries
 where average mid-level salary is higher than overall mid-level salary for the year 2023.*/
 
set @total = (select avg(salary_in_usd) from salaries where experience_level = 'MI');
select company_location,avg(salary_in_usd) from salaries where experience_level = 'MI' 
and salary_in_usd > @total group by company_location;
 
/* 4.As a database analyst you have been assigned the task to Identify the company locations with the highest and
 lowest average salary for senior-level (SE) employees in 2023.*/

-- Call the stored procedure to get the results
CALL get_highest_lowest_salary();

/*5.	You're a Financial analyst Working for a leading HR Consultancy, and your Task is to Assess the annual salary growth rate for various job titles.
 By Calculating the percentage Increase IN salary FROM previous year to this year, you aim to provide valuable Insights Into salary trends WITHIN different job roles.*/
 with t as(
 select t.job_title,avg_2023,avg_2024 from(
 select job_title,avg(salary_in_usd) as avg_2023 from salaries where work_year = 2023 group by job_title) as t
 inner join(
 select job_title,avg(salary_in_usd) as avg_2024 from salaries where work_year = 2024 group by job_title) as m
  on t.job_title = m.job_title)
  select * ,round((((avg_2024-avg_2023)/avg_2023)*100),2) from t;
  
  
/*6.	You've been hired by a global HR Consultancy to identify Countries experiencing significant salary growth for entry-level roles.
 Your task is to list the top three Countries with the highest salary growth rate FROM 2020 to 2023,
 Considering Only companies with more than 50 employees, helping multinational Corporations identify Emerging talent markets.*/
with t as (
select company_location,work_year,avg(salary_in_usd) as average from salaries where experience_level = 'EN' 
and (work_year = 2021 or work_year = 2023)  group by company_location,work_year
)-- Main query to calculate percentage change in salary from 2021 to 2023 for each country
SELECT *, (((AVG_salary_2023 - AVG_salary_2021) / AVG_salary_2021) * 100) AS changes
FROM(-- Subquery to pivot the data and calculate average salary for each country in 2021 and 2023
    SELECT company_location,
        MAX(CASE WHEN work_year = 2021 THEN average END) AS AVG_salary_2021,
        MAX(CASE WHEN work_year = 2023 THEN average END) AS AVG_salary_2023
    FROM t GROUP BY company_location) a 
-- Filter out null values and select the top three countries with the highest salary growth rate
WHERE (((AVG_salary_2023 - AVG_salary_2021) / AVG_salary_2021) * 100) IS NOT NULL ORDER BY changes DESC limit 3 ;

/*7.	Picture yourself as a data architect responsible for database management. Companies in US and AU(Australia) decided to
 create a hybrid model for employees they decided that employees earning salaries exceeding $90000 USD, will be given work from home.
 You now need to update the remote work ratio for eligible employees, ensuring efficient remote work management while implementing appropriate 
 error handling mechanisms for invalid input parameters.*/
create table camp as select * from salaries;
SET SQL_SAFE_UPDATES = 0;
update camp set remote_ratio=100 where (company_location = 'US' or company_location = 'AU' ) and salary_in_usd > 90000;
select * from camp where (company_location = 'US' or company_location = 'AU' ) and salary_in_usd > 90000;

/* 8. In year 2024, due to increase demand in data industry , there was  increase in salaries of data field employees.
                   Entry Level-35%  of the salary.
                   Mid junior – 30% of the salary.
                   Immediate senior level- 22% of the salary.
                   Expert level- 20% of the salary.
                   Director – 15% of the salary.
you have to update the salaries accordingly and update it back in the original database. */
update camp set salary_in_usd = case
when experience_level = 'EN' then salary_in_usd * 0.35
when experience_level = 'MI' then salary_in_usd * 0.30
when experience_level = 'SE' then salary_in_usd * 0.22
when experience_level = 'EX' then salary_in_usd * 0.20
when experience_level = 'DX' then salary_in_usd * 0.15
end where work_year = 2024;

/*9. You are a researcher and you have been assigned the task to Find the year with the highest average salary for each job title.*/
with avg_year as (select job_title,work_year,avg(salary_in_usd) as av from salaries group by work_year,job_title)
select job_title,work_year, av from (
select job_title,work_year, av, rank() over (partition by job_title order by av desc ) as rank_by_salary from avg_year)as ranked_salary
where rank_by_salary=1;

/*10. You have been hired by a market research agency where you been assigned the task to show the percentage of different employment type (full time, part time) in 
Different job roles, in the format where each row will be job title, each column will be type of employment type and  cell value  for that row and column will show 
the % value*/
select job_title,
round((sum(case when employment_type = 'PT' then 1 else 0 end )/count(*))*100,2) as PT_per,
round((sum(case when employment_type = 'FT' then 1 else 0 end )/count(*))*100,2) as FT_per,
round((sum(case when employment_type = 'CT' then 1 else 0 end )/count(*))*100,2) as CT_per,
round((sum(case when employment_type = 'FL' then 1 else 0 end )/count(*))*100,2) as FL_per
from salaries group by job_title;