from pathlib import Path
from datetime import date, timedelta
import random
import pandas as pd


def generate_fx_rates():

    currencies = {"USD": 91.0,"GBP": 119.0,"INR": 1.0,"EUR": 103.0,"CAD": 64.0,"AUD": 58.0}

    end_date = date.today()
    start_date = end_date - timedelta(days=365)

    data = []

    current_date = start_date

    while current_date <= end_date:

        for currency, base_rate in currencies.items():

            # Small daily variation for synthetic data
            if currency == "INR":
                rate = 1.0
            else:
                rate = round(base_rate * random.uniform(0.98, 1.02),2)#fake varying the dip and gain in the exchange

            data.append({
                "rate_date": current_date,
                "currency": currency,
                "exchange_rate_to_inr": rate
            })

        current_date += timedelta(days=1)#incrementing loop

    fx_df = pd.DataFrame(data)

    base_dir = Path(__file__).resolve().parent
    seed_path = (
            base_dir /"dbt_project"/"dbt_ecommerce"/ "seeds"/ "exchange_rates.csv"
        )

    fx_df.to_csv(seed_path, index=False)
    print(f"Exchange rates file generated successfully: {seed_path}")