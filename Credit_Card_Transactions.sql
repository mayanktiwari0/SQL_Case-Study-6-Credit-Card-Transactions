drop table if exists Card_base;
create table if not exists Card_base
(
	Card_Number		varchar(50),
	Card_Family		varchar(30),
	Credit_Limit	int,
	Cust_ID			varchar(20)
);


drop table if exists Customer_base;
create table if not exists Customer_base
(
	Cust_ID						varchar(20),
	Age 						int,
	Customer_Segment			varchar(30),
	Customer_Vintage_Group		varchar(20)
);


drop table if exists Fraud_base;
create table if not exists Fraud_base
(
	Transaction_ID		varchar(20),
	Fraud_Flag			int
);


drop table if exists Transaction_base;
create table if not exists Transaction_base
(
	Transaction_ID			varchar(20),
	Transaction_Date		date,
	Credit_Card_ID			varchar(50),
	Transaction_Value		decimal,
	Transaction_Segment		varchar(20)
);

select * from Card_base; -- 500 
select * from Customer_base; -- 5674
select * from Fraud_base; -- 109
select * from Transaction_base; -- 10000

1. How many customers have done transactions over 49000?

select count(distinct cust_id) as no_of_customers from Transaction_base trn
join Card_base crd on trn.credit_card_id = crd.card_number
where trn.transaction_value > 49000;

2. What kind of customers can get a Premium credit card?

select  distinct customer_segment from Card_base crd
join Customer_base cst on cst.cust_id = crd.cust_id
where card_family = 'Premium';

3.Identify the range of credit limit of customer who have done fraudulent transactions.

select min(credit_limit), max(credit_limit) from card_base cb
join transaction_base tb on cb.card_number = tb.credit_card_id
join fraud_base fb on fb.transaction_id = tb.transaction_id;

4. What is the average age of customers who are involved in fraud transactions based on different card type?

select cb.card_family, round(avg(age),2) as average_age from customer_base cbt
join card_base cb ON cbt.cust_id = cb.cust_id
join transaction_base tb ON tb.credit_card_id = cb.card_number 
join fraud_base fb on fb.transaction_id = tb.transaction_id
group by cb.card_family;

5. Identify the month when highest no of fraudulent transactions occured.

select extract(month from transaction_date) as month, count(transaction_value) as no_of_transactions
from transaction_base tb join fraud_base fb on fb.transaction_id = tb.transaction_id 
group by extract(month from transaction_date)
order by no_of_transactions desc
limit 1;

6. Identify the customer who has done the most transaction value without
   involving in any fraudulent transactions.

select cb.cust_id, sum(transaction_value) as most_transaction_value from card_base cb
join transaction_base tb ON cb.card_number = tb.credit_card_id
where tb.transaction_id NOT IN(select cb.cust_id
									from Transaction_base tb
									join Fraud_base fb on fb.transaction_id=tb.transaction_id
									join Card_base cb on tb.credit_card_id = cb.card_number)
group by cb.cust_id
order by most_transaction_value desc
limit 1;

7. Check and return any customers who have not done a single transaction.

select distinct cust_id from customer_base cb
where cb.cust_id not in (select distinct crd.cust_id
							  from Transaction_base trn
							  join Card_base crd 
							  	on trn.credit_card_id = crd.card_number);


8) What is the highest and lowest credit limit given to each card type?

select card_family, max(credit_limit) max_limit, 
min(credit_limit) min_limit from Card_base
group by card_family;

9. What is the total value of transactions done by customers who come under the
   age bracket of 20-30 yrs, 30-40 yrs, 40-50 yrs, 50+ yrs and 0-20 yrs.

select sum(case when age > 0 and age <= 20 then transaction_value else 0 end) as trns_value_0_to_20
	, sum(case when age > 20 and age <= 30 then transaction_value else 0 end) as trns_value_20_to_30
	, sum(case when age > 30 and age <= 40 then transaction_value else 0 end) as trns_value_30_to_40
	, sum(case when age > 40 and age <= 50 then transaction_value else 0 end) as trns_value_40_to_50
	, sum(case when age > 50 then transaction_value else 0 end) as trns_value_greater_than_50
	from Transaction_base trn
	join Card_base crd on trn.credit_card_id = crd.card_number
	join customer_base cst on cst.cust_id=crd.cust_id;



































