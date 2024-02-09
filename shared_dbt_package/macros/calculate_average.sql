{% macro calculate_average(column_name) %}

    avg({{ column_name }}) as average_value


{% endmacro %}