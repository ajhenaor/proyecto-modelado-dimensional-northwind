{{ config(schema="int", materialized="table") }}

with lines as (
    select * from {{ ref("stg_order_details") }}
)

select
    order_id,
    product_id,
    quantity,
    unit_price,
    discount_pct,
    unit_price * quantity as gross_sales_amount,
    unit_price * quantity * discount_pct as discount_amount,
    unit_price * quantity * (1 - discount_pct) as net_sales_amount
from lines
