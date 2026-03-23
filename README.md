# Life Expectancy Prediction Ecosystem

## Mission & Problem Statement
**Problem:** Public health organizations need data-driven ways to prioritize resource allocation effectively to improve global health outcomes.  
**Mission:** To leverage machine learning to identify the key socio-economic and health factors that most significantly impact life expectancy across nations. This enables public-health organizations and policymakers — particularly in developing countries — to make data-driven decisions about where to allocate resources (immunization programs, education investment, HIV/AIDS intervention, and nutrition initiatives) for the greatest improvement in population health outcomes.

## Repository Structure & Ecosystem
This repository has grown from a simple Machine Learning model into a complete, full-stack predictive ecosystem.

It consists of three main components contained within the `summative/` directory:

1. **Machine Learning Model (`summative/linear_regression/`)**
   - The original Jupyter Notebook where data cleaning, exploratory data analysis (EDA), and model training occurred.
   - Evaluated Random Forest, Decision Trees, and Linear Regression (SGD).

2. **FastAPI Backend (`summative/API/`)**
   - A REST API built with FastAPI that serves the exported `best_model.pkl`.
   - Includes data validation via Pydantic and endpoints for both generating predictions and retraining the model on new data.
   - Designed to be easily containerized and deployed on platforms like Render (`render.yaml` included).

3. **Flutter Mobile App (`summative/FlutterApp/life_expectancy_predictor/`)**
   - A modern, cross-platform mobile application built with Flutter.
   - Provides an intuitive, scrollable user interface where users can input socio-economic factors.
   - Connects to the FastAPI backend over HTTP to retrieve real-time life expectancy predictions.
   - Features input validation, API error handling, and a sample data autoloader (e.g., Rwanda 2014 data).

---

## What We Have Done So Far

### 1. Data Cleaning & Feature Engineering (ML Phase)
- **Missing Values:** Dropped rows missing the target variable and imputed remaining missing features using column medians.
- **Categorical Data:** Converted the `Status` column to numeric (Developed = 0, Developing = 1) via `LabelEncoder`.
- **Feature Selection:** Dropped the high-cardinality `Country` column as it is not suitable for direct regression without complex target encoding.

### 2. Exploratory Data Analysis (EDA)
- Identified strong positive correlations between Life Expectancy and `Schooling`, `Income composition of resources`, and `BMI`.
- Identified stark negative correlations with `Adult Mortality` and `HIV/AIDS`.

### 3. Model Training & Selection
- Tested SGDRegressor, DecisionTreeRegressor, and RandomForestRegressor.
- Selected **Random Forest** as the best performing model.
- Exported the model (`best_model.pkl`), feature names (`feature_names.pkl`), and StandardScaler (`scaler.pkl`) for production use.

### 4. API Development & Deployment
- Created a robust FastAPI wrapper (`prediction.py`) around our pickled machine learning model.
- Secured the API with CORS origin whitelisting.
- Deployed to **Render** using a custom `render.yaml` ensuring specific Python and pip versions to handle heavy ML libraries gracefully.

### 5. Flutter App Development
- Built `life_expectancy_predictor` featuring a clean, Material 3 compliant UI.
- Implemented robust error catching and field insights that dismiss gracefully when clicking outside of input fields.
- Integrated `http` packages to construct POST requests matching the FastAPI Pydantic schemas.

---

## How to Run the Project Locally

### 1. Running the FastAPI Backend
```bash
cd summative/API
python -m venv .venv
source .venv/bin/activate  # On Windows use: .venv\Scripts\activate
pip install -r requirements.txt
python -m uvicorn prediction:app --reload --port 8000
```
*The API will be available at `http://127.0.0.1:8000/docs`*

### 2. Running the Flutter App
Ensure you have the Flutter SDK installed and a simulator or device connected.
```bash
cd summative/FlutterApp/life_expectancy_predictor
flutter pub get
flutter run
```
*Note: Depending on your local setup, you may need to point the Flutter app to `10.0.2.2:8000` (for Android emulators) or `localhost:8000` (for iOS simulators) inside the application's API service.*
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

## Getting Started / Usage

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