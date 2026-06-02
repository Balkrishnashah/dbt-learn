select 
* 
from
{{ source('data_source', 'dim_store') }}