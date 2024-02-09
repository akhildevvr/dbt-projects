{% macro source_table_freshness() %}
-- this macro contains code to check the source freshness of all source tables
    {{ log("macro: source_table_freshness", True) }}

    {{ log("macro: source_table_freshness - Fetching sources", True) }}
    {% call statement('kpi_source', fetch_result=True) %}
        WITH kpi_status AS (
            SELECT 
                LOWER(kpi) AS kpi,
                PARSE_JSON(sources) AS sources
            FROM {{ source('metrics_ingest', 'kpi_standardization_kpis_tracker_tracker')}}
            WHERE sources IS NOT NULL
        ),
        exp_src AS (
            SELECT
                kpi || '-' || sources:source::string 
                || '-'|| sources:loaded_at::string as kpi_src
            FROM kpi_status
        )
        SELECT *
        FROM exp_src
    {% endcall %}

    {% set results = load_result('kpi_source')['data'] %}

    {% for source in results %}
        {% set kpi, src, load_at = source[0].split('-') %}

        {%- call statement('get_max_load_dt', fetch_result=True) -%}
            SELECT MAX({{ load_at }}) FROM {{src}}
        {%- endcall -%}
        {% set dt = load_result('get_max_load_dt')['data'][0] %}

        {# convert 'yyyymmdd' date fromat to 'yyyy-mm-dd' fromat #}
        {% set max_load_dt = dt[0] if dt[0] is not string else dt[0][:4]~'-'~dt[0][4:6]~'-'~dt[0][6:8] %}
        {{ log("macro: source_table_freshness - src: " ~ src ~" load_at: "~load_at~" max_load_date: " ~ max_load_dt, True) }}
        
        SELECT
            TOP 1
            'source_freshness' AS test_type,
            LOWER('{{kpi}}') AS kpi_name,
            '{{src}}' AS source,
            TO_TIMESTAMP('{{max_load_dt}}') AS max_loaded_date,
            CURRENT_DATE() AS dt
        FROM {{ src }}
            WHERE DATEDIFF('day', TO_TIMESTAMP('{{max_load_dt}}'), CURRENT_TIMESTAMP()) > 1
        
        {% if not loop.last %}
            UNION ALL
        {% endif %}

    {% endfor %}

{% endmacro %}