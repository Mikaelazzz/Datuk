
import requests
import os

url = 'http://127.0.0.1:8000/predict'
# Create a dummy file
with open('dummy.wav', 'wb') as f:
    f.write(os.urandom(1024)) # 1KB of random data

files = {'file': ('dummy.wav', open('dummy.wav', 'rb'), 'audio/wav')}

try:
    print(f"Sending request to {url}...")
    response = requests.post(url, files=files)
    print(f"Status Code: {response.status_code}")
    print(f"Response: {response.text}")
except Exception as e:
    print(f"Error: {e}")
