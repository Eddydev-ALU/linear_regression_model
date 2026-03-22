# ============================================================
#  predict.py – Standalone prediction script
#  Loads the best model saved in Task 1 and returns a prediction
# ============================================================

import numpy as np
import pandas as pd
import joblib


def predict_life_expectancy(input_dict: dict) -> float:
    """
    Predict life expectancy given a dictionary of feature values.
    """
    model = joblib.load("best_model.pkl")
    scaler = joblib.load("scaler.pkl")
    feature_names = joblib.load("feature_names.pkl")

    features_df = pd.DataFrame([input_dict], columns=feature_names)
    features_scaled = scaler.transform(features_df)
    return round(float(model.predict(features_scaled)[0]), 2)


if __name__ == "__main__":
    sample = {
        "Year": 2014,
        "Status": 1,
        "Adult Mortality": 180,
        "infant deaths": 25,
        "Alcohol": 3.5,
        "percentage expenditure": 150.0,
        "Hepatitis B": 80,
        "Measles": 300,
        "BMI": 35.0,
        "under-five deaths": 35,
        "Polio": 82,
        "Total expenditure": 5.5,
        "Diphtheria": 82,
        "HIV/AIDS": 1.2,
        "GDP": 2500.0,
        "Population": 15000000,
        "thinness  1-19 years": 6.0,
        "thinness 5-9 years": 6.5,
        "Income composition of resources": 0.55,
        "Schooling": 10.5,
    }

    predicted = predict_life_expectancy(sample)
    print(f">>> Predicted Life Expectancy: {predicted} years <<<")