CREATE DATABASE ProductSystem;
GO

DROP TABLE IF EXISTS Customer;
GO

-- Question 2 : Normalized tables

CREATE TABLE Customer (
    customerId INT PRIMARY KEY IDENTITY(1,1),
    name VARCHAR(100) NOT NULL
);
GO

CREATE TABLE CustomerAddress (
    addressId INT PRIMARY KEY IDENTITY(1,1),
    city VARCHAR(100) NOT NULL,
    postalCode VARCHAR(10) NOT NULL
);
GO

CREATE TABLE CustomerAddressMapping (
    customerId INT CONSTRAINT FK_CustomerAddressMapping_Customer FOREIGN KEY REFERENCES Customer(customerId),
    addressId INT CONSTRAINT FK_CustomerAddressMapping_CustomerAddress FOREIGN KEY REFERENCES CustomerAddress(addressId),
    PRIMARY KEY (CustomerId, AddressId)
);
GO

CREATE TABLE Products (
    productId INT PRIMARY KEY IDENTITY(101,1),
    productName NVARCHAR(100) NOT NULL,
	price DECIMAL(10,2),
    CONSTRAINT UQ_Products UNIQUE (productId, productName)
);
GO

CREATE TABLE Orders (
    orderId INT PRIMARY KEY IDENTITY(1001,1),
    customerId INT CONSTRAINT FK_Orders_Customer FOREIGN KEY REFERENCES Customer(customerId),
    orderDate DATE,
    totalAmount DECIMAL(10, 2)
);
GO

CREATE TABLE OrderDetails (
    orderId INT CONSTRAINT FK_OrderDetails_Orders FOREIGN KEY REFERENCES Orders(orderId),
    productId INT CONSTRAINT FK_OrderDetails_Products FOREIGN KEY REFERENCES Products(productId),
    quantity INT NOT NULL
);
GO

INSERT INTO Customer (name) VALUES ('SRIRAM'),('KUMAR'),('RAJAN');
INSERT INTO Products(productName,price) VALUES ('JAM',100),('CAKE',200);
INSERT INTO Orders (customerId,orderDate) VALUES (1,'2025-01-03'),(1,'2025-02-03'),(1,'2025-03-03'),(1,'2025-04-03'),(1,'2025-05-03'),(1,'2025-06-03'),(2,'2025-01-03');
INSERT INTO OrderDetails (orderId,productId,quantity) VALUES (1001,102,1),(1002,102,1),(1003,102,1),(1004,102,1),(1005,102,1),(1006,102,1),(1007,101,7);

-- Question 3 :

SELECT customerId
FROM Orders
WHERE orderDate >= DATEFROMPARTS(YEAR(GETDATE()),MONTH(DATEADD(MONTH,-5,GETDATE())),1)
GROUP BY customerId
HAVING COUNT(DISTINCT DATEFROMPARTS(YEAR(orderDate),MONTH(orderDate),1)) = 6;

-- Question 4 :

WITH ReportDetail AS (
	SELECT m.EmployeeId,e.Name,e.ManagerId
	FROM Employee e
	JOIN Employee m ON m.EmployeeId = e.ManagerID)
SELECT * FROM ReportDetail;

-- Question 6 :

SELECT s.productId,s.salesDate,s.amount,
(SELECT AVG(s1.amount) FROM Sales s1
WHERE s1.productId = s.productId AND s1.salesDate <= s.salesDate AND s1.salesDate >= DATEADD(DAY,-6,s.salesDate) AS SevenDayAverage)
FROM Sales s
ORDER BY s.productId,s.salesDate;

-- Question 7 : Stored Procedure

CREATE PROCEDURE TotalCaluculate
	@OrderID INT
AS
BEGIN
	IF NOT EXISTS (SELECT 1 FROM Orders WHERE orderId = @OrderID)
	BEGIN
		RAISERROR('Invalid OrderID ',16, 1)
		RETURN
	END

	DECLARE @totalOrderPrice INT

	SELECT @totalOrderPrice = SUM(p.price * od.quantity)
	FROM OrderDetails od
	JOIN Products p on p.productId = od.productId
	WHERE orderId = @OrderID

	UPDATE Orders
	SET totalAmount = @totalOrderPrice
	WHERE orderId = @OrderID

	PRINT 'Total amount is : ' + CAST(@totalOrderPrice AS VARCHAR(20))
END;

EXEC TotalCaluculate 1007;

-- Question 8 : 

DROP FUNCTION dbo.NoOrderInNmonth

CREATE FUNCTION dbo.NoOrderInNmonth (@Month INT)
RETURNS TABLE
AS
RETURN (
SELECT c.customerId, c.name
FROM Customer c
WHERE NOT EXISTS (SELECT 1 FROM Orders o WHERE o.customerId = c.customerId AND o.orderDate >= DATEADD(MONTH, -@Month, GETDATE())
)
);

SELECT * FROM dbo.NoOrderInNmonth(2);

-- Question 9 :

CREATE VIEW dbo.LastOrders
AS
WITH OrderCount AS (
    SELECT customerId, MAX(orderDate) AS LastOrderDate
    FROM Orders
    GROUP BY customerId
    HAVING COUNT(*) > 5
)
SELECT o.customerId,o.orderId,o.orderDate,o.totalAmount
FROM OrderCount v
JOIN Orders o ON o.customerId = v.customerId AND o.orderDate = v.LastOrderDate;

SELECT * FROM dbo.LastOrders;

-- Question 10 :

DROP FUNCTION dbo.SquareFunction

CREATE FUNCTION dbo.SquareFunction (@squareNumber INT)
RETURNS DECIMAL(10,2)
WITH SCHEMABINDING
AS
BEGIN
    RETURN POWER(@squareNumber,2)
END;

SELECT dbo.SquareFunction(4);


-- Question 11 :

CREATE TRIGGER trg_UpdatePriceTrigger
ON Products
AFTER UPDATE
AS
BEGIN
    DECLARE @oldPrice DECIMAL(10,2);
    DECLARE @newPrice DECIMAL(10,2);
    DECLARE @productId INT;
    DECLARE @priceDropPercent DECIMAL(10,2);

    SELECT @productId = i.productId,@oldPrice = d.Price,@newPrice = i.Price
    FROM inserted i
    JOIN deleted d ON i.productId = d.productId;

	SET @priceDropPercent = ((@oldPrice - @newPrice) * 100.0) / @oldPrice;

    IF @oldPrice > @newPrice AND @priceDropPercent > 20
    BEGIN
		RAISERROR('Not be Update because new price is less than 20% of old price',16, 1)
        ROLLBACK TRANSACTION;
    END
END;