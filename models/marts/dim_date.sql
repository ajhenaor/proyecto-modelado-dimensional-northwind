{{ config(schema="marts", materialized="table") }}

with bounds as (
    select min(dt) as min_dt, max(dt) as max_dt
    from (
        select order_date as dt from {{ ref("stg_orders") }} where order_date is not null
        union all
        select required_date from {{ ref("stg_orders") }} where required_date is not null
        union all
        select shipped_date from {{ ref("stg_orders") }} where shipped_date is not null
    ) as u
),

spine as (
    select dateadd(day, seq4(), (select min_dt from bounds)) as date_day
    from table(generator(rowcount => 10000))
)

select
    cast(to_char(date_day, 'YYYYMMDD') as number(38, 0)) as date_key,
    date_day,
    year(date_day) as year_n,
    month(date_day) as month_n,
    day(date_day) as day_of_month,
    dayofweekiso(date_day) as iso_weekday,
    quarter(date_day) as quarter_n
from spine
where date_day between (select min_dt from bounds) and (select max_dt from bounds)
