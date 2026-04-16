CREATE DATABASE BANKING;
USE BANKING;
drop table loan_data;
CREATE TABLE staging_data (
    customer_id text,
    age text,
    income text,
    employment_status TEXT,
    credit_score text,
    loan_amount text, 
    loan_type TEXT,
    interest_rate text,
    tenure_months text,
    previous_loans text,
    repayment_history TEXT,
    defaults text,
    loan_status TEXT
);
select * from staging_data;

SELECT COUNT(*) FROM staging_data;

SELECT age, COUNT(*)
FROM staging_data
WHERE age NOT REGEXP '^[0-9]+$'
GROUP BY age;

SELECT COUNT(*)
FROM staging_data
WHERE age = '' OR age IS NULL;

SELECT age
FROM staging_data
WHERE age != TRIM(age)
LIMIT 10;

SELECT age, COUNT(*)
FROM staging_data
GROUP BY age
HAVING CAST(age AS UNSIGNED) < 18 
    OR CAST(age AS UNSIGNED) > 100;

select income,count(*) from staging_data
where income not regexp '^-?[0-9]+(\\.[0-9]+)?$'
group by income;

SELECT employment_status, 
       round(avg(CAST(credit_score AS signed))) AS avg_credit_score
FROM staging_data
GROUP BY employment_status;

SELECT AVG(CAST(income AS DECIMAL(10,2))) AS avg_income
FROM staging_data
WHERE income REGEXP '^[0-9]+(\\.[0-9]+)?$';

select credit_score, count(*) 
from staging_data
where credit_score not regexp '^[0-9]+$'
group by credit_score;

SELECT 
    min(CAST(credit_score AS UNSIGNED)) AS min_score,
    MAX(CAST(credit_score AS UNSIGNED)) AS max_score
FROM staging_data;

create table clean_data(
select * from staging_data);

select*from clean_data;

update clean_data
set age = age+0;

SELECT age
FROM clean_data
WHERE age NOT REGEXP '^[0-9]+$' OR age IS NULL;

ALTER TABLE clean_data
MODIFY age INT;

select age,count(*)
from clean_data
where age < 18
group by age;

delete from clean_data
WHERE AGE<18;

update clean_data
set income = income+0;

update clean_data
set income = (select avg_income from (
select avg(income) as avg_income from clean_data)t)
where income = 0;

select defaults, count(*)
from clean_data 
where defaults not regexp "^[0-9]+$"
group by defaults;

update clean_data
set defaults = defaults+0;

describe clean_data;

alter table clean_data
modify income int;

alter table clean_data
modify	customer_id varchar(10);

select loan_type,count(*)
from clean_data
group by loan_type;

alter table clean_data
modify	loan_type varchar(10);

select loan_status,count(*)
from clean_data
group by loan_status;

alter table clean_data
modify	loan_status varchar(10);

select repayment_history,count(*)
from clean_data
group by repayment_history;

alter table clean_data
modify	repayment_history varchar(10);

alter table clean_data
add clean_credit_score int;

alter table clean_data
modify income int;

update clean_data c 
join(
 select employment_status,
 round(avg(cast(credit_score as signed))) as avg_credit_score
 from clean_data
 group by employment_status
)t
 on t.employment_status = c.employment_status
 set c.clean_credit_score =
 case 
 when cast(c.credit_score as signed) < 300
 then t.avg_credit_score
 else cast(c.credit_score as signed) 
 end;
 
 SELECT DISTINCT credit_score
FROM clean_data
WHERE credit_score NOT REGEXP '^[0-9]+$';
 
 SELECT COUNT(*)
FROM clean_data
WHERE credit_score = '';

UPDATE clean_data
SET credit_score = NULL
WHERE TRIM(credit_score) = '';

alter table clean_data
modify clean_credit_score int;

describe clean_data;

SELECT credit_score
FROM clean_data
LIMIT 20;

update clean_data c
join(
select employment_status,
round(avg(credit_score)) as avg_c_s
from clean_data 
where credit_score is not null
group by employment_status)t 
on t.employment_status = c.employment_status
set c.credit_score = t.avg_c_s
where c.credit_score is null;

alter table clean_data 
drop column credit_score;

alter table clean_data
rename column clean_credit_score to credit_score;

ALTER TABLE clean_data
MODIFY credit_score INT
AFTER income;

select interest_rate,count(*)
from clean_data
where interest_rate not regexp "^[0-9]+(\\.[0-9]+)?$"
group by interest_rate;

select * from clean_data;

update clean_data 
set interest_rate=interest_rate+0;

alter table clean_data
modify interest_rate decimal(5,2);

update clean_data 
set loan_amount=loan_amount+0;

alter table clean_data
modify loan_amount decimal(10,2);

describe clean_data;

select tenure_months,count(*)
from clean_data
where tenure_months not regexp "^[0-9]+(\\.[0-9]+)?$"
group by tenure_months;

select tenure_months,count(*)
from clean_data 
where tenure_months =" "
group by tenure_months;

update clean_data 
set tenure_months = tenure_months+0;

alter table clean_data 
modify tenure_months int;

describe clean_data;
select * from clean_data;

select previous_loans,count(*)
from clean_data
where previous_loans not regexp "^[0-9]+$"
group by previous_loans;

update clean_data
set previous_loans = previous_loans+0;

alter table clean_data
modify previous_loans int;

describe clean_data;
select * from clean_data;

select defaults,count(*)
from clean_data
where defaults not regexp "^[0-9]+$"
group by defaults;

update clean_data
set	defaults = defaults+0;

alter table clean_data
modify defaults int;

rename table Loan_data to clean_data;

describe loan_data;
select * from clean_data;
SELECT customer_id, COUNT(*) 
FROM loan_data
GROUP BY customer_id
HAVING COUNT(*) > 1;


CREATE TABLE `loan_data` (
  `customer_id` varchar(10) DEFAULT NULL,
  `age` int DEFAULT NULL,
  `income` int DEFAULT NULL,
  `credit_score` int DEFAULT NULL,
  `employment_status` varchar(15) DEFAULT NULL,
  `loan_amount` decimal(10,2) DEFAULT NULL,
  `loan_type` varchar(10) DEFAULT NULL,
  `interest_rate` decimal(5,2) DEFAULT NULL,
  `tenure_months` int DEFAULT NULL,
  `previous_loans` int DEFAULT NULL,
  `repayment_history` varchar(10) DEFAULT NULL,
  `defaults` int DEFAULT NULL,
  `loan_status` varchar(10) DEFAULT NULL,
  `row_num` int
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;


insert into loan_data(
select *,
row_number() over( partition by customer_id, age, income, credit_score, employment_status, loan_amount, loan_type, interest_rate, tenure_months, previous_loans, repayment_history, defaults, loan_status)
as row_num
from clean_data);

delete from loan_data
where row_num>1;

select*from loan_data;
describe loan_data;
alter table loan_data
drop column row_num;

create table customers(
customer_id varchar(10),
age int,
income int,
employment_status varchar(15),
rn int);

select * from customers;

insert into customers
SELECT customer_id, age, income, employment_status
from(
select*, row_number() over( partition by customer_id order by income) as rn
from loan_data
)t
where rn=1;

select count(*) from customers;

ALTER TABLE customers
ADD PRIMARY KEY (customer_id);

describe customers;

CREATE TABLE credit_profile (
  customer_id varchar(10),
  credit_score int,
  repayment_history varchar(10),
  defaults int,
  previous_loans int,
  FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

insert into credit_profile 
select 
	customer_id,
	credit_score,
    repayment_history,
    defaults,
    previous_loans
from (
select *, row_number() over( partition by customer_id order by credit_score desc) as rn
from loan_data 
) t
where rn=1;

select * from credit_profile;
describe loan_details;

create table loan_details (
loan_id int primary key auto_increment,
customer_id varchar(10),
loan_amount int,
loan_type varchar(10),
interest_rate decimal(5,2),
tenure_months int,
loan_status varchar(10),
foreign key (customer_id) references customers(customer_id)
);

insert into loan_details
		(customer_id,
		loan_amount,
        loan_type,
        interest_rate,
        tenure_months,
        loan_status)
 select customer_id,
		loan_amount,
        loan_type,
        interest_rate,
        tenure_months,
        loan_status
from loan_data;

select * from loan_details;