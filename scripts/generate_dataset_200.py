import pandas as pd

# Load your large dataset
df = pd.read_csv("sales_transactions_1000000.csv")

# Sample 200 rows
df_200 = df.sample(n=200, random_state=42)

# Save new dataset
df_200.to_csv("sales_transactions_200.csv", index=False)

print("✅ Generated sales_transactions_200.csv")