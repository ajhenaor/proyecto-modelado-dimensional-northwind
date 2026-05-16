{% snapshot snapshot_customer_history %}

{{
    config(
        unique_key="customer_id",
        strategy="check",
        check_cols=[
            "company_name",
            "contact_name",
            "contact_title",
            "address",
            "city",
            "region",
            "postal_code",
            "country",
            "phone",
            "fax",
            "customer_type_id",
            "customer_type_description",
            "customer_attribute_hash",
        ],
    )
}}

select * from {{ ref("int_customer_demographics") }}

{% endsnapshot %}
