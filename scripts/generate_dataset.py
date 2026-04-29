import pandas as pd
import random
from datetime import datetime, timedelta
from pathlib import Path

Path("datasets").mkdir(exist_ok=True)

categories = [
    (1, "Laptop"),
    (2, "Mobile"),
    (3, "Accessories"),
    (4, "Network Device"),
    (5, "Software")
]

products = [
    (1, "Dell Latitude", 1, 850),
    (2, "HP EliteBook", 1, 900),
    (3, "Lenovo ThinkPad", 1, 880),
    (4, "iPhone", 2, 999),
    (5, "Samsung Galaxy", 2, 799),
    (6, "Mouse", 3, 20),
    (7, "Keyboard", 3, 35),
    (8, "Cisco Switch", 4, 1200),
    (9, "FortiGate Firewall", 4, 2500),
    (10, "Microsoft License", 5, 300)
]

regions = [
    (1, "Phnom Penh", "Cambodia"),
    (2, "Siem Reap", "Cambodia"),
    (3, "Battambang", "Cambodia"),
    (4, "Sihanoukville", "Cambodia"),
    (5, "Kampong Cham", "Cambodia")
]

sales = []
start_date = datetime(2025, 1, 1)

for order_id in range(1, 1501):
    product = random.choice(products)
    region = random.choice(regions)
    quantity = random.randint(1, 20)
    unit_price = product[3]
    sales_amount = quantity * unit_price
    order_date = start_date + timedelta(days=random.randint(0, 364))

    sales.append([
        order_id,
        order_date.strftime("%Y-%m-%d"),
        product[0],
        region[0],
        quantity,
        unit_price,
        sales_amount
    ])

pd.DataFrame(categories, columns=["category_id", "category_name"]).to_csv("datasets/categories.csv", index=False)
pd.DataFrame(products, columns=["product_id", "product_name", "category_id", "unit_price"]).to_csv("datasets/products.csv", index=False)
pd.DataFrame(regions, columns=["region_id", "region_name", "country"]).to_csv("datasets/regions.csv", index=False)
pd.DataFrame(
    sales,
    columns=["order_id", "order_date", "product_id", "region_id", "quantity", "unit_price", "sales_amount"]
).to_csv("datasets/sales_orders.csv", index=False)

print("Dataset generated successfully: 1500 sales records")