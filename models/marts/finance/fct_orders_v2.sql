{{
    config(
        materialized = 'incremental',
        unique_key = 'order_id',
        incremental_strategy = 'merge',
        on_schema_change = 'append_new_columns'
    )
}}

with orders as  (
    select * from {{ ref ('stg_orders' )}}
),

payments as (
    select * from {{ ref ('stg_payments') }}
),

order_payments as (
    select
        order_id,
        sum (case when payment_status = 'success' then payment_amount end) as order_total

    from payments
    group by 1
),

 final as (

    select
        orders.order_id::TEXT AS order_id,
        orders.customer_id::TEXT AS customer_id,
        orders.order_date,
        orders.order_status,
        coalesce (order_payments.order_total, 0) as order_amount

    from orders
    left join order_payments using (order_id)
)

select * from final

{% if is_incremental() -%}
    where order_date >= (select max(order_date) from final ) --{{this}}
{% endif %}
