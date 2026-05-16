{% snapshot snapshot_employee_history %}

{{
    config(
        unique_key="employee_id",
        strategy="check",
        check_cols=[
            "last_name",
            "first_name",
            "title",
            "title_of_courtesy",
            "birth_date",
            "hire_date",
            "address",
            "city",
            "region",
            "postal_code",
            "country",
            "home_phone",
            "extension",
            "notes",
            "reports_to",
            "photo_path",
            "salary",
        ],
    )
}}

select * from {{ ref("int_employees_enriched") }}

{% endsnapshot %}
