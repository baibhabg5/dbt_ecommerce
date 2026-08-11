{{ config(materialized='table') }}

select distinct
    product_id,
    product_category
from {{ ref('silver') }}