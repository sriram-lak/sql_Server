DROP DATABASE IF EXISTS Employee;
GO

CREATE DATABASE Employee;
GO

USE Employee;
GO

CREATE PROCEDURE DeleteTable
@tableName NVARCHAR(50)
AS 
BEGIN
	DECLARE @sql NVARCHAR(MAX)
	IF EXISTS (SELECT 1 FROM SYS.TABLES WHERE NAME = @tableName)
		BEGIN
			SET @sql = 'DROP TABLE ['+@tableName+']'
			EXEC sp_executesql @sql
			PRINT 'Drop table successfully'
		END
	ELSE
		BEGIN
			PRINT 'Table is not found'
		END
END;

EXEC DeleteTable 'Department';
GO

CREATE TABLE Department(
departmentId INT IDENTITY(101,1) PRIMARY KEY,
departmentName NVARCHAR(50));

EXEC DeleteTable 'EmployeeDetail'
GO

CREATE TABLE EmployeeDetail(
employeeId INT IDENTITY(1,1) PRIMARY KEY,
employeeName NVARCHAR(50) NOT NULL,
departmentId INT CONSTRAINT FK_EmployeeDetail_Department FOREIGN KEY REFERENCES Department(departmentId),
hiredDate DATE NOT NULL,
managerId INT NULL,
salary MONEY NOT NULL);

INSERT INTO Department(departmentName)
VALUES('IT'),('PRODUCTION'),('FINANCE'),('HR');

INSERT INTO EmployeeDetail(employeeName,departmentId,hiredDate,managerId,salary)
VALUES ('SRIRAM',101,'2025-04-21',NULL,100000),
	   ('RAVI',102,'2025-05-21',1,50000),
	   ('KUMAR',103,'2025-01-21',2,15000);


-- 1,Create a procedure to get employees with salary greater than a given amount.

CREATE PROCEDURE GreaterSalary
@EnterSalary MONEY
AS 
BEGIN
	SELECT employeeName FROM EmployeeDetail
	WHERE salary > @EnterSalary
END;

EXEC GreaterSalary 30000;

-- 2,Create a procedure to update the department of an employee by employee ID.

CREATE PROCEDURE UpdateDepartment
@employeeId INT,
@EnterdepartmentId INT
AS 
BEGIN
	UPDATE EmployeeDetail
	SET departmentId = @EnterdepartmentId
	WHERE employeeId = @employeeId
END;

EXEC UpdateDepartment 2,101;

-- 3,Create a procedure to return the total count of employees in a given department.

DROP PROCEDURE IF EXISTS NumberOfEmployeeBasedOnDepartment;
GO

CREATE PROCEDURE NumberOfEmployeeBasedOnDepartment
@DepartmentId INT
AS 
BEGIN
	SELECT D.departmentName,COUNT(E.departmentId) AS NumberOfEmployees
	FROM Department D
	LEFT JOIN EmployeeDetail E ON E.departmentId = D.departmentId
	WHERE D.departmentId = @DepartmentId
	GROUP BY D.departmentName;
END;

EXEC NumberOfEmployeeBasedOnDepartment 103;

-- 4,Create a procedure that accepts a salary range (min, max) and returns employees within that range.

DROP PROCEDURE IF EXISTS SalaryRange;
GO

CREATE PROCEDURE SalaryRange
@MinRange MONEY,
@MaxRange MONEY
AS 
BEGIN
	SELECT employeeName
	FROM EmployeeDetail
	WHERE salary BETWEEN @MinRange AND @MaxRange
END;

EXEC SalaryRange 10000,50000;

-- 5,Create a procedure to increase the salary of all employees in a specific department by a given percentage.

DROP PROCEDURE IF EXISTS SalaryUpdateBasedOnDepartment;
GO

CREATE PROCEDURE SalaryUpdateBasedOnDepartment
@departmentId INT,
@IncreasePercentage DECIMAL(10,2)
AS 
BEGIN
	UPDATE EmployeeDetail
	SET salary = salary + (salary * (@IncreasePercentage / 100))
	WHERE departmentId = @departmentId
END;

EXEC SalaryUpdateBasedOnDepartment 101,5;

-- 6,Create a procedure to log changes in employee salary: it should insert old and new salary into a separate table whenever an update happens.

EXEC DeleteTable 'SalaryLog'
GO

CREATE TABLE SalaryLog(
logId INT IDENTITY(1001,1) PRIMARY KEY,
employeeId INT CONSTRAINT FK_SalaryLog_EmployeeDetail FOREIGN KEY REFERENCES EmployeeDetail(employeeId),
oldSalary MONEY,
newSalary MONEY,
changeDate DATE );

DROP PROCEDURE IF EXISTS LogUpdate;
GO

CREATE PROCEDURE LogUpdate
@employeeId INT,
@NewSalary MONEY
AS 
BEGIN
	DECLARE @OldSalary MONEY
	SELECT @OldSalary = salary 
	FROM EmployeeDetail
	WHERE employeeId = @employeeId

	UPDATE EmployeeDetail
	SET salary = @NewSalary,salaryUpdateDate = GETDATE()
	WHERE employeeId = @employeeId

	INSERT INTO SalaryLog(employeeId,oldSalary,newSalary,changeDate)
	VALUES (@employeeId,@OldSalary,@NewSalary,GETDATE())
END;

EXEC LogUpdate 3,200;

-- 7,Create a procedure to retrieve employees hired within a certain date range.

DROP PROCEDURE IF EXISTS HiredDateRange;
GO

CREATE PROCEDURE HiredDateRange
@StartDateRange DATE,
@EndDateRange DATE
AS 
BEGIN
	SELECT employeeName
	FROM EmployeeDetail
	WHERE hiredDate BETWEEN @StartDateRange AND @EndDateRange
END;

EXEC HiredDateRange '2025-01-01','2025-04-30';

-- 8,Create a procedure that deletes employees who have not received a salary update for more than 2 years.

ALTER TABLE EmployeeDetail
ADD salaryUpdateDate DATE;

UPDATE EmployeeDetail
SET salaryUpdateDate = hiredDate;

INSERT INTO EmployeeDetail(employeeName,departmentId,hiredDate,managerId,salary,SalaryUpdateDate)
VALUES ('SRIDHAR',101,'2003-04-21',NULL,1000000,'2003-04-21')

DROP PROCEDURE IF EXISTS DeleteEmployee;
GO

CREATE PROCEDURE DeleteEmployee
@NumberOfYearNoSalaryUpdate INT
AS 
BEGIN
	DELETE FROM EmployeeDetail
	WHERE SalaryUpdateDate < DATEADD(YEAR, -@NumberOfYearNoSalaryUpdate,GETDATE())
END;

EXEC DeleteEmployee 2;

-- 9,Create a procedure to insert a new department into a Department table, returning the newly created DepartmentID.

DROP PROCEDURE IF EXISTS AddNewDepartment;
GO

CREATE PROCEDURE AddNewDepartment
@departmentName NVARCHAR(50)
AS
BEGIN
	INSERT INTO Department(departmentName)
	values (@departmentName);

	DECLARE @NewDepartmentId INT = SCOPE_IDENTITY()

	PRINT 'Department added successfully and the department ID is '+ CAST(@NewDepartmentId AS VARCHAR)
END;

EXEC AddNewDepartment 'INTERN';

-- 10,Create a procedure to retrieve the department-wise average salary for all departments.

DROP PROCEDURE IF EXISTS DepartmentWiseAverageSalary;
GO

CREATE PROCEDURE DepartmentWiseAverageSalary
AS
BEGIN
	SELECT D.departmentName, ISNULL(AVG(E.salary),0) AS AverageSalary
	FROM Department D
	LEFT JOIN EmployeeDetail E ON E.departmentId = D.departmentId
	GROUP BY D.departmentName
END;

EXEC DepartmentWiseAverageSalary;

-- 11,Create a procedure that returns employees along with their manager's name (assume Employee table has ManagerID).

DROP PROCEDURE IF EXISTS FindManager;
GO

CREATE PROCEDURE FindManager
AS
BEGIN
	SELECT E.employeeName,ISNULL(M.employeeName,'No Manager') AS ManagerName
	FROM EmployeeDetail E
	LEFT JOIN EmployeeDetail M ON E.managerId = M.employeeId
END;

EXEC FindManager;

-- 12,Create a procedure to transfer an employee from one department to another and log the transfer details in a separate TransferLog table using a transaction.

EXEC DeleteTable 'TransferLog'
GO

CREATE TABLE TransferLog(
TransferlogId INT IDENTITY(10001,1) PRIMARY KEY,
employeeId INT CONSTRAINT FK_TransferLog_EmployeeDetail FOREIGN KEY REFERENCES EmployeeDetail(employeeId),
oldDepartmentId INT,
newDepartmentId INT,
departmentChangeDate DATE);
GO

DROP PROCEDURE IF EXISTS TransferLogUpdate;
GO

CREATE PROCEDURE TransferLogUpdate
@employeeId INT,
@NewDepartment INT
AS 
BEGIN
	DECLARE @OldDepartment INT
	SELECT @OldDepartment = departmentId 
	FROM EmployeeDetail
	WHERE employeeId = @employeeId

	UPDATE EmployeeDetail
	SET departmentId = @NewDepartment
	WHERE employeeId = @employeeId

	INSERT INTO TransferLog(employeeId,oldDepartmentId,newDepartmentId,departmentChangeDate)
	VALUES (@employeeId,@OldDepartment,@NewDepartment,GETDATE())
END;

EXEC TransferLogUpdate 3,108;

SELECT * FROM TransferLog;

-- 13,Create a procedure to get the top N highest-paid employees.

DROP PROCEDURE IF EXISTS TopPaidEmployee;
GO

CREATE PROCEDURE TopPaidEmployee
@TopEmployee INT
AS 
BEGIN
	SELECT TOP (@TopEmployee) WITH TIES *
	FROM EmployeeDetail
	ORDER BY salary DESC
END;

EXEC TopPaidEmployee 2;

-- 14,Create a procedure that returns the employee details along with a calculated bonus (e.g., 10% of salary) as an extra column.

DROP PROCEDURE IF EXISTS BonusCalculate;
GO

CREATE PROCEDURE BonusCalculate
AS 
BEGIN
	SELECT employeeId, employeeName, salary, (salary * 0.10) AS Bonus
	FROM EmployeeDetail
END;

EXEC BonusCalculate;

-- 15,Create a procedure that accepts a comma-separated list of EmployeeIDs and deletes all those employees in a single operation.

DROP PROCEDURE IF EXISTS DeleteCommaSeparatedEmployeeId;
GO

CREATE PROCEDURE DeleteCommaSeparatedEmployeeId
@DeleteEmployeeId VARCHAR(MAX)
AS 
BEGIN
	DELETE FROM EmployeeDetail
	WHERE employeeId IN (SELECT VALUE FROM STRING_SPLIT(@DeleteEmployeeId,','))
END;

EXEC DeleteCommaSeparatedEmployeeId '2,3';

SELECT * FROM Department;
SELECT * FROM EmployeeDetail;
SELECT * FROM SalaryLog;
SELECT * FROM TransferLog;