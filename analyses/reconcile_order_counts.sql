-- Ad-hoc reconciliation (plan § Post-implementation validation §C): run in Snowflake after dbt build.
-- Expect: staging_orders = fact_orders = distinct order_id on enriched path.

select
    (select count(*) from {{ ref("stg_orders") }}) as staging_orders_rows,
    (select count(distinct order_id) from {{ ref("stg_orders") }}) as staging_distinct_orders,
    (select count(*) from {{ ref("fact_orders") }}) as fact_orders_rows,
    (select count(*) from {{ ref("int_orders_enriched") }}) as int_orders_enriched_rows;
