{{ config(schema="int", materialized="table") }}

with line_agg as (
    select
        order_id,
        count(*) as order_line_count,
        sum(quantity) as order_quantity,
        sum(gross_sales_amount) as gross_sales_amount,
        sum(discount_amount) as discount_amount,
        sum(net_sales_amount) as net_sales_amount
    from {{ ref("int_order_line_amounts") }}
    group by order_id
),

orders as (
    select * from {{ ref("stg_orders") }}
)

select
    o.order_id,
    o.customer_id,
    o.employee_id,
    o.shipper_id,
    o.order_date,
    o.required_date,
    o.shipped_date,
    o.freight_amount,
    o.ship_name,
    o.ship_address,
    o.ship_city,
    o.ship_region,
    o.ship_postal_code,
    o.ship_country,
    coalesce(a.order_line_count, 0)::number(38, 0) as order_line_count,
    coalesce(a.order_quantity, 0)::number(38, 4) as order_quantity,
    coalesce(a.gross_sales_amount, 0)::decimal(38, 4) as gross_sales_amount,
    coalesce(a.discount_amount, 0)::decimal(38, 4) as discount_amount,
    coalesce(a.net_sales_amount, 0)::decimal(38, 4) as net_sales_amount,
    case
        when coalesce(a.net_sales_amount, 0) > 500 then 'enterprise'
        when coalesce(a.net_sales_amount, 0) >= 300 then 'premium'
        else 'standard'
    end as order_value_tier,
    case
        when o.shipped_date is null then null
        else datediff(day, o.order_date, o.shipped_date)
    end as days_to_ship,
    case
        when o.shipped_date is null then null
        else datediff(day, o.required_date, o.shipped_date)
    end as days_late,
    o.shipped_date is not null as is_shipped,
    case
        when o.shipped_date is null then null
        when o.shipped_date > o.required_date then true
        else false
    end as is_late,
    case
        when o.shipped_date is null then null
        when o.shipped_date <= o.required_date then true
        else false
    end as is_on_time
from orders as o
left join line_agg as a on o.order_id = a.order_id
