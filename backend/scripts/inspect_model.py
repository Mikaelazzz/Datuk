
import os
import tensorflow as tf
import numpy as np
import shutil

print(f"TensorFlow Version: {tf.__version__}")
try:
    import keras
    print(f"Keras Version: {keras.__version__}")
except:
    print("Keras not accessible directly")

base_dir = os.path.dirname(os.path.abspath(__file__))
model_dir = os.path.join(base_dir, "../final_cough_model.keras")

print(f"Model path: {model_dir}")
if os.path.isdir(model_dir):
    print("Path is a directory.")
    # Attempt to zip it if it looks like a Keras 3 model
    if os.path.exists(os.path.join(model_dir, "model.weights.h5")):
        print("Detected unzipped Keras model. Zipping to temp file...")
        zip_path = os.path.join(base_dir, "temp_model") # shutil.make_archive adds extension
        shutil.make_archive(zip_path, 'zip', model_dir)
        final_zip_path = zip_path + ".zip"
        keras_path = zip_path + ".keras"
        if os.path.exists(keras_path):
            os.remove(keras_path)
        os.rename(final_zip_path, keras_path)
        print(f"Created {keras_path}")
        
        try:
            model = tf.keras.models.load_model(keras_path)
            print("Model loaded successfully from zipped file.")
            model.summary()
            print("Input Shape:", model.input_shape)
            print("Output Shape:", model.output_shape)
            exit(0)
        except Exception as e:
            print(f"Failed to load zipped model: {e}")

try:
    model = tf.keras.models.load_model(model_dir)
    print("Model loaded successfully from directory.")
    model.summary()
except Exception as e:
    print(f"Error loading model directly: {e}")

