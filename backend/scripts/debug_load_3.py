
import os
import traceback
import sys

with open("debug_log_2.txt", "w", encoding='utf-8') as log:
    sys.stdout = log
    sys.stderr = log
    
    try:
        import keras
        print(f"Keras (standalone) Version: {keras.__version__}")
        
        model_path = "temp_model.keras"
        if os.path.exists(model_path):
            print(f"Loading {model_path} using keras.models.load_model...")
            model = keras.models.load_model(model_path)
            print("Success with keras.models.load_model!")
        else:
            print("temp_model.keras not found")
            
    except Exception as e:
        print("Failed with keras.models.load_model")
        traceback.print_exc()

    print("-" * 20)

    try:
        import tensorflow as tf
        print(f"TF Version: {tf.__version__}")
        model_path = "temp_model.keras"
        if os.path.exists(model_path):
            print(f"Loading {model_path} using tf.keras.models.load_model...")
            model = tf.keras.models.load_model(model_path)
            print("Success with tf.keras.models.load_model!")
    except Exception as e:
        print("Failed with tf.keras.models.load_model")
        traceback.print_exc()
