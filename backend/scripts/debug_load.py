
import tensorflow as tf
import os

try:
    print(f"TF Version: {tf.__version__}")
    model_path = "temp_model.keras"
    if os.path.exists(model_path):
        print(f"Loading {model_path}...")
        model = tf.keras.models.load_model(model_path)
        print("Success!")
    else:
        print("temp_model.keras not found")
except Exception as e:
    with open("error_log.txt", "w") as f:
        f.write(str(e))
    print("Error occurred, written to error_log.txt")
