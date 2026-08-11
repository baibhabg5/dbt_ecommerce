SELECT--revenue by country
    c.country,
    SUM(f.transaction_amount_inr) AS revenue_inr

FROM {{ ref('fact_sales') }} f

JOIN {{ ref('dim_customer') }} c
    ON f.customer_id = c.customer_id

WHERE f.order_status = 'Completed'

GROUP BY c.country

ORDER BY revenue_inr DESC;

SELECT --revenue by category
    p.product_category,
    SUM(f.transaction_amount_inr) AS revenue_inr

FROM {{ ref('fact_sales') }} f

JOIN {{ ref('dim_product') }} p
    ON f.product_id = p.product_id

WHERE f.order_status = 'Completed'

GROUP BY p.product_category

ORDER BY revenue_inr DESC;

SELECT  --revenue by month
    d.year,
    d.month,
    SUM(f.transaction_amount_inr) AS revenue_inr

FROM {{ ref('fact_sales') }} f

JOIN {{ ref('dim_date') }} d
    ON f.order_date = d.order_date

WHERE f.order_status = 'Completed'

GROUP BY
    d.year,
    d.month

ORDER BY
    d.year,
    d.month;

--we used it
SELECT
    d.year,
    d.month,
    ROUND(SUM(f.transaction_amount_inr)::numeric, 2) AS revenue_inr
FROM analytics.gold_fact_orders f
JOIN analytics.gold_dimension_dates d
    ON f.order_date = d.order_date
GROUP BY d.year, d.month
ORDER BY d.year, d.month;
--used it
SELECT
    c.country,
    ROUND(SUM(f.transaction_amount_inr)::numeric, 2) AS revenue_inr
FROM analytics.gold_fact_orders f
JOIN analytics.gold_dimension_customer c
    ON f.customer_id = c.customer_id
GROUP BY c.country
ORDER BY revenue_inr DESC;

SELECT
    d.year,
    d.quarter,
    ROUND(SUM(f.transaction_amount_inr)::numeric, 2) AS revenue_inr
FROM analytics.gold_fact_orders f
JOIN analytics.gold_dimension_dates d
    ON f.order_date = d.order_date
GROUP BY d.year, d.quarter
ORDER BY d.year, d.quarter;
