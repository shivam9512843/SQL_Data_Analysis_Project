-- DATA CLEANING

select*
from layoffs
;

-- 1. check for duplicates and remove any
-- 2. standardize data and fix errors
-- 3. Look at null values and see what 
-- 4. remove any columns and rows that are not necessary - few ways


create table layoffs_stagging
like layoffs
;

select * from layoffs_stagging;

insert into layoffs_stagging
select * 
from layoffs
;

select *,
row_number() over(
partition by company, industry, total_laid_off, percentage_laid_off, `date`) as row_num
from layoffs_stagging
;

-- to see duplicates if greater then 1

with duplicate_cte as (
select *,
row_number() over(
partition by company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) as row_num
from layoffs_stagging
)
select * 
from duplicate_cte
where row_num > 1
;

-- to check particular
select * 
from layoffs_stagging
where company = 'oda';


CREATE TABLE `layoffs_stagging2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` int
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

select * from layoffs_stagging2
where row_num > 1;

-- inserting 
insert into layoffs_stagging2
select *,
row_number() over(
partition by company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) as row_num
from layoffs_stagging;

-- to use to disable safe updates 
set sql_safe_updates = 0;

-- delete
delete 
from layoffs_stagging2
where row_num > 1;


-- 2. standardizing data
select company, (trim(company))
from layoffs_stagging2;

-- updating
update layoffs_stagging2
set company = trim(company);

select distinct industry
from layoffs_stagging2 order by 1;

select * from layoffs_stagging2
where industry like 'Crypto%';

-- updating 
update layoffs_stagging2
set industry = 'Crypto'
where industry like 'Crypto%';

select distinct industry
from layoffs_stagging2
order by 1;

select distinct country, trim(trailing '.' from country)
from layoffs_stagging2
order by 1;	

update layoffs_stagging2
set country = trim(trailing '.' from country)
where country like 'United States%';


select `date`,
str_to_date(`date`, '%m/%d/%Y')
from layoffs_stagging2;

update layoffs_stagging2
set `date` = str_to_date(`date`, '%m/%d/%Y');

alter table layoffs_stagging2
modify column `date` date;


-- missing and null value

select *
from layoffs_stagging2
where total_laid_off is null
and percentage_laid_off is null
;

-- to check any null value 
select *
from layoffs_stagging2
where industry is null 
or industry = ''
;

-- to join and check null
select t1.industry, t2.industry
from layoffs_stagging2 t1
join layoffs_stagging2 t2
on t1.company = t2.company
where (t1.industry is null or t1.industry ='')
and t2.industry is not null
;

update layoffs_stagging2
set industry = null
where industry = ''
;

select * from layoffs_stagging2;


-- updating null 
update layoffs_stagging2 t1
join layoffs_stagging2 t2
	on t1.company = t2.company
    set t1.industry = t2.industry
where t1.industry is null 
and t2.industry is not null
;

select * from layoffs_stagging2
where company = 'Airbnb';

select *
from layoffs_stagging2
where total_laid_off is null 
and percentage_laid_off is null
;

delete
from layoffs_stagging2
where total_laid_off is null 
and percentage_laid_off is null
;

alter table layoffs_stagging2
drop column row_num
;