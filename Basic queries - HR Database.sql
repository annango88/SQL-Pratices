USE W3resource_Hr
GO

/*find those employees whose salaries are less than 6000 and those with higher than 8000*/
SELECT  
	CONCAT (first_name,' ',	last_name) as full_name,
	salary
FROM employees
WHERE salary <6000 OR salary>8000
ORDER BY 2 DESC

/*find those employees whose salaries between 6000 and 8000*/
SELECT  
	CONCAT (first_name,' ',	last_name) as full_name,
	salary
FROM employees
WHERE salary BETWEEN 6000 AND 8000
ORDER BY 2 DESC

/*find those employees whose first name does not contain the letter ‘M’*/
SELECT  
	CONCAT (first_name,' ',	last_name) as full_name,
	hire_date,
	salary,
	department_id
FROM employees
WHERE first_name NOT LIKE '%M%'
ORDER BY 4 ASC

/*find those employees whose first name ends with letter ‘m’*/
SELECT  
	first_name,	
	last_name,
	salary
FROM employees
WHERE first_name LIKE '%m'

/*find those employees whose were hired between November 5th, 1987 and July 5th, 1990*/
SELECT  
	CONCAT (first_name,' ',	last_name) as full_name,
	job_id,
	hire_date
FROM employees
WHERE hire_date BETWEEN '1987-11-05' AND '1990-07-05'

/*find those employees whose work in departments 9 or 10*/
SELECT  
	CONCAT (first_name,' ',	last_name) as full_name,
	department_id
FROM employees
WHERE department_id= 9 OR department_id = 10

/* count the number of employees, the sum of all salary, 
and difference between the highest salary and lowest salaries by each job id*/

SELECT 
	job_id,
	sum (salary) as total_sal,
	(max (salary)- min(salary)) as sal_dif
FROM employees
GROUP BY job_id
ORDER BY 1 ASC

/*count the number of employees worked under each manager*/

SELECT 
	manager_id,
	count (employee_id) as num_of_emp
FROM employees
GROUP BY manager_id

/*find the departments where any manager manages four or more employees*/

SELECT department_id
FROM employees
GROUP BY department_id, manager_id
HAVING count(employee_id)>4

/*calculate the average salary of each job ID*/

SELECT 
	job_id,
	avg(salary) as avg_sal
FROM employees
GROUP BY job_id




