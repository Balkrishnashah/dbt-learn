select 
date_sk,
product_sk,
sum(gross_amount) as total_gross_amount
from {{ ref('silver_sales') }}
group by date_sk,product_sk