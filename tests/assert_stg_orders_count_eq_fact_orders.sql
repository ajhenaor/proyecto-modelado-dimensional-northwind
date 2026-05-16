-- stg_orders vs fact_orders row counts must match (no orphan-order policy).
select
    s.n_stg,
    f.n_fact
from (
    select count(*) as n_stg from {{ ref('stg_orders') }}
) s
cross join (
    select count(*) as n_fact from {{ ref('fact_orders') }}
) f
where s.n_stg <> f.n_fact
