-- models/marts/fct_orders.sql

with
orders as (
    select *
    from {{ ref('stg_wwi__orders') }}
),

cities as (
    select *
    from {{ ref('stg_wwi__cities') }}
),

joined as (
    select
        -- Orders Measures and Foreign Keys (excluding city_fk)
        o.order_pk,
        o.address_description,
        o.customer_fk,
        o.customer_name, -- Consider if this should only be in dim_customers
        o.stock_item_fk,
        o.stock_item_description, -- Consider if this should only be in dim_stock_items
        o.order_date,
        o.picked_date,
        o.sales_person_fk,
        o.picker_key_fk,
        o.order_item_description,
        o.package,
        o.quantity,
        o.unit_price,
        o.tax_rate,
        o.total_excluding_tax,
        o.tax_amount,
        o.total_including_tax,
        --o.extraction_date as order_extraction_date, -- Optional: Include if needed

        -- City Dimension Key from Cities table
        c.city_pk as city_dim_key
        -- Optional: Include city attributes directly if needed for performance/convenience
        -- c.city_name,
        -- c.state_province_name,
        -- c.county_name,
        -- c.continent_name,
        -- c.sales_territory_name,
        -- c.region_name,
        -- c.sub_region_name,
        -- c.lastest_recorded_population_number,
        -- c.extraction_date as city_extraction_date -- Optional: Include if needed

    from orders o
    left join cities c
        on o.city_fk = c.city_pk
)

select *
from joined
