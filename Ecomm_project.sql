use new;
# Ques 1: Identify the 3rd most expensive order placed by each customer if any.
-- Print CustomerID, OrderID, FirstName, LastName, PaymentID, OrderDate, Total_Order_Amount in the result.
-- Sort the result set in ascending order of CustomerID.

with cte as 
(select a.customerid,orderid,firstname,lastname,paymentid,orderdate,total_order_amount, 
dense_rank() over (partition by customerid order by total_order_amount desc) as NEW 
from customers a join orders o on a.customerid=o.customerid order by a.customerid) 
select customerid,orderid,firstname,lastname,paymentid,orderdate,total_order_amount 
from cte where NEW=3 order by customerid;

# Ques 2: Get Last Order Day of every month for every year.
-- If there are many orders placed on Last Day give every orders that was placed.
-- Print Order Id, Customer Id, and Orderdate.
-- Sort the output in ascending order of Order Id.

with cte as 
( select orderid, customerid, orderdate, dense_rank() over(partition by year(orderdate),
 month(orderdate) order by orderdate desc) as rank_ from orders) select orderid, customerid, 
 orderdate from cte where rank_ = 1 order by orderid;
 
 # Ques 3: Identify the Shipper who shipped the 3rd most number of orders in each month of the year 2021.
-- Consider ShipDate for all your calculations.
-- Sort the result in calendar order of months, for records with the same month, sort them in ascending order of ShipperID.

with cte2 as (with cte1 as (with cte as 
( select monthname(shipdate) m,shipperid,count(orderid) 
over (partition by monthname(shipdate),shipperid) C 
from orders where year(shipdate)=2021 order by month(shipdate),shipperid) 
select distinct * from cte) select *, dense_rank() over (partition by m order by c desc) as RNK from cte1) 
select m,shipperid,c from cte2 where RNK=3 
order by FIELD(m,'January','February','March','April','May','June','July','August','September','October', 
'November','December'),shipperid;

# Ques4: Write a query to find the top 5 customers for each month with highest total order amount.
-- Print order id,customer id, month number, order amount and rank.
-- Avoid skipping ranks.
-- Sort the result in ascending order of month number. For records with same month number, sort them in ascending order of rank.

with cte as 
(select orderid,customerid,month(orderdate),total_order_amount,dense_rank() over 
(partition by month(orderdate) order by total_order_amount desc) as RNK from orders) 
select * from cte where RNK in (1,2,3,4,5);

#Ques5: Write a query to find the top 2 Sale prices for each type.
-- Print all the columns of products table and the rank.
-- Avoid skipping ranks.
-- Sort the result set in alphabetical order of Type. For records with the same type sort them in ascending order of rank.

with cte as 
(select productid,product,category_id,sub_category,brand,sale_price,market_price,
type,dense_rank() over (partition by type order by sale_price desc) rnk from products) 
select * from cte where rnk in (1,2) order by type,rnk;

# Ques6: Write a query to identify the customer from each country who placed that particular country's second most expensive order.
-- Print orderid, customerid, first name, last name, total order amount, country and rank.
-- Avoid skipping ranks.
-- Sort the result in ascending order of OrderID.

with cte as 
(select orderid,customers.customerid,firstname,lastname,total_order_amount,country,
 dense_rank() over (partition by country order by total_order_amount desc) as rnk from customers 
 join orders on customers.customerid=orders.customerid) select * from cte where rnk=2 order by orderid;
 
 # Ques:7 Print the Productid, Quantity and Orderdate for daily top - 3 selling products between January 2020 to March 2020.
-- Essentially you are trying to identify the top 3 products sold for each date between the given date range.
-- Sort the result in ascending order of OrderDate, for records with same orderdate, sort them in ascending order of Quantity.

with cte as 
(select o.productid,quantity,orderdate,dense_rank() over 
( partition by orderdate order by quantity desc) rnk from orderdetails o 
join orders d on d.orderid=o.orderid where year(orderdate)=2020 and month(orderdate) between 1 and 3) 
select ProductID,Quantity,OrderDate from cte where rnk <=3 order by orderdate,quantity;

# Ques 8: Print Customer ID, Orderdate, Shipdate, PaymentID, Total Order Amount, and Cumulative total order amount by each customer. \
-- If the customer orders more than two orders in same date consider their highest amount as their first order of that day.
-- Sort the value in ascending order of CustomerID. For records with the same CustomerID order them by Orderdate.

select customerid,orderdate,shipdate,paymentid,total_order_amount, 
sum(total_order_amount) over (partition by customerid order by orderdate,total_order_amount 
desc rows between unbounded preceding and current row) amt from orders order by customerid,orderdate;

# Ques9: Manager wants to know the top 2 highest Total order amount for each Customers.
-- Print Order ID, Customer ID and Total order amount.
-- Sort the output in increasing order of Customer ID , for same Customer ID sort in descending order of Total order amount.

with cte as 
(select orderid,customerid,total_order_amount,dense_rank() over 
(partition by customerid order by total_order_amount desc) rnk from orders) 
select orderid,customerid,total_order_amount from cte where rnk<=2 order by customerid;

# Ques 10: Manager wants to know the top 3 highest Market Price for each Category.
-- Skipping allowed in the ranking.
-- Print Product ID, Category ID and Market_price.
-- Sort the table in ascending order of Product ID, Category ID, Market_price.

with cte as 
(select productid, category_id, market_price, rank() over
 (partition by category_id order by market_price desc) qw from products) 
 select productid,category_id,market_price from cte where qw<=3 order by productid,category_id,market_Price;

# Ques11: We want to know about the third transaction done by each customer for the year 2021.
-- Print the Customerid, Firstname, Lastname, Orderid, Total_order_amount. For people with Lastname null give 'Doe' as lastname
-- Sort the Output in ascending order of Customerid.

with cte as 
(select customers.customerid, firstname, lastname as lname, orderid, total_order_amount,orderdate ,
 row_number() over (partition by customers.customerid order by orderdate) RNK from orders join 
 customers on orders.customerid=customers.customerid where year(orderdate)=2021 order by customers.customerid) 
 select customerid,firstname, case when lname is NULL then "Doe" else lname end as lo,orderid,total_order_amount 
 from cte where RNK=3 order by customerid;



