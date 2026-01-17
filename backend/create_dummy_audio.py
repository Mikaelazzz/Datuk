
import numpy as np
import scipy.io.wavfile as wav

fs = 44100
duration = 2  # seconds
frequency = 440  # Hz
t = np.linspace(0, duration, int(fs * duration), endpoint=False)
audio = 0.5 * np.sin(2 * np.pi * frequency * t)

wav.write('dummy_cough.wav', fs, (audio * 32767).astype(np.int16))
print("Created dummy_cough.wav")
