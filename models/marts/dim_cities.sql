with

    cities as (
        select
            *
            , 1 as col
        from {{ ref('stg_wwi__cities') }}
    )

select *
from cities
