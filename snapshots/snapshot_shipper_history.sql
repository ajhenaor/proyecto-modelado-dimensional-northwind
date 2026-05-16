{% snapshot snapshot_shipper_history %}

{{
    config(
        unique_key="shipper_id",
        strategy="check",
        check_cols=[
            "company_name",
            "phone",
        ],
    )
}}

select * from {{ ref("stg_shippers") }}

{% endsnapshot %}
