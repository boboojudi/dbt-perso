{# -- use this set if you are comparing to another dbt model
{% set old_relation=ref('fct_orders', v=1) %}

-- this is your newly built dbt model 
{% set dbt_relation=ref('fct_orders') %}

{{ audit_helper.compare_relation_columns(
    a_relation = old_relation,
    b_relation = dbt_relation
) }} #}


{% set old_query %}
    select * from {{ ref('fct_orders', v=1) }}
{% endset %}

{% set new_query %}
    select * from {{ ref('fct_orders') }}
{% endset %}

{{ audit_helper.compare_column_values(
    a_query = old_query,
    b_query = new_query,
    primary_key = "order_id",
    column_to_compare = "customer_id"
) }}
