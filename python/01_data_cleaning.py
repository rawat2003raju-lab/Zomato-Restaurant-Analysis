# ============================================
# Zomato Dataset - Data Cleaning (Beginner)
# Run from the project root folder:  python python/01_data_cleaning.py
# ============================================

import pandas as pd
import numpy as np

# ---------- STEP 1: Load the data ----------
df = pd.read_csv("data/raw/Zomato_Restaurant_Dataset.csv")

print("Rows and columns:", df.shape)
print(df.head())

# ---------- STEP 2: Look at the data ----------
print(df.info())                 # column names, data types, non-null counts
print(df.isnull().sum())         # missing values in each column
print("Duplicate rows:", df.duplicated().sum())

# ---------- STEP 3: Fix missing Cuisines ----------
# Only 9 rows are missing, so we fill them with "Unknown"
df["Cuisines"] = df["Cuisines"].fillna("Unknown")

# ---------- STEP 4: Remove extra spaces ----------
df["Locality"] = df["Locality"].str.strip()

# ---------- STEP 5: Drop a useless column ----------
# "Switch to order menu" is "No" in every row, so it tells us nothing
df = df.drop(columns=["Switch to order menu"])

# ---------- STEP 6: Fix wrong currency labels ----------
# Philippines (Country Code 162) was labelled "Botswana Pula"
df.loc[df["Country Code"] == 162, "Currency"] = "Philippine Peso(PHP)"

# The pound sign is broken in the file, so fix the label
df.loc[df["Currency"].str.startswith("Pounds"), "Currency"] = "Pounds(GBP)"

# ---------- STEP 7: Fix broken city names ----------
# These three names have broken characters in the original file
df.loc[df["City"].str.contains("Bras"), "City"] = "Brasilia"
df.loc[df["City"].str.contains("Paulo"), "City"] = "Sao Paulo"
df.loc[df["City"].str.contains("stanbul"), "City"] = "Istanbul"

# ---------- STEP 8: Add a Country column ----------
# The file only has country codes, so we map them to names
country_names = {
    1: "India", 14: "Australia", 30: "Brazil", 37: "Canada",
    94: "Indonesia", 148: "New Zealand", 162: "Philippines",
    166: "Qatar", 184: "Singapore", 189: "South Africa",
    191: "Sri Lanka", 208: "Turkey", 214: "UAE",
    215: "United Kingdom", 216: "United States",
}
df["Country"] = df["Country Code"].map(country_names)

# ---------- STEP 9: Handle rating = 0 ----------
# A rating of 0 means "Not rated", it is NOT a bad score.
# We make a new column where 0 becomes NaN (missing).
df["Rating Clean"] = df["Aggregate rating"].replace(0, np.nan)

# ---------- STEP 10: Handle cost = 0 ----------
# A cost of 0 is not real, so treat it as missing
df["Cost Clean"] = df["Average Cost for two"].replace(0, np.nan)

# ---------- STEP 11: Handle zero coordinates ----------
# Latitude = 0 and Longitude = 0 means the location is missing
df["Latitude Clean"] = df["Latitude"].replace(0, np.nan)
df["Longitude Clean"] = df["Longitude"].replace(0, np.nan)

# ---------- STEP 12: Check the result ----------
print("Rows and columns after cleaning:", df.shape)
print(df.isnull().sum())

# ---------- STEP 13: Save the cleaned file ----------
df.to_csv("data/cleaned/zomato_cleaned_simple.csv", index=False)
print("Cleaned file saved!")
