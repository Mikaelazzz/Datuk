
import requests
import time
import sys

url = "http://127.0.0.1:8000/predict"
file_path = "backend/dummy_cough.wav"

print("Waiting for server...")
for i in range(10):
    try:
        response = requests.get("http://127.0.0.1:8000/docs")
        if response.status_code == 200:
            print("Server is up!")
            break
    except:
        time.sleep(2)
else:
    print("Server failed to start")
    sys.exit(1)

print(f"Sending {file_path}...")
try:
    with open(file_path, 'rb') as f:
        files = {'file': ('dummy_cough.wav', f, 'audio/wav')}
        response = requests.post(url, files=files)
        
    print("Status Code:", response.status_code)
    print("Response:", response.json())
except Exception as e:
    print(f"Error: {e}")
