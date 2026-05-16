{{ config(schema="staging") }}

select
    EMPLOYEE_ID::number(38, 0) as employee_id,
    LAST_NAME::varchar(255) as last_name,
    FIRST_NAME::varchar(255) as first_name,
    TITLE::varchar(255) as title,
    TITLE_OF_COURTESY::varchar(255) as title_of_courtesy,
    try_to_timestamp_ntz(BIRTH_DATE::varchar) as birth_date,
    try_to_timestamp_ntz(HIRE_DATE::varchar) as hire_date,
    ADDRESS::varchar(500) as address,
    CITY::varchar(255) as city,
    REGION::varchar(255) as region,
    POSTAL_CODE::varchar(255) as postal_code,
    COUNTRY::varchar(255) as country,
    HOME_PHONE::varchar(255) as home_phone,
    EXTENSION::varchar(255) as extension,
    NOTES::varchar(8000) as notes,
    nullif(REPORTS_TO::varchar, '')::number(38, 0) as reports_to,
    nullif(PHOTO_PATH::varchar, '')::varchar(500) as photo_path,
    try_to_decimal(nullif(trim(SALARY::varchar), ''), 38, 2) as salary
from {{ ref("employees") }}
