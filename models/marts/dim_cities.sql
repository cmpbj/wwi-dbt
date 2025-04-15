with

cities as (
    select *
    from {{ ref('stg_wwi__cities') }}
)

select *
from cities
