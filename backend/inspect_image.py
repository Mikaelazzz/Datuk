
from PIL import Image
import os

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
        except Exception as e:
            print(f"Error opening image: {e}")
    else:
        print("No png images found.")
else:
    print(f"Folder not found: {folder}")
