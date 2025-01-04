#1. What is the total amount each customer spent at the restaurant?

SELECT 
    sales.customer_id as customers,
    sum(menu.price) as total_amount_spent
FROM
	mrx_restaurants.sales
join 
	mrx_restaurants.menu on sales.product_id = menu.product_id
group by sales.customer_id;
##############################################################################################

#2. How many days has each customer visited the restaurant?
SELECT 
    sales.customer_id as each_customer, 
    count(sales.order_date) as number_of_days_visited
FROM
    mrx_restaurants.sales
 group by sales.customer_id;
 
 ##############################################################################################
 
 #3. What was the first item from the menu purchased by each customer?
 
SELECT DISTINCT
    (sales.customer_id) AS customer,
    menu.product_name AS first_item_purchased
FROM
    mrx_restaurants.sales
        JOIN
    mrx_restaurants.menu ON sales.product_id = menu.product_id
WHERE
    sales.order_date = (SELECT 
            MIN(order_date)
        FROM
            mrx_restaurants.sales AS sub_sales
        GROUP BY sales.customer_id)

####################################################################################################
 
 #4. What is the most purchased item on the menu and how many times was it purchased by all customers?

SELECT
    menu.product_name AS product,
    COUNT(sales.product_id) AS total_purchase
FROM
    mrx_restaurants.menu
INNER JOIN
    mrx_restaurants.sales ON sales.product_id = menu.product_id
GROUP BY
    menu.product_name
ORDER BY
    total_purchase DESC
LIMIT 3;

######################################################################################

#5. Which item was the most popular for each customer?

WITH customer_purchases AS (
    SELECT
        sales.customer_id,
        menu.product_name,
        COUNT(sales.product_id) AS purchase_count
    FROM
        mrx_restaurants.sales
    INNER JOIN
        mrx_restaurants.menu ON sales.product_id = menu.product_id
    GROUP BY
        sales.customer_id,
        menu.product_name
),
ranked_purchases AS (
    SELECT
        customer_id,
        product_name,
        purchase_count,
        RANK() OVER (PARTITION BY customer_id ORDER BY purchase_count DESC) AS rank_num
    FROM
        customer_purchases
)
SELECT
    customer_id AS customer,
    product_name AS most_popular_item,
    purchase_count AS times_purchased
FROM
    ranked_purchases
WHERE
    rank_num = 1
ORDER BY
    customer_id;
    
##############################################################################################
#6 which item was purchased first by the customer after they become a member?
 
SELECT 
    sales.customer_id as customer,
    menu.product_name as first_item_purchased
FROM
    mrx_restaurants.members
left join 
	mrx_restaurants.sales on members.customer_id = sales.customer_id
left join
	mrx_restaurants.menu on sales.product_id = menu.product_id
where 
	sales.order_date = (
		select min(order_date)
		from mrx_restaurants.sales as s
		where s.customer_id = sales.customer_id
		and s.order_date >= members.join_date
        )
        OR sales.order_date IS NULL
order by members.customer_id;

############################################################################################

# 7 Which item was purchased just before the customer become the member?

 with ranks as
 (
 SELECT 
    sales.customer_id as customer, 
    sales.order_date ,
    menu.product_name,
    rank () over (partition by sales.customer_id order by sales.order_date) as ranks,
    members.join_date
FROM
    mrx_restaurants.members
        LEFT JOIN
    mrx_restaurants.sales ON members.customer_id = sales.customer_id
        LEFT JOIN
    mrx_restaurants.menu ON sales.product_id = menu.product_id
where 
	 sales.order_date < members.join_date
	)
select Distinct customer, order_date, product_name, ranks, join_date from ranks
	where ranks = 1;                  
    
###################################################################################################

#8 What is the total items and amount spent for each member before they become a member?

SELECT 
    sales.customer_id, 
    count(sales.product_id) as total_item, 
    sum(menu.price) as total_amount_spent
FROM
    mrx_restaurants.members
        LEFT JOIN
    mrx_restaurants.sales ON members.customer_id = sales.customer_id
        LEFT JOIN
    mrx_restaurants.menu ON sales.product_id = menu.product_id
where 
sales.order_date < members.join_date
group by sales.customer_id;
    
###########################################################################################
#9. If each $1 spent equates to 10 points and sushi has x2 points multiplier - how many points would each customer have?

with points as 
(
	select menu. * ,
			case
				when menu.product_name = 'sushi' then price * 20
				when menu.product_name != 'sushi' then price * 10
			end as points
	from 
		mrx_restaurants.menu
)
select 
	sales.customer_id, 
    sum(points) as total_points
from 
	mrx_restaurants.sales
join 
	points on sales.product_id = points.product_id
group by 
	sales.customer_id;
    
    ########################################################################################
    
#10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi — how many points do customer A and B have at the end of January?

SELECT customer_id, SUM(total_points) AS total_points
FROM 
(
    WITH points AS
    (
        SELECT 
            sales.customer_id, 
            DATEDIFF(sales.order_date, members.join_date) AS first_week,
            menu.price,
            menu.product_name,
            sales.order_date
        FROM 
            mrx_restaurants.sales
        JOIN 
            mrx_restaurants.menu ON sales.product_id = menu.product_id
        JOIN 
            mrx_restaurants.members ON members.customer_id = sales.customer_id
    )
    SELECT 
        customer_id,
        order_date,
        CASE 
            WHEN first_week BETWEEN 0 AND 7 THEN price * 20
            WHEN (first_week > 7 OR first_week < 0) AND product_name = 'sushi' THEN price * 20
            WHEN (first_week > 7 OR first_week < 0) AND product_name != 'sushi' THEN price * 10
        END AS total_points
    FROM points
    WHERE EXTRACT(MONTH FROM order_date) = 1
) AS t
GROUP BY customer_id;


