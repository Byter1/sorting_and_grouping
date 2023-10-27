-- 1 задание 
SELECT 
    city,
    CASE 
        WHEN age BETWEEN 0 AND 20 THEN 'young'
        WHEN age BETWEEN 21 AND 49 THEN 'adult'
        ELSE 'old'
    END AS age_category,
    COUNT(*) AS number_of_users
FROM users
GROUP BY city, age_category
ORDER BY number_of_users DESC;

-- 2 задание
select ROUND(avg(price)::numeric,2) as avg_price, category from products
where name like '%Hair%' or name like '%hair%'
	  or name like '%Home%' or name like '%home%'
group by category
ORDER BY avg_price DESC;

-- 3 задание

select seller_id, 
	   count(category) as total_ceteg, 
       round(avg(rating)::numeric, 2) as avg_rating,
       sum(revenue) as total_revenue,
       case WHEN (count(category) > 1 and sum(revenue) > 50000) THEN 'rich' Else 'poor' END as seller_type
from sellers
where category <> 'Bedding'
group by seller_id
having count(category) > 1
order by seller_id;


-- 4 задание
WITH PoorSellers AS (
    SELECT seller_id,
           COUNT(DISTINCT category) AS num_categories,
           SUM(revenue) AS total_revenue,
           MIN(TO_TIMESTAMP(date_reg, 'DD/MM/YYYY')) AS registration_date
    FROM sellers
    where category <> 'Bedding'
    GROUP BY seller_id
    HAVING COUNT(DISTINCT category) < 2 AND SUM(revenue) <= 50000
),

DeliveryDifference AS (
    SELECT MAX(delivery_days) - MIN(delivery_days) AS max_delivery_difference, 
 	MAX(delivery_days) as max_d, min(delivery_days) as min_d
    FROM sellers
    WHERE seller_id IN (SELECT seller_id FROM PoorSellers)
)

SELECT 
    seller_id,
    (EXTRACT(EPOCH FROM NOW() - registration_date) / (30 * 24 * 3600))::INT AS month_from_registration,
    (SELECT max_delivery_difference FROM DeliveryDifference) AS max_delivery_difference
FROM PoorSellers
ORDER BY seller_id;


-- 5 задание
WITH CategoryRevenue AS (
    SELECT 
        seller_id,
        category,
        SUM(revenue) AS total_revenue
    FROM sellers
    WHERE EXTRACT(YEAR FROM TO_DATE(date_reg, 'DD/MM/YYYY')) = 2022
    GROUP BY seller_id, category
),

FilteredSellers AS (
    SELECT 
        seller_id
    FROM CategoryRevenue
    GROUP BY seller_id
    HAVING COUNT(DISTINCT category) = 2 AND SUM(total_revenue) > 75000
)

SELECT 
    f.seller_id,
    (
        SELECT STRING_AGG(category, ' - ')
        FROM (
            SELECT category 
            FROM CategoryRevenue
            WHERE seller_id = f.seller_id
            ORDER BY category
            LIMIT 2
        ) AS sub
    ) AS category_pair
FROM FilteredSellers f;