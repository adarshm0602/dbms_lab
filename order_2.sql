-- 1. List the Order# and Ship_date for all orders shipped from Warehouse# "W2".
SELECT order# , ship-date 
FROM Shipment 
WHERE warehouse# = 'W2';

-- 2. List the Warehouse information from which the Customer named "Kumar" was supplied his orders.
SELECT DISTINCT o.order#, s.warehouse# 
FROM Order o 
JOIN Shipment s ON o.order# = s.order#
JOIN Customer c ON o.cust# = c.cust#
WHERE c.cname = 'Kumar';

-- 3. Produce a listing: Cname, #ofOrders, Avg_Order_Amt.
SELECT c.cname, COUNT(o.order#) AS num_orders, AVG(o.order-amt) AS avg_order_amt
FROM Customer c
JOIN Order o ON c.cust# = o.cust#
GROUP BY c.cname;

-- 4. Delete all orders for customer named "Kumar".
DELETE FROM Order 
WHERE cust# IN (SELECT cust# FROM Customer WHERE cname = 'Kumar');

-- 5. Find the item with the maximum unit price.
SELECT * FROM Item
WHERE unitprice = (SELECT MAX(unitprice) FROM Item);

-- 6. Create a trigger that updates order_amt based on quantity and unit price of order_item.
CREATE TRIGGER update_order_amt
AFTER INSERT OR UPDATE ON Order-item
FOR EACH ROW
BEGIN
    UPDATE Order
    SET order-amt = (
        SELECT SUM(oi.qty * i.unitprice)
        FROM Order-item oi
        JOIN Item i ON oi.item# = i.item#
        WHERE oi.order# = NEW.order#
    )
    WHERE order# = NEW.order#;
END;

-- 7. Create a view to display orderID and shipment date of all orders shipped from warehouse 5.
CREATE VIEW Warehouse5_Shipments AS
SELECT order#, ship-date
FROM Shipment
WHERE warehouse# = 5;
