import json
import os

path = '../../rag-obat-batuk.ipynb'
print(f"Size: {os.path.getsize(path)} bytes")

try:
    with open(path, 'r', encoding='utf-8') as f:
        data = json.load(f)
    print("JSON Valid!")
    print(f"Keys: {data.keys()}")
    print(f"Cells: {len(data['cells'])}")
    
    # Try to find code cells
    code_cells = [c for c in data['cells'] if c['cell_type'] == 'code']
    print(f"Code Cells: {len(code_cells)}")
    
    # Print first line of each code cell
    for i, cell in enumerate(code_cells):
        src = cell['source']
        if src:
            print(f"Cell {i} start: {src[0].strip()}")
            
except Exception as e:
    print(f"Error: {e}")
