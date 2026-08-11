{{ config(materialized='view') }}--createsa view not a table as it eat storage[as no transformation is done]see the syntax

SELECT *
FROM {{ ref('ecommerce_sales') }}--referenced as already have that data

--do docker compose run --rm dbt run --project-dir <project name>[dbt_project or /usr/app/dbt_project]

--connect to  postgres db by -:docker exec -it <container-name[of db not dbt]> psql -U <${POSTGRES_USER}[actual one]>  -d <${POSTGRES_DB}[here dbt_ecom_warehouse the]>

--check errors like -:
--Select * from analytics.ecommerce_sales where customer_id is null limit 10;
--Select count(*) from analytics.ecommerce_sales where quantity <0 limit 10;
--Select count(*) from analytics.ecommerce_sales where price <0 limit 10;
--Select count(*) from analytics.ecommerce_sales where cast(order_date as date)>current_date limit 10; -- convert string->date
--Select count(*) from analytics.ecommerce_sales where country not in ('US', 'UK', 'IN', 'DE', 'FR', 'CA', 'AU') limit 10;
--select transaction_id,count(*) from analytics.ecommerce_sales group by transaction_id having count(*)>1;


