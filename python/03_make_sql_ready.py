# ============================================
# Make a MySQL-friendly CSV (simple column names)
# Run from the project root folder:  python python/03_make_sql_ready.py
# ============================================

import pandas as pd

# ---------- STEP 1: Load the cleaned data ----------
df = pd.read_csv("data/cleaned/zomato_cleaned_simple.csv")

# ---------- STEP 2: Rename columns ----------
# Lowercase and replace spaces with underscores, e.g. "Restaurant Name" -> "restaurant_name"
df.columns = df.columns.str.lower().str.replace(" ", "_")

# One name is long, so we shorten it by hand
df = df.rename(columns={"average_cost_for_two": "avg_cost_for_two"})

print(df.columns.tolist())

# ---------- STEP 3: Save ----------
df.to_csv("data/sql/zomato_sql_ready.csv", index=False)
print("Saved:", df.shape)
