# Life Expectancy Prediction Model

## 📌 Project Overview
This project focuses on predicting the **life expectancy** of populations across different countries using a variety of socio-economic and health-related indicators. The goal is to help public-health organizations and NGOs prioritize interventions (e.g., immunization campaigns, schooling investment, HIV/AIDS programs) in regions where life expectancy is projected to be the lowest.

## 📊 Dataset
- **Source:** WHO Life Expectancy Dataset (Kaggle)
- **Period:** 2000–2015
- **Coverage:** 193 countries (2,938 records)
- **Target Variable:** `Life expectancy` (continuous, in years)

## 🚀 What We Have Done So Far

### 1. Data Cleaning & Feature Engineering
- **Missing Values:** Dropped rows missing the target variable and imputed remaining missing features using column medians.
- **Categorical Data:** Converted the `Status` column to numeric (Developed = 0, Developing = 1) via `LabelEncoder`.
- **Feature Selection:** Dropped the high-cardinality `Country` column as it is not suitable for direct regression without complex target encoding.

### 2. Exploratory Data Analysis (EDA)
- Generated **Correlation Heatmaps** to identify strong predictors (e.g., `Schooling` +0.75, `Income composition` +0.72, `Adult Mortality` -0.70).
- Created **Target Distribution Distributions** comparing Developed vs. Developing nations, heavily illustrating the variance in life expectancies.
- Visualized **Scatter Plots** and **Histograms** for key features to understand linear trends and data distributions.

### 3. Model Training & Evaluation
We split the data appropriately (80% Train, 20% Test) and standardized features using `StandardScaler`. We then trained and evaluated three different regressors:
1. **Linear Regression** (using Gradient Descent / SGDRegressor)
2. **Decision Tree Regressor**
3. **Random Forest Regressor** (Best Performing Model)

Visualized "Before vs. After" predictions and traced epoch/depth loss curves for each model to identify the strengths and boundaries of each algorithm.

### 4. Model Export & Standalone Prediction
- Exported the best performing model (`best_model.pkl`), feature scaler (`scaler.pkl`), and feature column names (`feature_names.pkl`) using `joblib`.
- Created a **Prediction Script** snippet capable of dynamically loading these artifacts and predicting a country's life expectancy based on a dictionary input of its conditions.

## 🛠️ Getting Started / Usage

To use the pre-trained model for predictions, load the packaged `.pkl` files and input an array aligned with the training features:

```python
import numpy as np
import joblib

# Load saved artifacts
model = joblib.load('best_model.pkl')
scaler = joblib.load('scaler.pkl')
feature_names = joblib.load('feature_names.pkl')

def predict_life_expectancy(input_dict: dict) -> float:
    features = np.array([[input_dict[f] for f in feature_names]])
    features_scaled = scaler.transform(features)
    return round(model.predict(features_scaled)[0], 2)
```
