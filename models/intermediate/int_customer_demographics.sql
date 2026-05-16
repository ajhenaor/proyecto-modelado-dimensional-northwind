{{ config(schema="int", materialized="table") }}

with base as (
    select
        c.customer_id,
        c.company_name,
        c.contact_name,
        c.contact_title,
        c.address,
        c.city,
        c.region,
        c.postal_code,
        c.country,
        c.phone,
        c.fax,
        ccd.customer_type_id,
        cd.customer_desc as customer_type_description,
        row_number() over (
            partition by c.customer_id
            order by ccd.customer_type_id
        ) as rn
    from {{ ref("stg_customers") }} as c
    left join {{ ref("stg_customer_customer_demo") }} as ccd
        on c.customer_id = ccd.customer_id
    left join {{ ref("stg_customer_demographics") }} as cd
        on ccd.customer_type_id = cd.customer_type_id
)

select
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
    md5(
        concat_ws(
            '|',
            customer_id,
            coalesce(company_name, ''),
            coalesce(customer_type_id, '')
        )
    ) as customer_attribute_hash
from base
where rn = 1
