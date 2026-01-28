
from fastapi import FastAPI, File, UploadFile, HTTPException
import uvicorn
import shutil
import os
import json
import tensorflow as tf
import numpy as np
from preprocess import create_spectrogram, preprocess_for_model


from contextlib import asynccontextmanager
import sys

# ... imports ...

# Global variables for model
model = None
MODEL_PATH = "final_cough_model.keras" # It's in the same folder if we run from backend/ ? No, user said ../ 
# Wait, user file structure:
# backend/main.py
# final_cough_model.keras is in PROJECT ROOT (Datuk/) based on list_dir
# So backend/../final_cough_model.keras is correct relative to main.py?
# backend/main.py -> dirname is backend/.  ../ is Datuk/
# YES.


# Constants
THRESHOLD = 0.6
# Mappings from datuk.ipynb: 
# label = 1 if row['cough_type_4'] == 'wet' else 0
# 0: Dry (Batuk kering)
# 1: Wet (Batuk berdahak)
LABELS = {
    0: "Batuk kering",
    1: "Batuk berdahak"
}


# Medicine Database (Simulated RAG)
MEDICINES = {}

@asynccontextmanager
async def lifespan(app: FastAPI):
    global model, MEDICINES
    try:
        base_dir = os.path.dirname(os.path.abspath(__file__))
        
        # Load Medicines
        json_path = os.path.join(base_dir, "data", "medicines.json")
        if os.path.exists(json_path):
             with open(json_path, 'r') as f:
                 MEDICINES = json.load(f)
             print(f"Medicines loaded: {len(MEDICINES)} categories", file=sys.stderr)
        else:
             print("Warning: medicines.json not found!", file=sys.stderr)

        # Go up one level to find the model
        project_root = os.path.dirname(base_dir) # d:\APLAI\project UAS\Datuk
        original_model_path = os.path.join(project_root, "final_cough_model.keras")
        
        load_path = original_model_path
        
        # Check if it's a directory (unzipped Keras model)
        if os.path.isdir(original_model_path):
            print(f"Model is a directory: {original_model_path}", file=sys.stderr)
            temp_zip_path = os.path.join(base_dir, "temp_model_zipped.keras")
            
            # Use existing if available to save time? Or overwrite to be safe?
            # Creating zip...
            if not os.path.exists(temp_zip_path):
                print("Zipping model to temporary file...", file=sys.stderr)
                zip_base = os.path.join(base_dir, "temp_model_zipped")
                shutil.make_archive(zip_base, 'zip', original_model_path)
                os.rename(zip_base + ".zip", temp_zip_path)
            
            load_path = temp_zip_path
            print(f"Using zipped model: {load_path}", file=sys.stderr)

        print(f"Loading model from {load_path}...", file=sys.stderr)
        model = tf.keras.models.load_model(load_path)
        print("Model loaded successfully!", file=sys.stderr)
    except Exception as e:
        print(f"Failed to load model or data: {e}", file=sys.stderr)
        import traceback
        traceback.print_exc()
    
    yield
    
    # Clean up if needed
    model = None


def analyze_severity(confidence):
    """
    Heuristic analysis of severity based on model confidence.
    """
    if confidence > 0.90:
        return "Tingkat Lanjut (Indikasi Kuat)"
    elif confidence > 0.70:
        return "Sedang"
    else:
        return "Ringan (Indikasi Lemah)"

app = FastAPI(lifespan=lifespan)

# ... rest of code ...


@app.post("/predict")
async def predict_cough(file: UploadFile = File(...)):
    if not model:
        raise HTTPException(status_code=503, detail="Model not loaded")
    
    if not file.filename:
         raise HTTPException(status_code=400, detail="Empty filename")

    # Save temp file
    temp_filename = f"temp_{file.filename}"
    temp_dir = "temp_uploads"
    os.makedirs(temp_dir, exist_ok=True)
    temp_path = os.path.join(temp_dir, temp_filename)
    
    try:
        with open(temp_path, "wb") as buffer:
            shutil.copyfileobj(file.file, buffer)
            
        # Preprocessing
        print(f"Processing {file.filename}...")
        spectrogram_img = create_spectrogram(temp_path)
        if spectrogram_img is None:
             raise HTTPException(status_code=400, detail="Could not process audio file (Spectrogram generation failed)")
             
        input_data = preprocess_for_model(spectrogram_img)
        
        # Inference
        # Output is sigmoid (0-1), probability of class 1 (Wet)
        prediction = model.predict(input_data)
        score_wet = float(prediction[0][0])
         
        # Decision Logic
        predicted_class_id = 1 if score_wet > THRESHOLD else 0
        label = LABELS[predicted_class_id]
        
        # Confidence calculation
        confidence = score_wet if predicted_class_id == 1 else (1.0 - score_wet)
        
        # Analysis Level
        level = analyze_severity(confidence)
        
        # RAG / Recommendation Logic
        recommendations = MEDICINES.get(label, [])
        
        return {
            "status": "success",
            "file": file.filename,
            "prediction": label,
            "confidence": confidence,
            "analysis": level,
            "score_wet": score_wet,
            "threshold_used": THRESHOLD,
            "recommendations": recommendations,
            "message": "Klasifikasi berhasil."
        }
        
    except Exception as e:
        import traceback
        traceback.print_exc()
        raise HTTPException(status_code=500, detail=f"Internal Error: {str(e)}")
        
    finally:
        # Cleanup
        if os.path.exists(temp_path):
            try:
                os.remove(temp_path)
            except:
                pass

if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=8000)

