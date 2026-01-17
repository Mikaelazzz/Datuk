
import json

try:
    with open('../rag-obat-batuk.ipynb', 'r', encoding='utf-8') as f:
        notebook = json.load(f)
        
    code_cells = []
    for cell in notebook['cells']:
        if cell['cell_type'] == 'code':
            source = ''.join(cell['source'])
            code_cells.append(source)
            
    with open('rag_code_dump.py', 'w', encoding='utf-8') as f:
        f.write('\n\n# CELL ----------------\n\n'.join(code_cells))
    print("Extracted code to rag_code_dump.py")
except Exception as e:
    print(f"Error: {e}")
