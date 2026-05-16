{{ config(schema="staging") }}

select
    CUSTOMER_ID::varchar(255) as customer_id,
    COMPANY_NAME::varchar(255) as company_name,
    CONTACT_NAME::varchar(255) as contact_name,
    CONTACT_TITLE::varchar(255) as contact_title,
    ADDRESS::varchar(500) as address,
    CITY::varchar(255) as city,
    REGION::varchar(255) as region,
    POSTAL_CODE::varchar(255) as postal_code,
    COUNTRY::varchar(255) as country,
    PHONE::varchar(255) as phone,
    FAX::varchar(255) as fax
from {{ ref("customers") }}
