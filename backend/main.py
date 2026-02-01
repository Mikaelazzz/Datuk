
from fastapi import FastAPI, File, UploadFile, HTTPException, WebSocket, WebSocketDisconnect, Header, Form, Request
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
import uvicorn
import shutil
import os
import json
import tensorflow as tf
import numpy as np
from preprocess import create_spectrogram, preprocess_for_model
import database  # SQLite database module


from contextlib import asynccontextmanager
import sys
import time
from typing import List, Optional

# --- Pydantic Models ---
class UserRegister(BaseModel):
    user_id: str

# --- WebSocket Connection Manager ---
class ConnectionManager:
    def __init__(self):
        self.active_connections: List[WebSocket] = []

    async def connect(self, websocket: WebSocket):
        await websocket.accept()
        self.active_connections.append(websocket)
        print(f"WebSocket connected. Total: {len(self.active_connections)}", file=sys.stderr)

    def disconnect(self, websocket: WebSocket):
        if websocket in self.active_connections:
            self.active_connections.remove(websocket)
        print(f"WebSocket disconnected. Total: {len(self.active_connections)}", file=sys.stderr)

    async def broadcast(self, message: dict):
        """Broadcast message to all connected clients"""
        disconnected = []
        for connection in self.active_connections:
            try:
                await connection.send_json(message)
            except Exception as e:
                print(f"Error sending to client: {e}", file=sys.stderr)
                disconnected.append(connection)
        
        # Remove disconnected clients
        for conn in disconnected:
            self.disconnect(conn)

manager = ConnectionManager()

# CORS configuration for Flutter Web

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
        
        # Model file path in backend folder
        model_file_path = os.path.join(base_dir, "temp_model.keras")
        
        # --- Google Drive Download ---
        # If model doesn't exist locally, download from Google Drive
        GDRIVE_FILE_ID = "1ESTe8JzMu_rerVCgvrDJrTqcUm61AA4v"
        
        if not os.path.exists(model_file_path):
            print("Model not found locally. Downloading from Google Drive...", file=sys.stderr)
            try:
                import gdown
                gdrive_url = f"https://drive.google.com/uc?id={GDRIVE_FILE_ID}"
                gdown.download(gdrive_url, model_file_path, quiet=False)
                print(f"Model downloaded successfully to {model_file_path}", file=sys.stderr)
            except Exception as download_error:
                print(f"Failed to download model from Google Drive: {download_error}", file=sys.stderr)
                raise
        
        # Possible model locations (in order of priority)
        model_paths_to_try = [
            model_file_path,  # 1. Downloaded model in backend/
            os.path.join(base_dir, "temp_model_zipped.keras"),  # 2. Cached zip in backend/
            os.path.join(project_root, "final_cough_model.keras"),  # 3. .keras file in root
            os.path.join(project_root, "final_cough_model"),  # 4. Directory in root
        ]
        
        load_path = None
        for path in model_paths_to_try:
            if os.path.exists(path):
                if os.path.isdir(path):
                    # It's a directory, need to zip it for Keras
                    print(f"Model is a directory: {path}", file=sys.stderr)
                    temp_zip_path = os.path.join(base_dir, "temp_model_zipped.keras")
                    
                    if not os.path.exists(temp_zip_path):
                        print("Zipping model to temporary file...", file=sys.stderr)
                        zip_base = os.path.join(base_dir, "temp_model_zipped")
                        shutil.make_archive(zip_base, 'zip', path)
                        os.rename(zip_base + ".zip", temp_zip_path)
                    
                    load_path = temp_zip_path
                else:
                    load_path = path
                print(f"Found model at: {load_path}", file=sys.stderr)
                break
        
        if load_path is None:
            print("ERROR: No model file found! Checked paths:", file=sys.stderr)
            for p in model_paths_to_try:
                print(f"  - {p}", file=sys.stderr)
            raise FileNotFoundError("Model file not found")

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

# Add CORS middleware to allow Flutter Web requests
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Allow all origins for development
    allow_credentials=True,
    allow_methods=["*"],  # Allow all methods (GET, POST, etc.)
    allow_headers=["*"],  # Allow all headers
)

# --- Health Check Endpoint (for Render) ---
@app.get("/health")
async def health_check():
    """Health check endpoint for monitoring."""
    return {
        "status": "healthy",
        "model_loaded": model is not None,
        "medicines_loaded": len(MEDICINES) > 0
    }

# --- User Endpoints ---

@app.post("/users")
async def register_user(data: UserRegister):
    """Register a new user or get existing user."""
    try:
        user = database.create_or_get_user(data.user_id)
        return {
            "status": "success",
            "user": user
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Database error: {str(e)}")


@app.get("/users/{user_id}")
async def get_user(user_id: str):
    """Get user information by ID."""
    try:
        user = database.get_user(user_id)
        if user is None:
            raise HTTPException(status_code=404, detail="User not found")
        return {
            "status": "success",
            "user": user
        }
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Database error: {str(e)}")


# --- API Endpoints ---


@app.post("/predict")
async def predict_cough(
    file: UploadFile = File(...),
    user_id: Optional[str] = None  # Query parameter - simple and reliable
):
    print(f"--- [BACKEND] Received request: /predict ---")
    print(f"--- [BACKEND] File name: {file.filename} ---")
    print(f"--- [BACKEND] User ID from query param: {user_id} ---")

    if not model:
        print("--- [BACKEND] ERROR: Model not loaded! ---")
        raise HTTPException(status_code=503, detail="Model not loaded")
    
    if not file.filename:
         raise HTTPException(status_code=400, detail="Empty filename")

    # Save temp file
    temp_dir = "temp_uploads"
    os.makedirs(temp_dir, exist_ok=True)
    
    try:
        start_read = time.time()
        contents = await file.read()
        print(f"--- [BACKEND] File read successfully. Size: {len(contents)} bytes. Time: {time.time() - start_read:.4f}s ---")

        temp_filename = f"temp_{int(time.time())}_{file.filename}"
        temp_path = os.path.join(temp_dir, temp_filename) # Ensure temp_path uses temp_dir
        with open(temp_path, "wb") as f:
            f.write(contents)
        print(f"--- [BACKEND] Temp file saved: {temp_path} ---")

        # Preprocessing
        print(f"--- [BACKEND] Starting spectrogram generation for {temp_path}... ---")
        start_spectrogram = time.time()
        spectrogram_img = create_spectrogram(temp_path)
        print(f"--- [BACKEND] Spectrogram generated. Time: {time.time() - start_spectrogram:.4f}s ---")

        if spectrogram_img is None:
             print("--- [BACKEND] ERROR: Spectrogram generation failed (return is None) ---")
             raise HTTPException(status_code=400, detail="Could not process audio file (Spectrogram generation failed)")
             
        print("--- [BACKEND] Starting preprocessing... ---")
        input_data = preprocess_for_model(spectrogram_img)
        print(f"--- [BACKEND] Preprocessing complete. Input shape: {input_data.shape} ---")
        
        # Inference
        # Output is sigmoid (0-1), probability of class 1 (Wet)
        print("--- [BACKEND] Starting model prediction... ---")
        start_predict = time.time()
        prediction = model.predict(input_data)
        print(f"--- [BACKEND] Prediction complete. Time: {time.time() - start_predict:.4f}s ---")
        print(f"--- [BACKEND] Raw Prediction: {prediction} ---")

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
        
        # Save diagnosis to database with user_id
        try:
            diagnosis_id = database.save_diagnosis(
                jenis_batuk=label,
                confidence=confidence,
                tingkat_kondisi=level,
                rekomendasi_obat=recommendations,
                user_id=user_id  # Use query param user_id
            )
            print(f"--- [BACKEND] Saved diagnosis to database with ID: {diagnosis_id} for user: {user_id} ---")
            
            # Broadcast to all WebSocket clients
            await manager.broadcast({
                "type": "new_diagnosis",
                "diagnosis_id": diagnosis_id,
                "user_id": user_id,
                "data": {
                    "jenis_batuk": label,
                    "confidence": confidence,
                    "tingkat_kondisi": level,
                    "rekomendasi_obat": recommendations
                }
            })
            print(f"--- [BACKEND] Broadcasted new diagnosis to WebSocket clients ---")
            
        except Exception as db_error:
            print(f"--- [BACKEND] Warning: Failed to save to database: {db_error} ---")
            diagnosis_id = None
        
        return {
            "status": "success",
            "file": file.filename,
            "prediction": label,
            "confidence": confidence,
            "analysis": level,
            "score_wet": score_wet,
            "threshold_used": THRESHOLD,
            "recommendations": recommendations,
            "diagnosis_id": diagnosis_id,
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

# --- History Endpoints ---

@app.get("/history")
async def get_history(
    limit: int = 50,
    x_user_id: Optional[str] = Header(None, alias="x-user-id")
):
    """Get diagnosis history, most recent first. Filters by user if X-User-ID header provided."""
    print(f"--- [BACKEND] /history called, user_id from header: {x_user_id} ---", file=sys.stderr)
    try:
        history = database.get_all_diagnoses(limit=limit, user_id=x_user_id)
        print(f"--- [BACKEND] Returning {len(history)} records ---", file=sys.stderr)
        return {
            "status": "success",
            "count": len(history),
            "history": history
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Database error: {str(e)}")


@app.get("/history/{diagnosis_id}")
async def get_diagnosis_detail(diagnosis_id: int):
    """Get a specific diagnosis by ID."""
    try:
        diagnosis = database.get_diagnosis_by_id(diagnosis_id)
        if diagnosis is None:
            raise HTTPException(status_code=404, detail="Diagnosis not found")
        return {
            "status": "success",
            "diagnosis": diagnosis
        }
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Database error: {str(e)}")


@app.delete("/history/{diagnosis_id}")
async def delete_diagnosis(
    diagnosis_id: int,
    x_user_id: Optional[str] = Header(None, alias="x-user-id")
):
    """Delete a diagnosis record by ID. Verifies ownership if X-User-ID provided."""
    try:
        deleted = database.delete_diagnosis(diagnosis_id, user_id=x_user_id)
        if not deleted:
            raise HTTPException(status_code=404, detail="Diagnosis not found or not owned by user")
        
        # Broadcast deletion to all WebSocket clients
        await manager.broadcast({
            "type": "diagnosis_deleted",
            "diagnosis_id": diagnosis_id,
            "user_id": x_user_id
        })
        
        return {
            "status": "success",
            "message": f"Diagnosis {diagnosis_id} deleted"
        }
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Database error: {str(e)}")


@app.get("/statistics")
async def get_statistics(
    x_user_id: Optional[str] = Header(None, alias="x-user-id")
):
    """Get diagnosis statistics. Filters by user if X-User-ID header provided."""
    try:
        stats = database.get_statistics(user_id=x_user_id)
        return {
            "status": "success",
            "statistics": stats
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Database error: {str(e)}")


# --- WebSocket Endpoint ---
@app.websocket("/ws")
async def websocket_endpoint(websocket: WebSocket):
    """WebSocket endpoint for real-time history updates."""
    await manager.connect(websocket)
    try:
        while True:
            # Keep connection alive and listen for messages
            data = await websocket.receive_text()
            # Handle ping/pong for connection keep-alive
            if data == "ping":
                await websocket.send_text("pong")
    except WebSocketDisconnect:
        manager.disconnect(websocket)
    except Exception as e:
        print(f"WebSocket error: {e}", file=sys.stderr)
        manager.disconnect(websocket)


if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=8000)
