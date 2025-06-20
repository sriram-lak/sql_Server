CREATE DATABASE EmployeeSystem;
DROP TABLE Employee
CREATE TABLE Employee(
	EmployeeId INT IDENTITY(1,1) PRIMARY KEY,
	name NVARCHAR(100) NOT NULL,
	salary DECIMAL(10,2) NOT NULL,
	manageId INT
);
GO

-- Question 5 :

SELECT MAX(salary) AS SecondLargestSalary
FROM Employee
WHERE salary < (SELECT MAX(salary) FROM Employee)

-- Question 12 :

CREATE TABLE EmployeeArchive(
	employeeName NVARCHAR(100),
	actionType NVARCHAR(100) NOT NULL,
	logTime DATE
);
GO

DROP TRIGGER try_AfterDelete
CREATE TRIGGER try_AfterDelete
ON Employee
AFTER DELETE
AS
BEGIN
	INSERT INTO EmployeeArchive(employeeName,actionType,logTime)
	SELECT name,'Delete Row',GETDATE()
	FROM deleted
END;
GO

INSERT INTO Employee(name,salary,manageId)VALUES ('SRI',90000,NULL),('RAM',80000,1),('KUMAR',50000,2

DELETE FROM Employee WHERE EmployeeId = 1;

-- Question 14 : 

BEGIN TRY
	BEGIN TRANSACTION
		INSERT INTO Employee(name,salary,manageId) VALUES (10,100,1)
END TRY
BEGIN CATCH
	ROLLBACK TRANSACTION
	INSERT INTO EmployeeArchive(employeeName,actionType,logTime) VALUES ('Error',ERROR_MESSAGE(),GETDATE())
END CATCH

-- Question 13 :

CREATE TYPE PhoneNumber FROM NVARCHAR(20) NOT NULL;
GO

CREATE RULE PhoneNumberRule 
AS 
	@phone LIKE '+%' AND LEN(@phone) >= 10;
GO

EXEC sp_bindrule 'PhoneNumberRule', 'PhoneNumber';
GO