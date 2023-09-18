{% macro generate_pf_forecast_case_statements(column_names, var) %}

  {% for column in column_names %}
    ,CASE WHEN LSTDESC_16.VALUE = 'IS Parent' THEN ipc.{{ column }} 

        ELSE IFNULL(forecast.{{ column }}, 0.00) END AS {{ column }}{% if not loop.last %}

  {% endif %}
  {% endfor %}

{% endmacro %}