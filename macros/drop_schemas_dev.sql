{% macro drop_schemas_dev(pattern) %}

    {#- This macro will drop all schemas following the pattern -#}

    {% set get_dev_schemas_query %}
        select
            nspname as schema_name
        from pg_catalog.pg_namespace
        where nspname not in ('pg_catalog', 'information_schema')
        and nspname like '%{{ pattern }}%';
    {% endset %}

    {% if execute %}
        {% set dev_schemas = run_query(get_dev_schemas_query).columns[0].values() %}
    {% endif %}

    {% for schema_name in dev_schemas %}

        {% if schema_name in ['raw', 'staging', 'marts', 'pg_catalog', 'pg_toast', 'public', 'information_schema'] %}

            {% do log("Can't drop " + schema_name + " schema", info=True) %}

        {% else %}

            {% set drop_schemas %}
                drop schema {{ schema_name }} cascade;
            {% endset %}

            {% do run_query(drop_schemas) %}

            {% do log("Dropped schema " ~ schema_name, info = true) %}

        {% endif %}

    {% endfor %}

{% endmacro %}
