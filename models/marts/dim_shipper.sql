{{ config(schema="marts", materialized="table") }}

with snap as (
    select
        *,
        row_number() over (
            partition by shipper_id
            order by dbt_valid_from
        ) as _scd_version_rn
    from {{ ref("snapshot_shipper_history") }}
)

select
    md5(concat_ws('|', cast(shipper_id as varchar), to_varchar(dbt_valid_from))) as shipper_key,
    shipper_id,
    company_name,
    phone,
    case
        when _scd_version_rn = 1 then to_timestamp_ntz('1900-01-01')
        else dbt_valid_from
    end as effective_from,
    dbt_valid_to as effective_to,
    (dbt_valid_to is null) as is_current
from snap
