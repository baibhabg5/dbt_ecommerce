import pandas as pd
import numpy as np
import random
#from faker import Faker
from datetime import date,datetime, timedelta
from pathlib import Path
from exchange_rates import generate_fx_rates

#fake = Faker()#to  generate fake names 

# CONFIGURATION
NUM_RECORDS = 1000000
ERROR_PERCENTAGE = 0.20   # 20% of records will contain errors

first_names = ["Aarya", "Priya", "Rohan", "Anil", "Vikram", "Neha","Rahul","Aditya","Paul","Martin"]
last_names = ["Sharma", "Verma", "Patel", "Gupta", "Das", "Iyer","Aggarwal","Chatterjee","Ghosh","Kumar"]
countries = ["US", "UK", "IN", "DE", "FR", "CA", "AU"]
categories = ["Electronics", "Clothing", "Home_Decor", "Books", "Sports","Ornaments","Packaged_Food","Skincare"]
payment_methods = ["Credit Card", "PayPal", "UPI", "Debit Card","COD"]
#currency_map = {"US": "USD","UK": "GBP","IN": "INR", "DE": "EUR","FR": "EUR","CA": "CAD","AU": "AUD"}
#exchange_rates = {"USD": 91.0,"GBP": 119.0,"INR": 1.0,"EUR": 103.0,"CAD": 64.0,"AUD": 58.0}

def generate_data():
    data = []#creates a list
    end_date = date.today()
    start_date = end_date - timedelta(days=365)
    for i in range(NUM_RECORDS):
        order_date = date.fromordinal(random.randint(start_date.toordinal(), end_date.toordinal()))#fake date between today & a year back
        quantity = random.randint(1, 5)
        price = round(random.uniform(10, 500), 2)#uniform() picks a random decimal no. from 10-500[eg 70.955,98.435]
        country = random.choice(countries)
        data.append({
            "transaction_id": f"T{i+1}",#unique transaction ID with loop variable
            "order_date": order_date,
            "customer_id": f"C{random.randint(1, 300)}",#E.g=c1,c2..c300
            "customer_name": f"{random.choice(first_names)} {random.choice(last_names)}",#produce fake name
            "country": random.choice(countries),
            "product_id": f"P{random.randint(1, 200)}",#E.g=P1,P2...P200
            "product_category": random.choice(categories),
            "quantity": quantity,
            "price": price,
            "payment_method": random.choice(payment_methods),
            "order_status": random.choice(["Completed", "Cancelled", "Returned"])
        })#list of 1M dictionaries

    df = pd.DataFrame(data)#dict to dataframe

    inject_errors(df)#ingest error in data[function defined later]
    BASE_DIR = Path(__file__).resolve().parent
    
    SEED_PATH = (
        BASE_DIR /"dbt_project"/"dbt_ecommerce"/ "seeds"/ "ecommerce_sales.csv"
    )
    df.to_csv(SEED_PATH, index=False)#csv conversion
    print(f"CSV generated successfully: {SEED_PATH}")#logging

def inject_errors(df):
    num_errors = int(len(df) * ERROR_PERCENTAGE) # 200K or 2lakhs 
    invalid_countries = ["XYZ","USA","IND","UKK","123","","Unknown"]
    for _ in range(num_errors):
        row = random.randint(0, len(df) - 1)#random integerin 1 to 1 million
        error_type = random.choice([
            "null_customer",
            "negative_quantity",
            "invalid_price",
            "future_date",
            "invalid_country",
            "duplicate_transaction"
        ])
        #used to ingest error at randon rows
        if error_type == "null_customer":
            df.at[row, "customer_id"] = None #customer_id=None as error

        elif error_type == "negative_quantity":
            df.at[row, "quantity"] = -random.randint(1, 5)#quantity cannot be -ve

        elif error_type == "invalid_price":
            df.at[row, "price"] = round(-random.uniform(1, 100),2)#price cannot be -ve

        elif error_type == "future_date":
            df.at[row, "order_date"] = datetime.now() + timedelta(days=random.randint(1,60))#delivery date is possible not order date in futurn

        elif error_type == "invalid_country":
            df.at[row, "country"] = random.choice(invalid_countries)

        elif error_type == "duplicate_transaction":
            duplicate_row = random.randint(0, len(df) - 1)
            df.at[row, "transaction_id"] = df.at[duplicate_row, "transaction_id"]#f"T{random.randint(1,1000)}"#0.1% similar transaction id but is might not work as
            #For example, if it generates T847 and T847 doesn't exist, you've just created a new transaction ID[instead of duplicating].

if __name__ == "__main__":
    generate_data()
    generate_fx_rates()


#docker compose run --rm dbt init
#then many thing to fill up about t postgres but those are mentioned in profiles.yml or u can do manually
# if done manually [in that schema will also be asked give a name for postgres]
# also threads give 3-5[tell how many parallel connections can exist at a time]
#delete eg from models for freeing storage

#then run docker compose run  --rm dbt dbt seed --project-dir <project name>[dbt_project or /usr/app/dbt_project]
#then run docker compose run  --rm dbt dbt seed --project-dir /usr/app/dbt_ecommerce[dbt_project or /usr/app/dbt_project]
   #I did not/am not supposed manually create each of those PostgreSQL table but dbt seed creates it from the CSV.
   #it keeps the name same as .csv file [ecommerce_sales.csv->ecommerce_sales]dbt generated the table schemas.

#connect to postgres db by -:docker exec -it <container-name[of db not dbt]> psql -U <${POSTGRES_USER}[actual one]>  -d <${POSTGRES_DB}[here dbt_ecom_warehouse the]>
#docker exec -it dbt_postgres psql -U bg_p  -d dbt_ecom_warehouse
   #means docker  execute and it will take u inside db
   #select * from analytics.ecommerce_sales;   [schema.table]
   #exit the db n/w connection by    \q

#to create bronze,silver,gold do it in sql in "models"

#docker compose up -d->  Containers running->   python data_generator.py ->  dbt_project/seeds/ecommerce_sales.csv-> 
#Docker volume makes it visible to dbt ->docker compose run --rm dbt dbt seed-> PostgreSQL