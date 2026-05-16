{{ config(schema="staging") }}

select
    ORDER_ID::number(38, 0) as order_id,
    CUSTOMER_ID::varchar(255) as customer_id,
    EMPLOYEE_ID::number(38, 0) as employee_id,
    case
        when trim(coalesce(ORDER_DATE::varchar, '')) = '' then null
        else cast(try_to_timestamp_ntz(ORDER_DATE::varchar) as date)
    end as order_date,
    case
        when trim(coalesce(REQUIRED_DATE::varchar, '')) = '' then null
        else cast(try_to_timestamp_ntz(REQUIRED_DATE::varchar) as date)
    end as required_date,
    case
        when trim(coalesce(SHIPPED_DATE::varchar, '')) = '' then null
        else cast(try_to_timestamp_ntz(SHIPPED_DATE::varchar) as date)
    end as shipped_date,
    SHIP_VIA::number(38, 0) as shipper_id,
    try_to_decimal(trim(FREIGHT::varchar), 38, 4) as freight_amount,
    SHIP_NAME::varchar(255) as ship_name,
    SHIP_ADDRESS::varchar(500) as ship_address,
    SHIP_CITY::varchar(255) as ship_city,
    SHIP_REGION::varchar(255) as ship_region,
    SHIP_POSTAL_CODE::varchar(255) as ship_postal_code,
    SHIP_COUNTRY::varchar(255) as ship_country
from {{ ref("orders") }}
