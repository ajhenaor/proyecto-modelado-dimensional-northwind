{{ config(schema="marts", materialized="table") }}

with enriched as (
    select * from {{ ref("int_orders_enriched") }}
),

dim_c as (
    select * from {{ ref("dim_customer") }}
),

dim_e as (
    select * from {{ ref("dim_employee") }}
),

dim_s as (
    select * from {{ ref("dim_shipper") }}
),

dim_d as (
    select * from {{ ref("dim_date") }}
),

joined as (
    select
        e.*,
        dc.customer_key,
        de.employee_key,
        ds.shipper_key,
        ddo.date_key as order_date_key,
        ddr.date_key as required_date_key,
        dds.date_key as shipped_date_key
    from enriched as e
    inner join dim_c as dc
        on e.customer_id = dc.customer_id
        and e.order_date >= cast(dc.effective_from as date)
        and (
            dc.effective_to is null
            or e.order_date < cast(dc.effective_to as date)
        )
    inner join dim_e as de
        on e.employee_id = de.employee_id
        and e.order_date >= cast(de.effective_from as date)
        and (
            de.effective_to is null
            or e.order_date < cast(de.effective_to as date)
        )
    inner join dim_s as ds
        on e.shipper_id = ds.shipper_id
        and e.order_date >= cast(ds.effective_from as date)
        and (
            ds.effective_to is null
            or e.order_date < cast(ds.effective_to as date)
        )
    inner join dim_d as ddo on e.order_date = ddo.date_day
    inner join dim_d as ddr on e.required_date = ddr.date_day
    left join dim_d as dds on e.shipped_date = dds.date_day
)

select
    md5(cast(order_id as varchar)) as order_key,
    order_id,
    customer_id,
    employee_id,
    shipper_id,
    order_date,
    required_date,
    shipped_date,
    freight_amount,
    ship_name,
    ship_address,
    ship_city,
    ship_region,
    ship_postal_code,
    ship_country,
    order_line_count,
    order_quantity,
    gross_sales_amount,
    discount_amount,
    net_sales_amount,
    order_value_tier,
    days_to_ship,
    days_late,
    is_shipped,
    is_late,
    is_on_time,
    order_date_key,
    required_date_key,
    shipped_date_key,
    customer_key,
    employee_key,
    shipper_key,
    1::number(38, 0) as order_count,
    cast(null as timestamp_ntz) as created_at,
    cast(null as timestamp_ntz) as updated_at
from joined
