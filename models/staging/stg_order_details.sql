{{ config(schema="staging") }}

select
    ORDER_ID::number(38, 0) as order_id,
    PRODUCT_ID::number(38, 0) as product_id,
    try_to_decimal(trim(UNIT_PRICE::varchar), 38, 4) as unit_price,
    try_to_decimal(trim(QUANTITY::varchar), 38, 0) as quantity,
    try_to_decimal(trim(DISCOUNT::varchar), 38, 4) as discount_pct
from {{ ref("order_details") }}
