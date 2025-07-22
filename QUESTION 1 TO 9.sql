# Coffee Consumers Count
-- How many people in each city are estimated to consume coffee, given that 25% of the population does?
select*from city;


select city_name,population,
round((population*25)/100,2) as coffe_consumers,city_rank
from city
order by (population*25)/100 desc ;

#Total Revenue from Coffee Sales
-- What is the total revenue generated from coffee sales across all cities in the last quarter of 2023?
select*from sales;


select
year(sale_date) as year,
sum(total) as revenue
from sales
where 
quarter(sale_date)=4
group by 
year(sale_date)
order by year;


#Sales Count for Each Product
-- How many units of each coffee product have been sold?
select*from sales;


select
p.product_name,
count(s.sale_id) as total
from sales s
join products p on s.product_id=p.product_id
group by  p.product_name
order by total desc;


# Average Sales Amount per City
-- What is the average sales amount per customer in each city?

with cte as (
select c.city_name as city,
u.customer_id as customer_id
from city c
join customers u 
on  c.city_id=u.city_id)

select

sum(s.total)/COUNT(DISTINCT t.customer_id) as avg_per_customer,
t.city 
from sales s 
join cte t on s.customer_id=t.customer_id
group by t.city
order by  avg_per_customer desc;


#City Population and Coffee Consumers
-- Provide a list of cities along with their populations and estimated coffee consumers.

select
city_name,
population,
population*0.25 as coffe_consumers
from city
order by coffe_consumers desc;


#Top Selling Products by City
-- What are the top 3 selling products in each city based on sales volume?

select
y.city_name as city ,
p.product_name as products,
count(s.sale_id) as total_orders
from sales s
join products p on s.product_id=p.product_id
join customers c on  s.customer_id=c.customer_id
join city y on c.city_id=y.city_id
GROUP BY 
    y.city_name, p.product_name
    
order by city_name ,total_orders desc;



-- OR 
with ranked_sales as(select
t.city_name,
p.product_name,
count(s.sale_id) as total_orders,
dense_rank()over(partition  by t.city_name order by  count(s.sale_id) desc) as ranking
from sales s
join products p on s.product_id=p.product_id
join customers c on s.customer_id=c.customer_id
join city t on c.city_id =t.city_id
group by t.city_name,p.product_name
) 
select*from ranked_sales
where ranking<=3
order by city_name,ranking;


# Customer Segmentation by City
-- How many unique customers are there in each city who have purchased coffee products?
select
count(distinct s.customer_id) no_of_customers,
t.city_name
from sales s
join products p on s.product_id=s.product_id
join customers c on s.customer_id = c.customer_id
join city t on c.city_id=t.city_id
group by t.city_name
order by count(distinct s.customer_id) desc;


#Average Sale vs Rent
-- Find each city and their average sale per customer and avg rent per customer




WITH rent AS (
    SELECT 
        SUM(estimated_rent) AS total_rent,
        city_name,
        city_id 
    FROM 
        city
    GROUP BY 
        city_name, city_id
),

sale AS (
    SELECT 
        SUM(total) AS total_sales,
        customer_id,
        product_id
    FROM 
        sales
    GROUP BY 
        product_id, customer_id
)

SELECT 
    r.city_name,
    r.total_rent / COUNT(DISTINCT s.customer_id) AS avg_rent,
    SUM(s.total_sales) / COUNT(DISTINCT s.customer_id) AS avg_sales
FROM 
    rent r
JOIN 
    customers c ON r.city_id = c.city_id
JOIN 
    sale s ON s.customer_id = c.customer_id
GROUP BY 
    r.city_name, r.total_rent;
    
    
    
    
# Monthly Sales Growth
-- Sales growth rate: Calculate the percentage growth (or decline) in sales over different time periods (monthly).


WITH monthly_sales AS (
    SELECT 
        ci.city_name,
        EXTRACT(MONTH FROM sale_date) AS month,
        EXTRACT(YEAR FROM sale_date) AS sale_year,
        SUM(s.total) AS total_sale
    FROM 
        sales s
    JOIN 
        customers c ON c.customer_id = s.customer_id
    JOIN 
        city ci ON ci.city_id = c.city_id
    GROUP BY 
        ci.city_name, month, sale_year
),

growth_ratio AS (
    SELECT
        city_name,
        month,
        sale_year,
        total_sale AS cr_month_sale,
        LAG(total_sale, 1) OVER(PARTITION BY city_name ORDER BY sale_year, month) AS last_month_sale
    FROM 
        monthly_sales
)

SELECT
    city_name,
    month,
    sale_year,
    cr_month_sale,
    last_month_sale,
    ROUND(
        (cr_month_sale - last_month_sale) / last_month_sale * 100, 2
    ) AS growth_ratio
FROM 
    growth_ratio
WHERE 
    last_month_sale IS NOT NULL
ORDER BY 
    city_name, sale_year, month;

 













