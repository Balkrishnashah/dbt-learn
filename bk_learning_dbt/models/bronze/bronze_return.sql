select 
* 
from
{{ source('data_source', 'fact_returns') }}