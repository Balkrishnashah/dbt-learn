with sales as (

    select sales_id,
    date_sk,
    store_sk,
    product_sk,
    quantity,
    unit_price,
    gross_amount
    from {{ ref('bronze_sales') }}
),
product as (
    select
    product_sk,
    product_code
    from {{ ref('bronze_product') }}
)
select
a.sales_id,
a.date_sk,
a.store_sk,
a.product_sk,
a.quantity,
a.unit_price,
round(a.gross_amount,2) as gross_amount,
b.product_code
from sales a inner join product b
on a.product_sk = b.product_sk
