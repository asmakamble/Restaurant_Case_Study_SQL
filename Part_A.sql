drop database if exists mrx_restaurants;
create database if not exists mrx_restaurants;
use mrx_restaurants;

select 'creating database structure' as 'info';

drop table if exists sales,
					 menu,
					 members;
    
create table menu (
	product_id 		int 		not null,
    product_name 	varchar(5) 	not null,
    price 			int 		not null,
    primary key(product_id)
    );
    
create table members (
	customer_id 	varchar(1) 		not null,
    join_date 		timestamp    	not null,
    primary key (customer_id)
    );
    
create table sales (
	customer_id 	varchar(1)  	not null,
    order_date  	date 			not null,
    product_id  	int  			not null,
    foreign key(customer_id) references members (customer_id) ON DELETE CASCADE,
    foreign key(product_id) references menu (product_id) ON DELETE CASCADE
    );

insert into menu values (1, 'sushi', 10),
(2, 'curry', 15),
(3, 'ramen', 12);

insert into members values ( 'A', '2021-01-07'),
( 'B', '2021-01-9'),
( 'C', '2021-01-11');

insert into sales values ('A', '2021-01-01', 1),
('A', '2021-01-01', 1),
('A', '2021-01-01', 2),
('A', '2021-01-07', 2),
('A', '2021-01-10', 3),
('A', '2021-01-11', 3),
('A', '2021-01-11', 3),
('B', '2021-01-01', 2),
('B', '2021-01-02', 2),
('B', '2021-01-04', 1),
('B', '2021-01-11', 1),
('B', '2021-01-16', 3),
('B', '2021-02-01', 3),
('C', '2021-01-01', 3),
('C', '2021-01-01', 3),
('C', '2021-01-07', 3);

#Review the created tables
select * from mrx_restaurants.menu;
select * from mrx_restaurants.members;
select * from mrx_restaurants.sales;

#Merge teh data for finding analysis
SELECT 
    sales.customer_id, sales.order_date, sales.product_id, members.join_date,menu.product_name, menu.price
FROM
    mrx_restaurants.sales
join mrx_restaurants.members on sales.customer_id = members.customer_id
join mrx_restaurants.menu on sales.product_id = menu.product_id
order by sales.customer_id;

#Find the data of menbered and not membered









    