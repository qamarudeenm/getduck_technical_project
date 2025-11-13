{% macro quote(identifier) %}
  {# Override adapter quote to prevent backticks/quotes on ClickHouse relations #}
  {{ identifier }}
{% endmacro %}
