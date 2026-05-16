-- order_date must fall within each joined SCD2 dim validity window.
select 'customer' as dim_role, fo.order_id
from {{ ref('fact_orders') }} as fo
inner join {{ ref('dim_customer') }} as d on fo.customer_key = d.customer_key
where fo.order_date < cast(d.effective_from as date)
    or (d.effective_to is not null and fo.order_date >= cast(d.effective_to as date))

union all

select 'employee', fo.order_id
from {{ ref('fact_orders') }} as fo
inner join {{ ref('dim_employee') }} as d on fo.employee_key = d.employee_key
where fo.order_date < cast(d.effective_from as date)
    or (d.effective_to is not null and fo.order_date >= cast(d.effective_to as date))

union all

select 'shipper', fo.order_id
from {{ ref('fact_orders') }} as fo
inner join {{ ref('dim_shipper') }} as d on fo.shipper_key = d.shipper_key
where fo.order_date < cast(d.effective_from as date)
    or (d.effective_to is not null and fo.order_date >= cast(d.effective_to as date))
