{{ config(schema="staging") }}

select
    CUSTOMER_TYPE_ID::varchar(255) as customer_type_id,
    CUSTOMER_DESC::varchar(4000) as customer_desc
from {{ ref("customer_demographics") }}
