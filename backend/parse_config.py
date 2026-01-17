
import json
import os

base_dir = os.path.dirname(os.path.abspath(__file__))
config_path = os.path.join(base_dir, "../final_cough_model.keras/config.json")

try:
    with open(config_path, 'r') as f:
        data = json.load(f)
        
    config = data.get('config', {})
    layers = config.get('layers', [])
    
    if layers:
        first_layer = layers[0]
        print(f"First Layer Input Shape: {first_layer.get('config', {}).get('batch_shape')}")
        
        last_layer = layers[-1]
        print(f"Last Layer Type: {last_layer.get('class_name')}")
        conf = last_layer.get('config', {})
        print(f"Units: {conf.get('units')}")
        print(f"Activation: {conf.get('activation')}")
    else:
        print("No layers found.")

except Exception as e:
    print(f"Error: {e}")
