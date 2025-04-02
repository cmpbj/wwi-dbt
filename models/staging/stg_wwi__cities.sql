with
    source as (
        select *
        from {{ source('wwi_sources', 'raw_cities') }}
    )

    , casting_columns as (
        select
            cast("cityKey" as int) as city_pk
            , cast("city" as varchar) as city_name
            , cast("stateProvince" as varchar) as state_province_name
            , cast("country" as varchar) as county_name
            , coalesce(cast("continent" as varchar), 'Not Provided') as continent_name
            , cast("salesTerritory" as varchar) as sales_territory_name
            , cast("region" as varchar) as region_name
            , cast("subregion" as varchar) as subregion_name
            , cast("latestRecordedPopulation" as int) as lastest_recorded_population_number
            , cast("validFrom" as timestamp) as valid_from
            , cast("validTo" as timestamp) as valid_to
            , cast("extraction_date" as timestamp) as extraction_date
        from source
        where cast("cityKey" as int) != 0
    )

select *
from casting_columns
