create table bank_customers
(
customer_id bigint,
credit_score int,
country varchar(50),
gender varchar(50),
age int,
tenure int,
balance float,
products_number int,
credit_card int,
active_member int,
estimated_salary float,
churn int

);
-- exploring dataset
select count(*) from bank_customers;

select count(*) from bank_customers
where customer_id isnull;

-- checking null values
SELECT 
  COUNT(*) FILTER (WHERE customer_id IS NULL) AS null_customer_id,
  COUNT(*) FILTER (WHERE credit_score IS NULL) AS null_credit_score,
  COUNT(*) FILTER (WHERE country IS NULL) AS null_country,
  COUNT(*) FILTER (WHERE gender IS NULL) AS null_gender,
  COUNT(*) FILTER (WHERE age IS NULL) AS null_age,
  COUNT(*) FILTER (WHERE tenure IS NULL) AS null_tenure,
  COUNT(*) FILTER (WHERE balance IS NULL) AS null_balance,
  COUNT(*) FILTER (WHERE products_number IS NULL) AS null_products_number,
  COUNT(*) FILTER (WHERE credit_card IS NULL) AS null_credit_card,
  COUNT(*) FILTER (WHERE active_member IS NULL) AS null_active_member,
  COUNT(*) FILTER (WHERE estimated_salary IS NULL) AS null_estimated_salary,
  COUNT(*) FILTER (WHERE churn IS NULL) AS null_churn
FROM bank_customers;

select min(age),
max(age)
from bank_customers;

-- data exp, how many customers in each age group
select
case 
when age between 18 and 30 then '18-29'
when age between 30 and 45 then '30-45'
when age between 45 and 60 then '45-60'
when age > 60 then 'above 60'
else 'unknown'
end as age_group,
count(*)

from bank_customers

group by age_group
order by 1

-- churn rate by age
SELECT 
    CASE 
        WHEN age BETWEEN 18 AND 29 THEN '18-29'
        WHEN age BETWEEN 30 AND 45 THEN '30-45'
        WHEN age BETWEEN 46 AND 60 THEN '46-60'
        WHEN age > 60 THEN '60+'
        ELSE 'Unknown' 
    END AS age_group,
    COUNT(*) AS total_customers,
    SUM(churn) AS churned,
    ROUND(SUM(churn) * 100.0 / COUNT(*), 2) AS churn_rate
FROM 
    bank_customers
GROUP BY 
    age_group
ORDER BY 
    churn_rate DESC;

--Churn by Country and Gender
select 
country, 
gender,
COUNT(*) AS total_customers,
sum(churn) as Churns,
round((sum(churn)*100/count(*))) as Churn_Percent
from bank_customers
GROUP BY 
    1,2
ORDER BY 
    5 DESC;

--Is there any relationship between the number of products a customer uses and their likelihood to churn?

select distinct(products_number) from bank_customers

select 
products_number as No_of_products, 
COUNT(*) AS total_customers,
sum(churn) as Churns,
round((sum(churn)*100/count(*))) as Churn_Percent
from bank_customers
GROUP BY 
    1
ORDER BY 
    4 DESC;

-- Is there a pattern between tenure (years with the bank) and churn?

select 
tenure,
COUNT(*) AS total_customers,
sum(churn) as Churns,
round((sum(churn)*100/count(*))) as Churn_Percent
from bank_customers
GROUP BY 
    1
ORDER BY 
    1 DESC;

-- What’s the relationship between credit score and churn? But let’s not look at individual scores
SELECT 
    CASE 
        WHEN credit_score BETWEEN 350 AND 500 THEN 'below 500'
         WHEN credit_score BETWEEN 500 AND 700 THEN '500-700'
        WHEN credit_score > 700 THEN '700+'
        ELSE 'Unknown' 
    END AS credit_group,
    COUNT(*) AS total_customers,
    SUM(churn) AS churned,
    ROUND(SUM(churn) * 100.0 / COUNT(*), 2) AS churn_rate
FROM 
    bank_customers
GROUP BY 
    credit_group
ORDER BY 
    churn_rate DESC;

-- Credit card relationship
SELECT 
    CASE 
        WHEN credit_card=1 THEN 'With_Credit_Card'
		  WHEN credit_card=0 THEN 'Without_Credit_Card'       
        ELSE 'Unknown' 
    END AS cc_holder,
    COUNT(*) AS total_customers,
    SUM(churn) AS churned,
    ROUND(SUM(churn) * 100.0 / COUNT(*), 2) AS churn_rate
FROM 
    bank_customers
GROUP BY 
    cc_holder
ORDER BY 
    churn_rate DESC;

--Does customer engagement level (i.e., being an active member or not) affect churn?
SELECT 
    CASE 
        WHEN active_member=1 THEN 'Active'
		  WHEN active_member=0 THEN 'InActive'       
        ELSE 'Unknown' 
    END AS Member_activeness,
    COUNT(*) AS total_customers,
    SUM(churn) AS churned,
    ROUND(SUM(churn) * 100.0 / COUNT(*), 2) AS churn_rate
FROM 
    bank_customers
GROUP BY 
    Member_activeness
ORDER BY 
    churn_rate DESC;

-- Balance corelation
SELECT 
  balance_quartile,
  COUNT(*) AS total_customers,
  SUM(churn) AS churned,
  ROUND(SUM(churn) * 100.0 / COUNT(*), 2) AS churn_rate
FROM (
  SELECT *,
         NTILE(4) OVER (ORDER BY balance) AS balance_quartile
  FROM bank_customers
) sub
GROUP BY balance_quartile
ORDER BY balance_quartile;

--Salary
SELECT 
  salary_quartile,
  COUNT(*) AS total_customers,
  SUM(churn) AS churned,
  ROUND(SUM(churn) * 100.0 / COUNT(*), 2) AS churn_rate
FROM (
  SELECT *,
         NTILE(4) OVER (ORDER BY estimated_salary) AS salary_quartile
  FROM bank_customers
) sub
GROUP BY salary_quartile
ORDER BY salary_quartile;

--Multivarient ananlysy
-- How does churn vary across different age groups and number of products held?

SELECT 
    CASE 
        WHEN age BETWEEN 18 AND 29 THEN '18-29'
        WHEN age BETWEEN 30 AND 45 THEN '30-45'
        WHEN age BETWEEN 46 AND 60 THEN '46-60'
        WHEN age > 60 THEN '60+'
        ELSE 'Unknown' 
    END AS age_group,
	products_number as No_of_products,
    COUNT(*) AS total_customers,
    SUM(churn) AS churned,
    ROUND(SUM(churn) * 100.0 / COUNT(*), 2) AS churn_rate
FROM 
    bank_customers
GROUP BY 
    1,2
ORDER BY 
    5 DESC;

--Let’s now analyze churn by member activity + number of products
SELECT 
    CASE 
        WHEN active_member = 1 THEN 'Active'
        WHEN active_member = 0 THEN 'InActive'
        ELSE 'Unknown'
    END AS member_activeness,
    products_number AS no_of_products,
    COUNT(*) AS total_customers,
    SUM(churn) AS churned,
    ROUND(SUM(churn) * 100.0 / COUNT(*), 2) AS churn_rate
FROM 
    bank_customers
GROUP BY 
    member_activeness, no_of_products
ORDER BY 
    churn_rate DESC;
