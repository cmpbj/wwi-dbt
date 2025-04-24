with
    source as (
        select *
        from {{ source('wwi_sources', 'raw_employees') }}
    )

    , casting_columns as (
        select
            cast("employeeKey" as bigint) as employee_pk
            , cast("employee" as varchar) as employee_name
            , cast("preferredName" as varchar) as preferred_name
            , cast("isSalesPerson" as boolean) as is_sales_person
            , cast("photo" as varchar) as photo
            , cast("validFrom" as timestamp) as valid_from
            , cast("validTo" as timestamp) as valid_to
            , cast("extraction_date" as timestamp) as extraction_date
        from source
    )

select *
from casting_columns
