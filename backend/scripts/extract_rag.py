
def extract_code_streaming(notebook_path, output_path):
    print(f"Streaming from {notebook_path}...")
    extracted_code = []
    
    in_source = False
    
    try:
        with open(notebook_path, 'r', encoding='utf-8', errors='replace') as f:
            for line in f:
                stripped = line.strip()
                
                # Detect start of source block
                # Strict check for "source": [
                if '"source": [' in line:
                    in_source = True
                    # print("Entered source block")
                    continue
                
                # Detect end of source block
                # It usually looks like "   ]" or "   ],"
                if in_source and stripped.startswith(']'):
                    in_source = False
                    extracted_code.append("\n# %% CELL\n")
                    # print("Exited source block")
                    continue
                
                if in_source:
                    # Typical line: "    import foo\n",
                    # or: "    print('hello')"
                    
                    # Must start with quote?
                    # Jupyter JSON lines usually are quoted strings
                    
                    # Fast parse: content is everything between first and last quote?
                    # But quotes can be escaped.
                    # Simple heuristic:
                    
                    try:
                        # Find first quote
                        first_quote = line.find('"')
                        if first_quote == -1: continue # Should contain a quote
                        
                        # Find last quote (ignoring comma if present)
                        last_quote = line.rfind('"')
                        if last_quote == first_quote: continue # Empty or single quote?
                        
                        # Content
                        content_raw = line[first_quote+1:last_quote]
                        
                        # Unescape
                        # Replace \\" with "
                        # Replace \\n with \n
                        # Replace \\\\ with \\
                        content = content_raw.replace('\\"', '"').replace('\\n', '\n').replace('\\\\', '\\')
                        
                        extracted_code.append(content)
                    except:
                        pass

        with open(output_path, 'w', encoding='utf-8') as f:
            f.write("".join(extracted_code))
            
        print(f"Extracted {len(extracted_code)} lines to {output_path}")

    except Exception as e:
        print(f"Error: {e}")

if __name__ == "__main__":
    extract_code_streaming('../../rag-obat-batuk.ipynb', 'rag_source.py')
