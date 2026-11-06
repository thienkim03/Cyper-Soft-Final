use looker_ecommerce;

-- fact_order_items 
select
    oi.id as order_item_id,
    oi.order_id,
    oi.user_id,
    oi.product_id,
    p.distribution_center_id,
    oi.status,
    date(oi.created_at) as order_date,
    oi.created_at,
    oi.shipped_at,
    oi.delivered_at,
    oi.returned_at,
    round(oi.sale_price, 2) as sale_price,
    round(ii.cost, 2) as cost,
    round(oi.sale_price - ii.cost, 2) as gross_profit
from order_items oi
join inventory_items ii on oi.inventory_item_id = ii.id
join products p on oi.product_id = p.id;

-- dim_products
select 
	id as product_id
	, name as product_name
	, brand
    , category
    , department
    , round(retail_price, 2) as retail_price, round(cost, 2) as cost, distribution_center_id
from products;

-- dim_users
select
    id as user_id,
    age,
    case
        when age < 18 then '<18'
        when age < 25 then '18-24'
        when age < 35 then '25-34'
        when age < 45 then '35-44'
        when age < 55 then '45-54'
        else '55+'
    end as age_group,
    gender,
    case
        when country = 'Deutschland' then 'Germany'
        when country like 'Espa%' then 'Spain'
        when country = 'Brasil' then 'Brazil'
        else country
    end as country,
    state,
    city,
    traffic_source,
    date(created_at) as signup_date
from users;


-- dim_distribution_centers
select 
	id as distribution_center_id
	, name as distribution_center_name
    , latitude
    , longitude
from distribution_centers;

-- fact_orders
select 
	order_id
	, user_id
    , status
    , date(created_at) as order_date
    , num_of_item
from orders;





