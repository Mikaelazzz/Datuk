
import librosa
import librosa.display
import numpy as np
import matplotlib
# Set backend to Agg to avoid GUI requirement
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from PIL import Image
import io
import os
import cv2

def create_spectrogram(audio_path):
    """
    Converts audio to a spectrogram image matching the training notebook.
    """
    try:
        # Load with native sampling rate
        y, sr = librosa.load(audio_path, sr=None)
        
        # Parameters from datuk.ipynb
        # n_mels=128, fmax=8000 (n_fft=2048, hop_length=512 are defaults)
        S = librosa.feature.melspectrogram(y=y, sr=sr, n_mels=128, fmax=8000)
        S_dB = librosa.power_to_db(S, ref=np.max)
        
        # Plotting - Exactly as in the notebook
        plt.figure(figsize=(4, 4))
        librosa.display.specshow(S_dB, sr=sr, fmax=8000)
        plt.axis('off')
        
        buf = io.BytesIO()
        plt.savefig(buf, format='png', bbox_inches='tight', pad_inches=0)
        plt.close()
        buf.seek(0)
        
        # Open with PIL
        img = Image.open(buf).convert('RGB')
        return img
        
    except Exception as e:
        print(f"Error creating spectrogram: {e}")
        return None

def preprocess_for_model(image_path_or_obj, target_size=(128, 128)):
    """
    Loads, resizes, and normalizes image for MobileNetV2.
    Normalization: [-1, 1] range.
    """
    if isinstance(image_path_or_obj, str):
        img_pil = Image.open(image_path_or_obj).convert('RGB')
    else:
        img_pil = image_path_or_obj
        
    # Resize to target size (128, 128)
    # Note: Training used cv2.resize. PIL.Image.resize is similar but not identical.
    # To be safe, we can use cv2 if available, or stick to PIL if precision isn't critical.
    # Given we have cv2 installed via opencv-python-headless presumably (or we will), 
    # let's try to convert to array first.
    
    img_array = np.array(img_pil)
    
    # Resize using cv2 to match training exactly
    # Training: img = cv2.resize(img, (IMG_SIZE, IMG_SIZE))
    img_array = cv2.resize(img_array, target_size)
    
    # Preprocessing MobileNetV2 (Scaling -1 to 1)
    # Original: img = preprocess_input(img.astype(np.float32))
    # Tensorflow's preprocess_input for MobileNetV2: ((x / 127.5) - 1)
    img_array = img_array.astype(np.float32)
    img_array = (img_array / 127.5) - 1.0
    
    # Add batch dimension: (1, 128, 128, 3)
    img_array = np.expand_dims(img_array, axis=0)
    
    return img_array
