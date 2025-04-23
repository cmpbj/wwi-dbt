with
    source as (
        select *
        from {{ source('wwi_sources', 'raw_orders') }}
    )

    , casting_columns as (
        select
            cast("orderKey" as bigint) as order_key
            , cast("cityKey" as int) as city_fk
            , cast("address" as varchar) as address_description
            , cast("customerKey" as int) as customer_fk
            , cast("customer" as varchar) as customer_name
            , cast("stockItemKey" as int) as stock_item_fk
            , cast("stockItem" as varchar) as stock_item_description
            , cast("orderDateKey" as date) as order_date
            , cast("pickedDateKey" as date) as picked_date
            , cast("salespersonKey" as int) as sales_person_fk
            , cast("pickerKey" as int) as picker_key_fk
            , cast("description" as varchar) as order_item_description
            , cast("package" as varchar) as package
            , cast("quantity" as int) as quantity
            , cast("unitPrice" as double precision) as unit_price
            , cast("taxRate" as double precision) as tax_rate
            , cast("totalExcludingTax" as double precision) as total_excluding_tax
            , cast("taxAmount" as double precision) as tax_amount
            , cast("totalIncludingTax" as double precision) as total_including_tax
            , cast("extraction_date" as timestamp) as extraction_date
        from source
    )

select *
from casting_columns
