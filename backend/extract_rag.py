
import json
import re

def extract_code(notebook_path, output_path):
    with open(notebook_path, 'r', encoding='utf-8', errors='replace') as f:
        content = f.read()

    # Simple regex to find code cells (approximate)
    # This is hacky but might work if json parse fails
    # actually, why did json parse fail? "Unterminated string". maybe the file is indeed corrupted.
    
    # let's try to fix the string if possible or just use regex to find "source": [ ... ] inside "cell_type": "code"
    
    # We will iterate through the file and look for code cells
    # This pattern matches "cell_type": "code" ... "source": [...]
    # It's hard to parse nested JSON with regex.
    pass

# standard json load again but with error handling?
try:
    with open('../rag-obat-batuk.ipynb', 'r', encoding='utf-8') as f:
        data = json.load(f)
    
    print("JSON Load Successful!")
    
    all_code = ""
    for cell in data['cells']:
        if cell['cell_type'] == 'code':
            source_lines = cell['source']
            code = "".join(source_lines)
            all_code += f"\n# %% CELL\n{code}\n"
            
    with open('rag_implementation.py', 'w', encoding='utf-8') as f:
        f.write(all_code)
    print("Extraction complete.")

except json.JSONDecodeError as e:
    print(f"JSON Decode Error: {e}")
    # Fallback: try to read just the text lines that look like code?
    # No, that's too hard.
    
except Exception as e:
    print(f"Error: {e}")
