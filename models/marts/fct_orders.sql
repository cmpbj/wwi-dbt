with
    orders as (
        select *
        from {{ ref('stg_wwi__orders') }}
    )

    , cities as (
        select *
        from {{ ref('stg_wwi__cities') }}
    )

    , joined as (
        select
        -- Orders Measures and Foreign Keys (excluding city_fk)
            orders.order_pk
            , orders.address_description
            , orders.customer_fk
            , orders.customer_name
            , orders.stock_item_fk
            , orders.stock_item_description
            , orders.order_date
            , orders.picked_date
            , orders.sales_person_fk
            , orders.picker_key_fk
            , orders.order_item_description
            , orders.package
            , orders.quantity
            , orders.unit_price
            , orders.tax_rate
            , orders.total_excluding_tax
            , orders.tax_amount
            , orders.total_including_tax
            --o.extraction_date as order_extraction_date, -- Optional: Include if needed

            -- City Dimension Key from Cities table
            , cities.city_pk as city_fk
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

        from orders
        left join cities on orders.city_fk = cities.city_pk
    )

select *
from joined
