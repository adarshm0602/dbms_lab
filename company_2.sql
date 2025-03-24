-- 1. List all project numbers for projects that involve an employee whose last name is ‘Scott’ 
-- either as a worker or as a manager of the department that controls the project.
SELECT DISTINCT P.PNo 
FROM PROJECT P
JOIN DEPARTMENT D ON P.DNo = D.DNo
JOIN EMPLOYEE E ON D.MgrSSN = E.SSN OR E.SSN IN (SELECT W.SSN FROM WORKS_ON W WHERE W.PNo = P.PNo)
WHERE E.Name LIKE '%Scott';

-- 2. Show the resulting salaries if every employee working on the ‘IoT’ project is given a 10% raise.
SELECT E.SSN, E.Name, E.Salary * 1.1 AS NewSalary
FROM EMPLOYEE E
JOIN WORKS_ON W ON E.SSN = W.SSN
JOIN PROJECT P ON W.PNo = P.PNo
WHERE P.PName = 'IoT';

-- 3. Find sum, max, min, and average salary of employees in the ‘Accounts’ department.
SELECT SUM(E.Salary) AS TotalSalary, 
       MAX(E.Salary) AS MaxSalary, 
       MIN(E.Salary) AS MinSalary, 
       AVG(E.Salary) AS AvgSalary
FROM EMPLOYEE E
JOIN DEPARTMENT D ON E.DNo = D.DNo
WHERE D.DName = 'Accounts';

-- 4. Retrieve the name of each employee who works on all projects controlled by department number 5.
SELECT E.Name
FROM EMPLOYEE E
WHERE NOT EXISTS (
    SELECT P.PNo 
    FROM PROJECT P
    WHERE P.DNo = 5
    EXCEPT
    SELECT W.PNo
    FROM WORKS_ON W
    WHERE W.SSN = E.SSN
);

-- 5. Retrieve department number and number of employees making more than Rs. 6,00,000, 
-- but only for departments with more than 5 employees.
SELECT E.DNo, COUNT(E.SSN) AS NumEmployees
FROM EMPLOYEE E
GROUP BY E.DNo
HAVING COUNT(E.SSN) > 5 AND SUM(CASE WHEN E.Salary > 600000 THEN 1 ELSE 0 END) > 0;

-- 6. Create a view showing employee name, department name, and location.
CREATE VIEW EmployeeDeptView AS
SELECT E.Name, D.DName, DL.DLoc
FROM EMPLOYEE E
JOIN DEPARTMENT D ON E.DNo = D.DNo
JOIN DLOCATION DL ON D.DNo = DL.DNo;

-- 7. Create a trigger to prevent deletion of a project if any employee is currently working on it.
CREATE TRIGGER PreventProjectDeletion
BEFORE DELETE ON PROJECT
FOR EACH ROW
BEGIN
    IF EXISTS (SELECT * FROM WORKS_ON WHERE PNo = OLD.PNo) THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Cannot delete project as employees are currently working on it';
    END IF;
END;
