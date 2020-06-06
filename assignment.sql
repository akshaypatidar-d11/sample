#Part 1. Modify payments table
# I have allowed order number to be null because otherwise we would have to insert lots of dummy data. Ideally it should not be null.
ALTER TABLE payments ADD orderNumber int;
ALTER TABLE payments add FOREIGN KEY (orderNumber) REFERENCES orders(orderNumber);


#Part 3. Transaction creating a customer, places order and makes payment.
START Transaction;

# create customer
SELECT @customerNumber:=MAX(customerNumber)+1 FROM customers;
INSERT INTO customers(customerNumber, customerName, contactLastName, contactFirstName, phone, addressLine1, city, country) VALUES(@customerNumber, 'Akshay', 'Patidar', 'Akshay', 9999999999, '221B Baker Street', 'London', 'England');
# order
SELECT @orderNumber:=MAX(orderNumber)+1 FROM orders;
INSERT INTO orders(orderNumber, orderDate, requiredDate, status, customerNumber) VALUES(@orderNumber, '2020-6-6', '2020-6-15', 'In Process', @customerNumber);
INSERT INTO orderdetails(orderNumber, productCode, quantityOrdered, priceEach, orderLineNumber) VALUES(@orderNumber, 'S10_1678', 1, 48.81, 1);
# payment
INSERT INTO payments(customerNumber, checkNumber, paymentDate, amount, orderNumber) VALUES(@customerNumber, 'HQ336386', '2020-6-6', 48.81, @orderNumber);

COMMIT;

#Part 4 

select temp.*, products.productName, productlines.image FROM (select customers.customerName, orders.orderNumber, orders.shippedDate, payments.amount, 
																	payments.paymentDate, orderdetails.quantityOrdered, orderdetails.productCode
																FROM customers,orders,orderdetails,payments 
																WHERE customers.customerNumber = 497 AND orders.orderNumber = 10426 AND orderdetails.orderNumber = orders.orderNumber AND payments.orderNumber = orders.orderNumber) as temp,
	products, productlines where products.productCode = temp.productCode AND productlines.productLine = products.productLine;

# Part 5 Triggers

# create table 
CREATE TABLE orderCount (
  customerNumber int NOT NULL,
  orderCount bigint NOT NULL DEFAULT '0',
  PRIMARY KEY (customerNumber),
  CONSTRAINT orderCount_ibfk_1 FOREIGN KEY (customerNumber) REFERENCES customers (customerNumber)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;


#prefill data
INSERT INTO orderCount (SELECT customerNumber, count(*) AS orderCount FROM orders GROUP BY customerNumber);

# Now command to add trigger
CREATE TRIGGER update_order_count AFTER INSERT ON orders 
FOR EACH ROW
UPDATE orderCount SET orderCount = orderCount + 1 WHERE customerNumber = NEW.customerNumber;


/*
# Outputs

Invoice query (part 4)

+--------------+-------------+-------------+--------+-------------+-----------------+-------------+---------------------------------------+--------------+
| customerName | orderNumber | shippedDate | amount | paymentDate | quantityOrdered | productCode | productName                           | image        |
+--------------+-------------+-------------+--------+-------------+-----------------+-------------+---------------------------------------+--------------+
| Akshay       |       10426 | NULL        |  48.81 | 2020-06-06  |               1 | S10_1678    | 1969 Harley Davidson Ultimate Chopper | 0x           |
+--------------+-------------+-------------+--------+-------------+-----------------+-------------+---------------------------------------+--------------+

Explain invoice query

+----+-------------+--------------+------------+--------+---------------------+-------------+---------+----------------------------------------+------+----------+-------+
| id | select_type | table        | partitions | type   | possible_keys       | key         | key_len | ref                                    | rows | filtered | Extra |
+----+-------------+--------------+------------+--------+---------------------+-------------+---------+----------------------------------------+------+----------+-------+
|  1 | SIMPLE      | customers    | NULL       | const  | PRIMARY             | PRIMARY     | 4       | const                                  |    1 |   100.00 | NULL  |
|  1 | SIMPLE      | orders       | NULL       | const  | PRIMARY             | PRIMARY     | 4       | const                                  |    1 |   100.00 | NULL  |
|  1 | SIMPLE      | orderdetails | NULL       | ref    | PRIMARY,productCode | PRIMARY     | 4       | const                                  |    1 |   100.00 | NULL  |
|  1 | SIMPLE      | products     | NULL       | eq_ref | PRIMARY,productLine | PRIMARY     | 17      | classicmodels.orderdetails.productCode |    1 |   100.00 | NULL  |
|  1 | SIMPLE      | productlines | NULL       | eq_ref | PRIMARY             | PRIMARY     | 52      | classicmodels.products.productLine     |    1 |   100.00 | NULL  |
|  1 | SIMPLE      | payments     | NULL       | ref    | orderNumber         | orderNumber | 5       | const                                  |    1 |   100.00 | NULL  |
+----+-------------+--------------+------------+--------+---------------------+-------------+---------+----------------------------------------+------+----------+-------+

SHOW TRIGGERS

+--------------------+--------+--------+---------------------------------------------------------------------------------------------+--------+------------------------+----------+----------------+----------------------+----------------------+--------------------+
| Trigger            | Event  | Table  | Statement                                                                                   | Timing | Created                | sql_mode | Definer        | character_set_client | collation_connection | Database Collation |
+--------------------+--------+--------+---------------------------------------------------------------------------------------------+--------+------------------------+----------+----------------+----------------------+----------------------+--------------------+
| update_order_count | INSERT | orders | UPDATE orderCount SET orderCount = orderCount + 1 WHERE customerNumber = NEW.customerNumber | AFTER  | 2020-06-06 18:10:25.11 |          | root@localhost | utf8                 | utf8_general_ci      | latin1_swedish_ci  |
+--------------------+--------+--------+---------------------------------------------------------------------------------------------+--------+------------------------+----------+----------------+----------------------+----------------------+--------------------+


*/
