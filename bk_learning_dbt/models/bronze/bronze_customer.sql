{{
  config(
    materialized = 'view',
    )
}}

select 
* 
from
{{ source('data_source', 'dim_customer') }}