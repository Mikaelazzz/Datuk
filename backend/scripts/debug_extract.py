
def extract_partial_code(path):
    with open(path, 'r', encoding='utf-8', errors='ignore') as f:
        content = f.read(100000) # Read first 100KB
    
    # split by "source": [
    parts = content.split('"source": [')
    
    print(f"Found {len(parts)} potential source blocks in first 100KB")
    
    for i, part in enumerate(parts[1:]): # skip first preamble
        # end of source block is "]"
        end = part.find(']')
        if end != -1:
            raw_source = part[:end]
            # parse each line string
            # lines are like "import foo\n", "print(x)\n"
            # messy but readable
            print(f"\n--- BLOCK {i} ---")
            print(raw_source)

extract_partial_code('../../rag-obat-batuk.ipynb')
