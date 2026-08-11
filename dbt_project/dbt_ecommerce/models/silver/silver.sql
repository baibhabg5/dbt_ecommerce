{{ config(materialized='table') }}--as there is actual cleaning and for gold to have faster query

WITH cleaned AS (    ----using CTEs

    SELECT
        transaction_id,
        CAST(order_date AS DATE) AS order_date,  --order_date must be converted to date from string
        customer_id,
        customer_name,
        country,
        product_id,
        product_category,
        quantity,
        price,
        payment_method,
        order_status

    FROM {{ ref('bronze_sales') }}--name of the view will be the name of the file as we get it from bronze.sql sowe referenced it
    WHERE 
    transaction_id IS NOT NULL
      AND customer_id IS NOT NULL
      AND CAST(order_date AS DATE) <= CURRENT_DATE
      AND country IN ('US','UK','IN','DE','FR','CA','AU')
      AND quantity > 0
      AND price > 0
      AND product_id IS NOT NULL
      AND product_category IS NOT NULL
      AND order_status IN ('Completed','Cancelled','Returned')
),

with_currency AS (
    SELECT
        *,CASE
            WHEN country = 'US' THEN 'USD'
            WHEN country = 'UK' THEN 'GBP'
            WHEN country = 'IN' THEN 'INR'
            WHEN country IN ('DE', 'FR') THEN 'EUR' --same currency is used in both Germany AND France
            WHEN country = 'CA' THEN 'CAD'
            WHEN country = 'AU' THEN 'AUD'
        END AS currency
    FROM cleaned
),

with_exchange AS (
    SELECT
        sales.*,exchange.exchange_rate_to_inr
    FROM with_currency sales

    LEFT JOIN {{ ref('bronze_exchange_rates') }} exchange
        ON sales.currency = exchange.currency
        AND sales.order_date = exchange.rate_date
),--comma segregates two CTEs

deduplicated AS (
    SELECT
        *, ROW_NUMBER() OVER (  
            PARTITION BY transaction_id
            ORDER BY order_date DESC                --latest/youngest date will come on top
        ) AS row_number
    FROM with_exchange
)

SELECT
    transaction_id,
    order_date,
    customer_id,
    customer_name,
    country,
    currency,
    exchange_rate_to_inr,
    product_id,
    product_category,
    quantity,
    price,
    -- Local transaction value
    ROUND((price * quantity)::numeric, 2) AS transaction_amount,
    -- Standardized company revenue value
    ROUND(
    (price * quantity * exchange_rate_to_inr)::numeric,2) AS transaction_amount_inr,
    payment_method,
    order_status

FROM deduplicated
WHERE row_number = 1   --only taking the 1st of eache transaction_id[which is the youngest date]
  AND exchange_rate_to_inr IS NOT NULL  --this  is equivalent to adding inner join instead of left join[Making sure the exchange join succeeded]
 
--do docker compose run --rm dbt run --project-dir <project name>[dbt_project or /usr/app/dbt_project]

--connect to  postgres db by -:docker exec -it <container-name[of db not dbt]> psql -U <${POSTGRES_USER}[actual one]>  -d <${POSTGRES_DB}[here dbt_ecom_warehouse the]>
--# 2. Load CSVs into PostgreSQL through dbt seeds
--docker compose run --rm dbt dbt seed --project-dir /usr/app
--
--# 3. Build Bronze + Silver models
--docker compose run --rm dbt dbt run --project-dir /usr/app
--
--# 4. Enter PostgreSQL
--docker compose ps
--
--docker exec -it <db-container-name> psql \
--    -U <POSTGRES_USER> \
--    -d <POSTGRES_DB>
--\dn              [see schemas]
--\dt analytics.*  [see tables]
--\d analytics.silver_sales

--u can run the same bronze_sales queries to see if all clening is successfull or not


