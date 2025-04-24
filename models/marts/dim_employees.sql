with

    employees as (
        select *
        from {{ ref('stg_wwi__employees') }}
    )

select *
from employees
