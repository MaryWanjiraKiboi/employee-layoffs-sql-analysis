/* 
SQL Practice Project

Concepts Covered:
- SELECT & WHERE
- GROUP BY & HAVING
- JOINS (INNER, LEFT, SELF JOIN)
- Window Functions (ROW_NUMBER, RANK)
- CTEs
- Data Cleaning (TRIM, STR_TO_DATE)
- Stored Procedures
- Triggers
- Temporary Tables

Environment: MySQL
*/

/*SELECT */

SELECT *
FROM employee_salary
WHERE first_name ='Leslie'
;

SELECT *
FROM employee_salary
WHERE salary >=50000
;

SELECT *
FROM employee_demographics
WHERE birth_date >'1985-01-01'
;

SELECT *
FROM employee_demographics
WHERE birth_date >'1985-01-01'
;


SELECT *
FROM employee_demographics
WHERE birth_date >'1985-01-01' OR  NOT gender='Male'
;

SELECT *
FROM employee_demographics
WHERE first_name LIKE'%er%';

/*TRIM */
SELECT company,TRIM(company)
FROM layoffs_staging2;

UPDATE layoffs_staging2
SET company=TRIM(company);

SELECT DISTINCT industry
FROM layoffs_staging2
ORDER BY 1;

SELECT*
FROM layoffs_staging2
WHERE industry LIKE 'Crypto%';

SELECT*
FROM layoffs_staging2;

SELECT`date`,
STR_TO_DATE (`date`,'%m/%d/%Y')
FROM layoffs_staging2;

UPDATE layoffs_staging2 
SET`date`= STR_TO_DATE (`date`,'%m/%d/%Y');


ALTER TABLE layoffs_staging2
MODIFY COLUMN `date` DATE;

SELECT*
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS  NULL;

SELECT *
FROM layoffs_staging2;
SELECT MAX(total_laid_off), MAX(percentage_laid_off)
FROM layoffs_staging2;

SELECT *
FROM layoffs_staging2
WHERE percentage_laid_off=1
ORDER BY total_laid_off DESC;

SELECT company,SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company
ORDER BY 2 DESC;

Select*
FROM layoffs_staging2
WHERE industry IS NULL
OR industry=' ';

SELECT *
FROM layoffs_staging2;

ALTER TABLE layoffs_staging2
DROP COLUMN row_num;

SELECT *
FROM layoffs_staging2;

SELECT MIN(`date`),MAX(`date`)
FROM layoffs_staging2;


/*PARTITION */
SELECT*
FROM layoffs;

SELECT*
FROM layoffs_staging;

SELECT*,
ROW_NUMBER () OVER(
PARTITION BY company,location,stage,funds_raised, country, total_laid_off,`date`) AS row_num
FROM layoffs_staging;

WITH duplicate_cte AS
(SELECT*,
ROW_NUMBER () OVER(
PARTITION BY company,location,stage,funds_raised, country, total_laid_off,`date`) AS row_num
FROM layoffs_staging)
SELECT*
FROM duplicate_cte
WHERE row_num >1;

SELECT *
FROM layoffs_staging
WHERE company = 'Cazoo';

CREATE TABLE `layoffs_staging2` (
  `company` text,
  `location` text,
  `total_laid_off` text,
  `date` text,
  `percentage_laid_off` text,
  `industry` text,
  `source` text,
  `stage` text,
  `funds_raised` text,
  `country` text,
  `date_added` text,
  `row_num` INT
  
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

SELECT *
FROM layoffs_staging2;

INSERT INTO layoffs_staging2
(SELECT*,
ROW_NUMBER () OVER(
PARTITION BY company,location,stage,funds_raised, country, total_laid_off,`date`) AS row_num
FROM layoffs_staging);

/*INSERTBY*/

SELECT*
FROM layoffs_staging2
WHERE row_num > 1;

SET SQL_SAFE_UPDATES =0;

DELETE 
FROM layoffs_staging2
WHERE row_num > 1;

SELECT*
FROM layoffs_staging2;



UPDATE layoffs_staging2
SET company = TRIM(company);



SELECT*
FROM employee_demographics;

SELECT*
FROM employee_salary;


DELIMITER $$
CREATE TRIGGER employee_insert 
  AFTER INSERT ON employee_salary
  FOR EACH ROW
BEGIN  
  INSERT INTO employee_demographics (employee_id,first_name,last_name)
  VALUES (NEW.employee_id,NEW.first_name,NEW.last_name);
END $$
DELIMITER ;
  
  
  INSERT INTO employee_salary(employee_id,first_name,last_name,occupation,salary,dept_id)
  VALUES (13,'Jean-Ralphio','Saperstein','Exntertainment 720 CEO',1000000,NULL);
  
  
  
SELECT*
FROM employee_salary
WHERE salary >= 50000;

DELIMITER $$
CREATE PROCEDURE  large_salaries()
BEGIN
SELECT*
FROM employee_salary
WHERE salary >= 50000;
END $$
DELIMITER;


/*DELIMIER*/

CALL large_salaries();

DELIMITER $$
CREATE PROCEDURE  large_salaries2()
BEGIN
 SELECT*
 FROM employee_salary
 WHERE salary >= 50000;
 SELECT*
 FROM employee_salary
 WHERE salary >= 10000;
END $$
DELIMITER ;

CALL large_salaries2();
  
  /*TEMPORARY TABLE*/
  

CREATE TEMPORARY TABLE temp_table
(first_name varchar(50),
last_name varchar(50),
favorite_movie varchar(100)
);

SELECT*
FROM temp_table;


INSERT INTO temp_table
VALUES('Mary','Wanjira','Enough');

SELECT*
FROM temp_table;

/*CTE*/

WITH CTE_Example AS
(
SELECT gender, AVG(salary) avg_sal, MAX(salary)max_sal, MIN(salary)min_sal, COUNT(salary)count_sal
FROM employee_demographics dem
JOIN employee_salary sal
  ON dem.employee_id = sal.employee_id
GROUP BY gender
)
SELECT AVG(avg_sal)
FROM CTE_Example
;

SELECT AVG(avg_sal)
FROM CTE_Example;


WITH CTE_Example AS
(
SELECT employee_id,gender,birth_date
FROM employee_demographics dem
WHERE birth_date >'1985-01-01'
),
CTE_Example2 AS
(
SELECT employee_id,salary
FROM employee_salary
WHERE salary >50000
)
SELECT *
FROM CTE_Example
JOIN CTE_Example2
  ON CTE_Example.employee_id= CTE_Example2.employee_id
;

/*JOIN*/



SELECT gender,AVG(salary)AS avg_salary
FROM employee_demographics dem
JOIN employee_salary sal
  ON dem.employee_id = sal.employee_id
  GROUP BY gender;
  
  
SELECT dem.first_name,dem.last_name,sal.salary,AVG(salary) OVER(PARTITION BY gender)
FROM employee_demographics dem
JOIN employee_salary sal
  ON dem.employee_id = sal.employee_id
  ;



SELECT dem.first_name,dem.last_name,gender,salary,
ROW_NUMBER() OVER(PARTITION BY gender ORDER BY salary DESC) AS row_num,
RANK()OVER(PARTITION BY gender ORDER BY salary DESC) AS rank_num
FROM employee_demographics dem
JOIN employee_salary sal
  ON dem.employee_id = sal.employee_id
  ;  
  
  
SELECT dem.first_name,dem.last_name,gender,salary,SUM(salary) OVER(PARTITION BY gender ORDER BY dem.employee_id) AS Rolling_Total
FROM employee_demographics dem
JOIN employee_salary sal
  ON dem.employee_id = sal.employee_id
  ;  

  /*GROUP BY*/
 

SELECT*
FROM employee_demographics;
 
 
 SELECT*
 FROM employee_salary;
 
 
SELECT*
FROM employee_demographics
WHERE employee_id IN 
(SELECT employee_id FROM employee_salary WHERE dept_id =1);


 SELECT first_name,salary,
 (SELECT AVG(salary)
 FROM employee_salary)
 FROM employee_salary;
 

SELECT gender,AVG(age),MAX(age),MIN(age),COUNT(age)
FROM employee_demographics
GROUP BY gender;
             
    /*SUBSTRING */        

SELECT LENGTH('skyfall');

SELECT first_name,LENGTH (first_name)
FROM employee_demographics
ORDER BY 2;


SELECT UPPER ('sky');
SELECT LOWER ('SKY');


SELECT first_name, UPPER  (first_name)
FROM employee_demographics;

SELECT RTRIM('      sky     ');


SELECT first_name, 
LEFT(first_name,4),
RIGHT(first_name,4)
FROM employee_demographics;


SELECT first_name, 
LEFT(first_name,4),
RIGHT(first_name,4),
SUBSTRING(first_name,3,2),
birth_date,
SUBSTRING(birth_date,6,2) AS birth_month
FROM employee_demographics;


SELECT first_name ,replace( first_name,'a','z')
FROM employee_demographics;     



SELECT LOCATE ('x', 'Alexander');


SELECT first_name ,LOCATE('An', first_name)
FROM employee_demographics; 


SELECT first_name,last_name,
CONCAT(first_name, '  ',last_name) AS full_name
FROM employee_demographics;

/*WHERE CLAUSE*/
SELECT *
FROM employee_salary
WHERE first_name='Lesile';
 

/*HAVING */
SELECT gender,AVG(age)
FROM employee_demographics
GROUP BY gender
HAVING AVG(age)> 40
;

SELECT occupation,AVG(salary)
FROM employee_salary
GROUP BY occupation;

SELECT occupation,AVG(salary)
FROM employee_salary
WHERE occupation LIKE '%manager%'
GROUP BY occupation
HAVING AVG(salary)>75000;

/*JOINS*/
SELECT dem.employee_id,age,occupation
FROM employee_demographics AS dem
INNER JOIN employee_salary AS sal
   ON dem.employee_id=sal.employee_id;
   
   
   SELECT *
FROM employee_demographics AS dem
LEFT JOIN employee_salary AS sal
   ON dem.employee_id=sal.employee_id;
   
   SELECT emp1.employee_id AS emp_santa,
    emp1.first_name AS first_name_santa,
	emp1.last_name AS last_name_santa,
	emp2.employee_id AS emp_name,
	emp2.first_name AS first_name_emp,
	emp2.last_name AS last_name_emp
   FROM employee_salary emp1
   JOIN employee_salary emp2
    ON emp1.employee_id+    1 = emp2.employee_id 
    ;
    
    
SELECT *
FROM employee_demographics AS dem
INNER JOIN employee_salary AS sal
ON dem.employee_id=sal.employee_id
INNER JOIN parks_departments pd
ON sal.dept_id=pd.department_id;
   
   
   SELECT*
   FROM parks_departments;
   
   /*AND*/
   SELECT*
FROM employee_salary
WHERE first_name ='Leslie'
;

select*
FROM employee_salary
WHERE salary >'80000'
;


select*
FROM employee_demographics
WHERE birth_date >'1985-01-01'
AND gender= 'male'
;

/*GROUP BY*/

SELECT gender
FROM employee_demographics _demographics
GROUP BY gender;

SELECT occupation ,salary
FROM employee_salary
GROUP BY  occupation, salary
;

SELECT gender,AVG(age),min(age),Max(age),COUNT(age)
FROM employee_demographics 
GROUP BY gender;

SELECT *
FROM employee_demographics 
ORDER BY age,gender
;

/*LIMIT*/
SELECT *
FROM employee_demographics
LIMIT 3 ;


SELECT *
FROM employee_demographics
ORDER BY age DESC
LIMIT 3 ;

SELECT *
FROM employee_demographics
ORDER BY age DESC
LIMIT 2,1 ;


SELECT gender, AVG(age) AS avg_age
FROM employee_demographics
GROUP BY gender;