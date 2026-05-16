{{ config(schema="marts", materialized="table") }}

{# First SCD2 row: backdate effective_from when snapshot valid_from is warehouse load time (plan §6). #}
with snap as (
    select
        *,
        row_number() over (
            partition by customer_id
            order by dbt_valid_from
        ) as _scd_version_rn
    from {{ ref("snapshot_customer_history") }}
)

select
    md5(concat_ws('|', cast(customer_id as varchar), to_varchar(dbt_valid_from))) as customer_key,
    customer_id,
    company_name,
    contact_name,
    contact_title,
    address,
    city,
    region,
    postal_code,
    country,
    phone,
    fax,
    customer_type_id,
    customer_type_description,
    case
        when _scd_version_rn = 1 then to_timestamp_ntz('1900-01-01')
        else dbt_valid_from
    end as effective_from,
    dbt_valid_to as effective_to,
    (dbt_valid_to is null) as is_current
from snap
