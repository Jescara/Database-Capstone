SELECT customers.CustomerID, customers.CustomerName, orders.OrderID, orders.TotalCost, menu.MenuName, menuitems.CourseName, menuitems.StarterName 
FROM customers 
INNER JOIN orders ON customers.CustomerID = orders.CustomerID 
INNER JOIN menu ON orders.MenuID = menu.MenuID
INNER JOIN menuitems ON menu.MenuItemsID = menuitems.MenuItemsID
WHERE orders.TotalCost > 150 
ORDER BY orders.TotalCost ASC;

SELECT menu.MenuName FROM menu WHERE MenuID = ANY(SELECT MenuID FROM orders WHERE Quantity >2);

DELIMITER //
CREATE PROCEDURE GetMaxQuantity()
BEGIN
SELECT MAX(Quantity) AS "Max Quantity in Order" FROM orders;
END//
DELIMITER ;

CALL GetMaxQuantity();

PREPARE GetOrderDetail FROM 'SELECT OrderID, Quantity, TotalCost FROM orders WHERE OrderID = ? ';

SET @id = 2;
EXECUTE GetOrderDetail USING @id;

DELIMITER //
CREATE PROCEDURE CancelOrder(order_id INT)
BEGIN
DELETE FROM orders WHERE OrderID = order_id;
SELECT CONCAT("Order", order_id, " has been cancelled.") AS Confirmation;
END//

DELIMITER ;

CALL CancelOrder(2)