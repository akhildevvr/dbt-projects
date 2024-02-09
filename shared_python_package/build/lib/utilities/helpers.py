# dbt_helpers/helpers.py
import pandas as pd

def generate_date_series(start_date, end_date):
    # Your implementation here
    # Convert start and end date to datetime objects
    start = pd.to_datetime(start_date)
    end = pd.to_datetime(end_date)
    
    # Generate date range
    date_range = pd.date_range(start=start, end=end)
    
    # Convert date range to list of strings in 'YYYY-MM-DD' format
    date_list = [date.strftime('%Y-%m-%d') for date in date_range]
    
    return date_list

def calculate_growth_rate(current_value, previous_value):
    # Your implementation here
    pass
