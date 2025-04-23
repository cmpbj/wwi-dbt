with

    cities as (
        select
            *
            , 1
        from {{ ref('stg_wwi__cities') }}
    )

select *
from cities
