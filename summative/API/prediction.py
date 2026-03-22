# ==============================================================================
#  Life Expectancy Prediction API – FastAPI
#  Serves the best-performing model from Task 1 (Random Forest / SGD / DT)
# ==============================================================================

import io
import os
import warnings

import joblib
import numpy as np
import pandas as pd
from fastapi import FastAPI, File, HTTPException, UploadFile
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel, Field
from sklearn.ensemble import RandomForestRegressor
from sklearn.linear_model import SGDRegressor
from sklearn.metrics import mean_absolute_error, mean_squared_error, r2_score
from sklearn.model_selection import train_test_split
from sklearn.preprocessing import LabelEncoder, StandardScaler
from sklearn.tree import DecisionTreeRegressor

warnings.filterwarnings("ignore")

# ── App Initialization ────────────────────────────────────────────────────────
app = FastAPI(
    title="Life Expectancy Prediction API",
    description=(
        "Predict life expectancy using socio-economic and health indicators. "
        "Built on the WHO Life Expectancy dataset with Random Forest, "
        "Decision Tree, and Linear Regression (SGD) models."
    ),
    version="1.0.0",
)

# ── CORS Middleware – Specific, NOT generic allow_origins=["*"] ────────────────
# Whitelisted origins for the frontend / Swagger UI / local dev environments
allowed_origins = [
    "https://life-expectancy-frontend.onrender.com",
    "https://life-expectancy-api.onrender.com",
    "http://localhost:3000",
    "http://localhost:5173",
    "http://localhost:8080",
    "http://127.0.0.1:8000",
]

app.add_middleware(
    CORSMiddleware,
    allow_origins=allowed_origins,                     # ← explicit origins list
    allow_credentials=True,                            # ← cookies / auth headers
    allow_methods=["GET", "POST", "PUT", "DELETE"],    # ← explicit methods
    allow_headers=[                                    # ← explicit headers
        "Content-Type",
        "Authorization",
        "Accept",
        "X-Requested-With",
    ],
)

# ── Paths for saved artefacts ─────────────────────────────────────────────────
MODEL_DIR = os.path.dirname(os.path.abspath(__file__))
MODEL_PATH = os.path.join(MODEL_DIR, "best_model.pkl")
SCALER_PATH = os.path.join(MODEL_DIR, "scaler.pkl")
FEATURES_PATH = os.path.join(MODEL_DIR, "feature_names.pkl")


# ── Helpers to load / reload artefacts ────────────────────────────────────────
def load_artefacts():
    """Load model, scaler, and feature names from disk."""
    model = joblib.load(MODEL_PATH)
    scaler = joblib.load(SCALER_PATH)
    feature_names = joblib.load(FEATURES_PATH)
    return model, scaler, feature_names


model, scaler, feature_names = load_artefacts()


# ── Pydantic Request / Response Schemas ───────────────────────────────────────
class LifeExpectancyInput(BaseModel):
    """
    Input schema with enforced data types **and realistic range constraints**
    derived from the WHO Life Expectancy dataset.
    """

    Year: int = Field(
        ..., ge=2000, le=2030,
        description="Calendar year (2000–2030)",
        json_schema_extra={"example": 2014},
    )
    Status: int = Field(
        ..., ge=0, le=1,
        description="Country development status: 0 = Developed, 1 = Developing",
        json_schema_extra={"example": 1},
    )
    Adult_Mortality: float = Field(
        ..., ge=0, le=1000, alias="Adult Mortality",
        description="Adult mortality rate per 1 000 population (both sexes, 15–60 yrs)",
        json_schema_extra={"example": 180.0},
    )
    infant_deaths: int = Field(
        ..., ge=0, le=2000,
        description="Number of infant deaths per 1 000 population",
        json_schema_extra={"example": 25},
    )
    Alcohol: float = Field(
        ..., ge=0.0, le=20.0,
        description="Recorded per-capita alcohol consumption (litres, 15+ yrs)",
        json_schema_extra={"example": 3.5},
    )
    percentage_expenditure: float = Field(
        ..., ge=0.0, le=25000.0, alias="percentage expenditure",
        description="Health expenditure as a percentage of GDP per capita",
        json_schema_extra={"example": 150.0},
    )
    Hepatitis_B: float = Field(
        ..., ge=0, le=100, alias="Hepatitis B",
        description="Hepatitis B immunisation coverage among 1-year-olds (%)",
        json_schema_extra={"example": 80.0},
    )
    Measles: int = Field(
        ..., ge=0, le=250000,
        description="Number of reported Measles cases per 1 000 population",
        json_schema_extra={"example": 300},
    )
    BMI: float = Field(
        ..., ge=0.0, le=100.0,
        description="Average Body Mass Index of entire population",
        json_schema_extra={"example": 35.0},
    )
    under_five_deaths: int = Field(
        ..., ge=0, le=3000, alias="under-five deaths",
        description="Number of under-five deaths per 1 000 population",
        json_schema_extra={"example": 35},
    )
    Polio: float = Field(
        ..., ge=0, le=100,
        description="Polio immunisation coverage among 1-year-olds (%)",
        json_schema_extra={"example": 82.0},
    )
    Total_expenditure: float = Field(
        ..., ge=0.0, le=20.0, alias="Total expenditure",
        description="Government health expenditure as % of total government expenditure",
        json_schema_extra={"example": 5.5},
    )
    Diphtheria: float = Field(
        ..., ge=0, le=100,
        description="DTP3 immunisation coverage among 1-year-olds (%)",
        json_schema_extra={"example": 82.0},
    )
    HIV_AIDS: float = Field(
        ..., ge=0.0, le=60.0, alias="HIV/AIDS",
        description="Deaths per 1 000 live births due to HIV/AIDS (0–4 yrs)",
        json_schema_extra={"example": 1.2},
    )
    GDP: float = Field(
        ..., ge=0.0, le=150000.0,
        description="Gross Domestic Product per capita (USD)",
        json_schema_extra={"example": 2500.0},
    )
    Population: float = Field(
        ..., ge=0.0, le=2_000_000_000,
        description="Population of the country",
        json_schema_extra={"example": 15000000.0},
    )
    thinness_1_19_years: float = Field(
        ..., ge=0.0, le=50.0, alias="thinness  1-19 years",
        description="Prevalence of thinness among 10–19 year olds (%)",
        json_schema_extra={"example": 6.0},
    )
    thinness_5_9_years: float = Field(
        ..., ge=0.0, le=50.0, alias="thinness 5-9 years",
        description="Prevalence of thinness among 5–9 year olds (%)",
        json_schema_extra={"example": 6.5},
    )
    Income_composition_of_resources: float = Field(
        ..., ge=0.0, le=1.0, alias="Income composition of resources",
        description="Human Development Index – income composition (0–1)",
        json_schema_extra={"example": 0.55},
    )
    Schooling: float = Field(
        ..., ge=0.0, le=25.0,
        description="Number of years of schooling",
        json_schema_extra={"example": 10.5},
    )

    model_config = {"populate_by_name": True}


class PredictionResponse(BaseModel):
    predicted_life_expectancy: float = Field(
        ..., description="Predicted life expectancy in years"
    )
    model_used: str = Field(
        ..., description="Name of the model that produced the prediction"
    )


class RetrainResponse(BaseModel):
    message: str
    best_model: str
    metrics: dict


# ── Utility ───────────────────────────────────────────────────────────────────
def _model_display_name(mdl) -> str:
    """Return a human-friendly name for the loaded model object."""
    name = type(mdl).__name__
    mapping = {
        "RandomForestRegressor": "Random Forest",
        "DecisionTreeRegressor": "Decision Tree",
        "SGDRegressor": "Linear Regression (SGD)",
    }
    return mapping.get(name, name)


# ── Routes ────────────────────────────────────────────────────────────────────
@app.get("/", tags=["Health"])
def root():
    """Health-check endpoint."""
    return {
        "status": "healthy",
        "model_loaded": _model_display_name(model),
        "features_expected": feature_names,
    }


@app.post(
    "/predict",
    response_model=PredictionResponse,
    tags=["Prediction"],
    summary="Predict life expectancy for a single observation",
)
def predict(data: LifeExpectancyInput):
    """
    Accepts a JSON body with 20 health / socio-economic features and returns
    the predicted life expectancy in years.
    """
    global model, scaler, feature_names

    # Build dict keyed exactly as the training features
    input_dict = {
        "Year": data.Year,
        "Status": data.Status,
        "Adult Mortality": data.Adult_Mortality,
        "infant deaths": data.infant_deaths,
        "Alcohol": data.Alcohol,
        "percentage expenditure": data.percentage_expenditure,
        "Hepatitis B": data.Hepatitis_B,
        "Measles": data.Measles,
        "BMI": data.BMI,
        "under-five deaths": data.under_five_deaths,
        "Polio": data.Polio,
        "Total expenditure": data.Total_expenditure,
        "Diphtheria": data.Diphtheria,
        "HIV/AIDS": data.HIV_AIDS,
        "GDP": data.GDP,
        "Population": data.Population,
        "thinness  1-19 years": data.thinness_1_19_years,
        "thinness 5-9 years": data.thinness_5_9_years,
        "Income composition of resources": data.Income_composition_of_resources,
        "Schooling": data.Schooling,
    }

    features_df = pd.DataFrame([input_dict], columns=feature_names)
    features_scaled = scaler.transform(features_df)
    prediction = float(model.predict(features_scaled)[0])

    return PredictionResponse(
        predicted_life_expectancy=round(prediction, 2),
        model_used=_model_display_name(model),
    )


@app.post(
    "/retrain",
    response_model=RetrainResponse,
    tags=["Retraining"],
    summary="Upload new CSV data to retrain all three models and persist the best",
)
async def retrain(file: UploadFile = File(..., description="CSV file with WHO Life Expectancy columns")):
    """
    Accepts a CSV upload identical in schema to the WHO Life Expectancy Data.
    Re-runs the full training pipeline (Linear Regression via SGD, Decision Tree,
    Random Forest), picks the best model by MSE, and saves it to disk.
    """
    global model, scaler, feature_names

    # ── 1. Read & validate the uploaded CSV ───────────────────────────────
    if not file.filename.endswith(".csv"):
        raise HTTPException(status_code=400, detail="Only .csv files are accepted.")

    contents = await file.read()
    try:
        df = pd.read_csv(io.BytesIO(contents))
    except Exception as exc:
        raise HTTPException(status_code=400, detail=f"Could not parse CSV: {exc}")

    df.columns = df.columns.str.strip()

    if "Life expectancy" not in df.columns:
        raise HTTPException(
            status_code=400,
            detail="CSV must contain a 'Life expectancy' target column.",
        )

    # ── 2. Clean & feature-engineer (mirrors Task 1 pipeline) ─────────────
    df.dropna(subset=["Life expectancy"], inplace=True)

    if "Country" in df.columns:
        df.drop(columns=["Country"], inplace=True)

    if "Status" in df.columns and df["Status"].dtype == object:
        le = LabelEncoder()
        df["Status"] = le.fit_transform(df["Status"])

    for col in df.select_dtypes(include="number").columns:
        df[col].fillna(df[col].median(), inplace=True)

    X = df.drop(columns=["Life expectancy"])
    y = df["Life expectancy"]

    X_train, X_test, y_train, y_test = train_test_split(
        X, y, test_size=0.2, random_state=42
    )

    new_scaler = StandardScaler()
    X_train_scaled = new_scaler.fit_transform(X_train)
    X_test_scaled = new_scaler.transform(X_test)

    # ── 3. Train all three models ─────────────────────────────────────────
    # Linear Regression (SGD)
    sgd = SGDRegressor(
        loss="squared_error",
        max_iter=300,
        learning_rate="invscaling",
        eta0=0.001,
        random_state=42,
        penalty="l2",
        alpha=0.0001,
    )
    sgd.fit(X_train_scaled, y_train)

    # Decision Tree
    dt = DecisionTreeRegressor(random_state=42, max_depth=10, min_samples_leaf=5)
    dt.fit(X_train_scaled, y_train)

    # Random Forest
    rf = RandomForestRegressor(
        n_estimators=200, max_depth=15, min_samples_leaf=3,
        random_state=42, n_jobs=-1,
    )
    rf.fit(X_train_scaled, y_train)

    # ── 4. Evaluate & pick the best ───────────────────────────────────────
    results = {}
    for name, mdl in [
        ("Linear Regression (SGD)", sgd),
        ("Decision Tree", dt),
        ("Random Forest", rf),
    ]:
        preds = mdl.predict(X_test_scaled)
        results[name] = {
            "MSE": round(float(mean_squared_error(y_test, preds)), 4),
            "MAE": round(float(mean_absolute_error(y_test, preds)), 4),
            "R2": round(float(r2_score(y_test, preds)), 4),
            "model_obj": mdl,
        }

    best_name = min(results, key=lambda k: results[k]["MSE"])
    best_mdl = results[best_name].pop("model_obj")

    # Remove model objects from metrics dict before returning
    for v in results.values():
        v.pop("model_obj", None)

    # ── 5. Persist new artefacts ──────────────────────────────────────────
    joblib.dump(best_mdl, MODEL_PATH)
    joblib.dump(new_scaler, SCALER_PATH)
    joblib.dump(list(X.columns), FEATURES_PATH)

    # Reload into memory
    model, scaler, feature_names = load_artefacts()

    return RetrainResponse(
        message="Retraining complete. Best model saved and loaded.",
        best_model=best_name,
        metrics=results,
    )