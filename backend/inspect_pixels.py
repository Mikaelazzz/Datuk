
from PIL import Image
import os
import numpy as np

base_dir = os.path.dirname(os.path.abspath(__file__))
folder = os.path.join(base_dir, "../spectrograms")

if os.path.exists(folder):
    files = [f for f in os.listdir(folder) if f.endswith('.png')]
    if files:
        img_path = os.path.join(folder, files[0])
        try:
            with Image.open(img_path) as img:
                print(f"Image: {files[0]}")
                print(f"Size: {img.size}")
                print(f"Mode: {img.mode}")
                
                # Sample pixels
                # Convert to RGBA
                img = img.convert("RGBA")
                data = np.array(img)
                
                # Check corners
                print(f"Corner (0,0): {data[0,0]}")
                print(f"Corner (max,max): {data[-1,-1]}")
                print(f"Center: {data[data.shape[0]//2, data.shape[1]//2]}")
                
                # Check if mostly white or transparent
                white_pixels = np.sum(np.all(data[:, :, :3] == 255, axis=2))
                total_pixels = data.shape[0] * data.shape[1]
                print(f"White pixels: {white_pixels} / {total_pixels} ({white_pixels/total_pixels:.2%})")
                
        except Exception as e:
            print(f"Error opening image: {e}")
    else:
        print("No png images found.")
else:
    print("Folder not found.")
