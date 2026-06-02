{%- set inc_flag = 1 -%}

{%- if inc_flag == 1 -%}

    select
        sales_id,
        date_sk,
        sum(unit_price) as total_unit_price
    from {{ ref('bronze_sales') }}
    where quantity > 1
    group by sales_id, date_sk

{% else %}

    select
        sales_id,
        date_sk,
        sum(unit_price) as total_unit_price
    from {{ ref('bronze_sales') }}
    group by sales_id, date_sk

{% endif %}