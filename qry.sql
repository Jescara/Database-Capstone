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
CREATE PROCEDURE CancelOrder(IN order_id INT)
BEGIN
DELETE FROM orders WHERE OrderID = order_id;
SELECT CONCAT("Order", order_id, " has been cancelled.") AS Confirmation;
END //

DELIMITER ;

CALL CancelOrder(5);

-- procedure is not executing for some reason

-- insert statements
INSERT INTO bookings (`BookingID`, `Date`, `TableNumber`, `CustomerID`, `StaffID`) VALUES ('1', '2022-11-12', '5', '1', '4');
INSERT INTO bookings (`BookingID`, `Date`, `TableNumber`, `CustomerID`, `StaffID`) VALUES ('2', '2022-11-12', '3', '3', '3');
INSERT INTO bookings (`BookingID`, `Date`, `TableNumber`, `CustomerID`, `StaffID`) VALUES ('3', '2022-10-11', '2', '2', '4');
INSERT INTO bookings (`BookingID`, `Date`, `TableNumber`, `CustomerID`, `StaffID`) VALUES ('4', '2022-10-13', '2', '1', '5');

DELIMITER //

CREATE PROCEDURE CheckBooking(IN bookingDate DATE, IN tableNum INT)
BEGIN
DECLARE bookingStatus VARCHAR(255);
SELECT 
CASE
WHEN COUNT(*) > 0 THEN CONCAT("Table ", tableNum, " is already booked")
ELSE  CONCAT("Table ", tableNum, " is available") 
END
INTO bookingStatus FROM bookings WHERE Date = bookingDate AND TableNumber = tableNum;

SELECT bookingStatus AS "Booking Status";
END//

DELIMITER ;

CALL CheckBooking("2022-11-12", 4);

DELIMITER //
CREATE PROCEDURE AddValidBooking(IN bookingDate DATE, IN tableNum INT, IN customer_id INT, IN staff_id INT)
BEGIN
DECLARE booking_count INT;
START TRANSACTION;
SELECT COUNT(*) INTO booking_count FROM bookings WHERE Date = bookingDate AND TableNumber = tableNum;

IF booking_count = 0 THEN
	INSERT INTO bookings (Date, TableNumber, CustomerID, StaffID) VALUES (bookingDate, tableNum, customer_id, staff_id);
	COMMIT;
	SELECT CONCAT("Table ", tableNum, " is now booked. Booking successful.") AS "Booking Status";
ELSE 
	ROLLBACK;
	SELECT CONCAT("Table ", tableNum, " is already booked. Booking cancelled.") AS "Booking Status";
END IF;
END//
DELIMITER ;

CALL AddValidBooking("2022-12-17", 7, 2, 4);
CALL AddValidBooking("2022-12-17", 7, 3, 5);

DELIMITER //

CREATE PROCEDURE AddBookings(IN booking_id INT, IN customer_id INT, IN booking_date DATE, IN table_number INT, IN staff_id INT)
BEGIN
INSERT INTO bookings (BookingID, Date, TableNumber, CustomerID, StaffID) VALUES(booking_id, booking_date, table_number, customer_id, staff_id);
SELECT "New booking added."AS "Confirmation";

END //

DELIMITER ; 

CALL AddBookings(11, 5, "2022-11-02", 3, 5);

DELIMITER //

CREATE PROCEDURE UpdateBooking(IN booking_id INT, IN booking_date DATE)
BEGIN
UPDATE bookings 
SET Date = booking_date
WHERE BookingID = booking_id;
SELECT CONCAT("Booking ", booking_id, " updated.") AS "Confirmation";
END //

DELIMITER ; 

CALL UpdateBooking(9, "2022-11-02");

DELIMITER //

CREATE PROCEDURE CancelBooking(IN booking_id INT)
BEGIN
DELETE FROM bookings 
WHERE BookingID = booking_id;
SELECT CONCAT("Booking ", booking_id, " cancelled") AS "Confirmation";
END //

DELIMITER ; 

CALL CancelBooking(9)