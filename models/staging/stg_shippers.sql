{{ config(schema="staging") }}

select
    SHIPPER_ID::number(38, 0) as shipper_id,
    COMPANY_NAME::varchar(255) as company_name,
    PHONE::varchar(255) as phone
from {{ ref("shippers") }}
