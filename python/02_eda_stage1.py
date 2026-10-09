# ============================================
# Zomato EDA - Stage 1: Understand each column
# Run from the project root folder:  python python/02_eda_stage1.py
# ============================================

import pandas as pd
import matplotlib.pyplot as plt

# ---------- STEP 1: Load the cleaned data ----------
df = pd.read_csv("data/cleaned/zomato_cleaned_simple.csv")
print("All countries:", df.shape)

# ---------- STEP 2: Restaurants per country ----------
country_counts = df["Country"].value_counts()
print(country_counts)

country_counts.plot(kind="bar", figsize=(10, 5), color="tomato")
plt.title("Number of Restaurants by Country")
plt.xlabel("Country")
plt.ylabel("Restaurants")
plt.show()

# ---------- STEP 3: Keep only India ----------
# India has most of the data and uses one currency (Rupees)
india = df[df["Country"] == "India"]
print("India only:", india.shape)

# ---------- STEP 4: Top 10 cities in India ----------
top_cities = india["City"].value_counts().head(10)
print(top_cities)

top_cities.plot(kind="bar", figsize=(10, 5), color="orange")
plt.title("Top 10 Indian Cities by Number of Restaurants")
plt.xlabel("City")
plt.ylabel("Restaurants")
plt.show()

# ---------- STEP 5: Rating distribution ----------
# We use "Rating Clean" so the 'Not rated' restaurants are left out
print("Rated restaurants:", india["Rating Clean"].notnull().sum())
print("Not rated restaurants:", india["Rating Clean"].isnull().sum())
print(india["Rating Clean"].describe())

plt.figure(figsize=(8, 5))
plt.hist(india["Rating Clean"].dropna(), bins=20, color="green", edgecolor="black")
plt.title("Rating Distribution (India, rated restaurants)")
plt.xlabel("Rating")
plt.ylabel("Number of Restaurants")
plt.show()

# ---------- STEP 6: Price range ----------
price_counts = india["Price range"].value_counts().sort_index()
print(price_counts)

price_counts.plot(kind="bar", figsize=(8, 5), color="purple")
plt.title("Restaurants by Price Range (1 = cheapest, 4 = most expensive)")
plt.xlabel("Price range")
plt.ylabel("Restaurants")
plt.xticks(rotation=0)
plt.show()

# ---------- STEP 7: Top 10 cuisines ----------
# Cuisines look like "North Indian, Chinese" (many in one cell)
# 1) split the text into a list, 2) give each cuisine its own row
cuisine_list = india["Cuisines"].str.split(", ")
all_cuisines = cuisine_list.explode()

top_cuisines = all_cuisines.value_counts().head(10)
print(top_cuisines)

top_cuisines.plot(kind="barh", figsize=(8, 6), color="teal")
plt.title("Top 10 Cuisines in India")
plt.xlabel("Number of Restaurants")
plt.gca().invert_yaxis()   # biggest bar on top
plt.show()
