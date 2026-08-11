{{ config(materialized='table') }}

select
    transaction_id,
    customer_id,
    product_id,
    order_date,
    quantity,
    price,
    currency,
    exchange_rate_to_inr,
    transaction_amount,
    transaction_amount_inr,
    payment_method,
    order_status
from {{ ref('silver') }}