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
