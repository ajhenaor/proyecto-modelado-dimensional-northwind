{{ config(schema="staging") }}

select
    CUSTOMER_ID::varchar(255) as customer_id,
    CUSTOMER_TYPE_ID::varchar(255) as customer_type_id
from {{ ref("customer_customer_demo") }}
