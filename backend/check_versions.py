
import tensorflow as tf
try:
    import keras
    print(f"Keras Version: {keras.__version__}")
except:
    print("Keras not found directly")
print(f"TensorFlow Version: {tf.__version__}")
print(f"TF Keras Version: {tf.keras.__version__}")
