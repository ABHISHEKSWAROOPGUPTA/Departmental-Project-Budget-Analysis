CREATE DATABASE Project;
USE PROJECT 
SELECT * FROM DEPARTMENTS;
SELECT * FROM COMPLETED_PROJECTS;
SELECT * FROM EMPLOYEES;
SELECT * FROM HEAD_SHOTS;
SELECT * FROM PROJECT_ASSIGNMENTS;
SELECT * FROM PROJECTS;
SELECT * FROM UPCOMING_PROJECTS;

-- changing the columns names for easiy acessable names
ALTER TABLE departments
CHANGE COLUMN ï»¿Department_ID department_id INT;
ALTER TABLE head_shots
CHANGE COLUMN ï»¿Employee_ID employee_id INT;
ALTER TABLE employees
CHANGE COLUMN ï»¿employee_id employee_id INT;

-- Problem Statements
-- QUE1 : How effectively are departments utilizing their budgets in completed projects, 
-- and what percentage of the total department budget has been spent on projects?

SELECT 
    d.Department_Name, 
    d.Department_Budget, 
    COALESCE(SUM(cp.project_budget), 0) AS Total_Project_Spent,
    ROUND((COALESCE(SUM(cp.project_budget), 0) / d.Department_Budget) * 100, 2) AS Budget_Utilization_Percentage
FROM 
    departments d
LEFT JOIN 
    completed_projects cp ON d.Department_ID = cp.department_id
GROUP BY 
    d.Department_Name, d.Department_Budget;
    
-- QUE2 : Which departments have the highest employee involvement in projects, 
-- and how is the workforce distributed across completed and upcoming projects?

-- For Employee Involvement in Completed Projects
SELECT 
    d.department_name AS Departments,
    COUNT(DISTINCT pa.employee_id) AS Employees_Involved_Completed_Projects,
    'Completed' AS Project_Type
FROM 
    departments d
JOIN 
    completed_projects cp ON d.department_id = cp.department_id
JOIN 
    project_assignments pa ON cp.project_id = pa.project_id
GROUP BY 
    d.department_name

UNION

-- For Employee Involvement in Upcoming Projects
SELECT 
    d.department_name AS Department,
    COUNT(DISTINCT pa.employee_id) AS Employees_Involved_Upcoming_Projects,
    'Upcoming' AS Project_Type
FROM 
    departments d
JOIN 
    upcoming_projects up ON d.department_id = up.department_id
JOIN 
    project_assignments pa ON up.project_id = pa.project_id
GROUP BY 
    d.department_name;

-- QUE3 : What is the project completion rate for each department, and are departments meeting their project goals?

-- Project Completion Rate for Each Department
SELECT 
    d.department_name AS Department,
    COUNT(DISTINCT cp.project_id) AS Completed_Projects,
    COUNT(DISTINCT p.project_id) AS Total_Projects,
    ROUND((COUNT(DISTINCT cp.project_id) / COUNT(DISTINCT p.project_id)) * 100, 2) AS Project_Completion_Rate_Percentage
FROM 
    departments d
LEFT JOIN 
    completed_projects cp ON d.department_id = cp.department_id
LEFT JOIN 
    projects p ON d.department_id = p.department_id
GROUP BY 
    d.department_name;
    
-- Departments Are Meeting Their Project Goals
SELECT 
    d.department_name AS Department,
    d.department_goals AS Department_Goals,
    COUNT(DISTINCT cp.project_id) AS Completed_Projects,
    CASE 
        WHEN COUNT(DISTINCT cp.project_id) >= d.department_goals THEN 'Goals Met'
        ELSE 'Goals Not Met'
    END AS Goal_Achievement_Status
FROM 
    departments d
LEFT JOIN 
    completed_projects cp ON d.department_id = cp.department_id
GROUP BY 
    d.department_name, d.department_goals;


-- Que4 : What are the average and total project budgets for completed and upcoming projects across different departments? 
-- Are some departments receiving larger project budgets compared to others?

-- Average and Total Budgets for Completed Projects
SELECT 
    d.department_name AS Department,
    SUM(cp.project_budget) AS Total_Completed_Budget,
    AVG(cp.project_budget) AS Average_Completed_Budget,
    'Completed' AS Project_Type
FROM 
    departments d
JOIN 
    completed_projects cp ON d.department_id = cp.department_id
GROUP BY 
    d.department_name

UNION ALL

-- Average and Total Budgets for Upcoming Projects
SELECT 
    d.department_name AS Department,
    SUM(up.project_budget) AS Total_Upcoming_Budget,
    AVG(up.project_budget) AS Average_Upcoming_Budget,
    'Upcoming' AS Project_Type
FROM 
    departments d
JOIN 
    upcoming_projects up ON d.department_id = up.department_id
GROUP BY 
    d.department_name;
    
-- QUE5 : Are there any significant delays in project completion, 
-- and how do the durations of completed projects compare across departments?

-- Project Durations and Analyze Delays for Completed Projects
SELECT 
    d.department_name AS Department,
    cp.project_name AS Project_Name,
    cp.project_start_date,
    cp.project_end_date,
    DATEDIFF(cp.project_end_date, cp.project_start_date) AS Project_Duration,
    CASE 
        WHEN DATEDIFF(cp.project_end_date, cp.project_start_date) > 30 THEN 'Delayed'
        ELSE 'On Time'
    END AS Delay_Status
FROM 
    departments d
JOIN 
    completed_projects cp ON d.department_id = cp.department_id
ORDER BY 
    d.department_name, Project_Duration;
    
-- QUE6 : How aligned are the completed and upcoming projects with the stated departmental goals? 
-- Are departments working towards their goals through the projects they are assigned?

-- Alignment of Completed and Upcoming Projects with Departmental Goals
SELECT 
    d.department_name AS Department,
    d.department_goals AS Department_Goals,
    COUNT(DISTINCT cp.project_id) AS Completed_Projects,
    COUNT(DISTINCT up.project_id) AS Upcoming_Projects,
    COUNT(DISTINCT cp.project_id) + COUNT(DISTINCT up.project_id) AS Total_Projects,
    CASE 
        WHEN (COUNT(DISTINCT cp.project_id) + COUNT(DISTINCT up.project_id)) >= d.department_goals THEN 'On Track'
        ELSE 'Not On Track'
    END AS Goal_Alignment_Status
FROM 
    departments d
LEFT JOIN 
    completed_projects cp ON d.department_id = cp.department_id
LEFT JOIN 
    upcoming_projects up ON d.department_id = up.department_id
GROUP BY 
    d.department_name, d.department_goals
ORDER BY 
    d.department_name;


-- QUE7 : Are project leads and resources (employees) being distributed equally across departments, 
-- or are some departments overloaded with work?

-- Distribution of Project Leads and Employees Across Departments

SELECT 
    d.department_name AS Department,
    COUNT(DISTINCT cp.project_id) AS Total_Completed_Projects,
    COUNT(DISTINCT up.project_id) AS Total_Upcoming_Projects,
    COUNT(DISTINCT pa.employee_id) AS Total_Employees_Assigned,
    COUNT(DISTINCT up.project_lead) AS Total_Project_Leads,
    COUNT(DISTINCT pa.assignment_id) AS Total_Assignments
FROM 
    departments d
LEFT JOIN 
    completed_projects cp ON d.department_id = cp.department_id
LEFT JOIN 
    upcoming_projects up ON d.department_id = up.department_id
LEFT JOIN 
    project_assignments pa ON pa.project_id IN (cp.project_id, up.project_id)
GROUP BY 
    d.department_name
ORDER BY 
    Total_Employees_Assigned DESC, Total_Project_Leads DESC;
    
    
 -- Query for the front page

SELECT 
    e.employee_id,
    e.first_name,
    e.last_name,
    e.job_title,
    e.salary,
    d.department_name AS Department_Name,
    p.project_id,
    p.project_name,
    CASE 
        WHEN cp.project_id IS NOT NULL THEN 'completed'
        ELSE 'upcoming'
    END AS status
FROM 
    employees e
JOIN 
    project_assignments pa ON e.employee_id = pa.employee_id
JOIN 
    projects p ON pa.project_id = p.project_id
LEFT JOIN 
    completed_projects cp ON p.project_id = cp.project_id
JOIN 
    departments d ON p.department_id = d.department_id;