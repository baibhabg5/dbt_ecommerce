{{ config(materialized='view') }}

SELECT *
FROM {{ ref('exchange_rates') }}