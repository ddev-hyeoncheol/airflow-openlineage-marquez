{{ config(
    schema='dm',
    materialized='table'
) }}

with customer_orders as (
    select
        customer_id,
        customer_name,
        customer_email,
        order_date,
        total_order_amount,
        total_items_count
    from {{ ref('customer_orders') }}
),

customer_aggregates as (
    select
        customer_id,
        customer_name,
        customer_email,
        ('2026-01-31'::date - max(order_date)) as recency_days,
        count(distinct order_date) as purchase_frequency,
        sum(total_order_amount) as total_monetary_amount,
        avg(total_order_amount) as average_order_amount,
        sum(total_items_count) as total_items_purchased
    from customer_orders
    group by customer_id, customer_name, customer_email
),

rfm_scores as (
    select
        customer_id,
        customer_name,
        customer_email,
        recency_days,
        purchase_frequency,
        total_monetary_amount,
        average_order_amount,
        total_items_purchased,
        case
            when recency_days <= 5 then 3
            when recency_days <= 15 then 2
            else 1
        end as r_score,
        case
            when purchase_frequency >= 3 then 3
            when purchase_frequency >= 2 then 2
            else 1
        end as f_score,
        case
            when total_monetary_amount >= 500 then 3
            when total_monetary_amount >= 200 then 2
            else 1
        end as m_score
    from customer_aggregates
)

select
    customer_id,
    customer_name,
    customer_email,
    recency_days,
    purchase_frequency,
    total_monetary_amount,
    average_order_amount,
    total_items_purchased,
    (r_score + f_score + m_score) as total_rfm_score,
    case
        when (r_score + f_score + m_score) >= 8 then 'VIP'
        when (r_score + f_score + m_score) >= 6 then 'Regular'
        when (r_score + f_score + m_score) >= 4 then 'Risky'
        else 'Lost'
    end as customer_segment
from rfm_scores
