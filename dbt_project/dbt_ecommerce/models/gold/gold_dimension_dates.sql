{{ config(materialized='table') }}

SELECT DISTINCT
    order_date,
    extract(YEAR FROM order_date) AS year,
    extract(QUARTER FROM order_date) AS quarter,
    extract(MONTH FROM order_date) AS month,
    extract(WEEK FROM order_date) AS week,
    extract(DAY FROM order_date) AS day,
    extract(DOW FROM order_date) AS day_of_week

FROM {{ ref('silver') }}