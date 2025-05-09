
--View to get order summary details:
CREATE VIEW vw_order_summary
AS
Select o.OrderID, o.OrderDate, o.TotalAmount, u.FullName as 'Customer Name',
		v.VendorName as 'Vendor Name', s.statusName
from orders o join users u on o.userid = u.userID
join vendors v on o.vendorID = v.vendorID
join DeliveryStatus ds on o.OrderID = ds.OrderID
join Status s on s.statusID = ds.StatusID

select * from vw_order_summary

---View to summarize product sales
CREATE VIEW vw_product_sales
AS
Select pr.Name 'Product Name', SUM(oi.Quantity) AS 'Total Product Sold'
from Products pr join OrderItems oi
on pr.ProductID = oi.ProductID
group by pr.Name


select * from vw_product_sales
order by [Total Product Sold] desc

---Creating indexes to speed up queries:
CREATE NONCLUSTERED INDEX indx_productname on products(Name)

select * from Products where name like '%2%'

CREATE NONCLUSTERED INDEX indx_orderitems_order_product
ON OrderItems(OrderID, ProductID)


-- Trigger to automate the inventory stock automatically when product is ordered.
-- When orderitem in inserted then inventory quantity should be updated.

CREATE TRIGGER trg_update_inventory
ON OrderItems
AFTER INSERT
AS
BEGIN
		UPDATE i set i.quantityAvailable = i.QuantityAvailable - ins.Quantity
		from inventory i inner join inserted ins on
		i.productID = ins.ProductID
END

-- Stored procedure- Place new order
CREATE TYPE dbo.OrderItemType AS TAble (
	ProductID INT,
	Quantity INT,
	Price DECIMAL(10,2)
);

CREATE TYPE dbo.OrderItemType AS TAble (
	ProductID INT,
	Quantity INT,
	Price DECIMAL(10,2))

---Procedure to placce new order
CREATE PROCEDURE sp_PlaceOrder
@UserID INT, @VendorID INT, @TotalAmount Decimal(10,2), 
@OrderItemsList AS dbo.OrderItemType READONLY -- Pass multiple items (ProductID, Quantity, Price)
AS
BEGIN
	SET NOCOUNT ON;
	DECLARE @NewOrderID INT;

	-- 1. Insert into orders Table
	INSERT INTO Orders(UserID, VendorID, OrderDate, TotalAmount)
	VALUES (@UserID, @VendorID, GETDATE(), @TotalAmount);

	-- 2. Get the newly created OrderID
	SET @NewOrderID = SCOPE_IDENTITY();

	-- 3. insert into orderitems table
	INSERT INTO OrderItems(OrderID, ProductID, Quantity, Price)
	SELECT @NewOrderID, ProductID, Quantity, Price FROM @OrderItemsList;
END;

SELECT * FROM INVENTORY WHERE ProductID = 1;

DECLARE @Items dbo.OrderItemType;

INSERT INTO @Items (ProductID, Quantity, Price) VALUES (1,4, 70.00);

EXEC sp_PlaceOrder 1, 2, 280, @Items;

SELECT * FROM Orders;