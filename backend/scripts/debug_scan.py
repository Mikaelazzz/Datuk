
path = '../../rag-obat-batuk.ipynb'
print(f"Scanning {path}...")

with open(path, 'r', encoding='utf-8', errors='replace') as f:
    for i, line in enumerate(f):
        # if i > 2000: break
        if "source" in line:
            print(f"Line {i}: {repr(line)}")
