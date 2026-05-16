{{ config(schema="marts", materialized="table") }}

with snap as (
    select
        *,
        row_number() over (
            partition by employee_id
            order by dbt_valid_from
        ) as _scd_version_rn
    from {{ ref("snapshot_employee_history") }}
)

select
    md5(concat_ws('|', cast(employee_id as varchar), to_varchar(dbt_valid_from))) as employee_key,
    employee_id,
    last_name,
    first_name,
    title,
    title_of_courtesy,
    birth_date,
    hire_date,
    address,
    city,
    region,
    postal_code,
    country,
    home_phone,
    extension,
    notes,
    reports_to,
    photo_path,
    salary,
    case
        when _scd_version_rn = 1 then to_timestamp_ntz('1900-01-01')
        else dbt_valid_from
    end as effective_from,
    dbt_valid_to as effective_to,
    (dbt_valid_to is null) as is_current
from snap
