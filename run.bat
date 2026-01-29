@echo off
echo ==========================================
echo Starting Datuk Application System
echo ==========================================

echo Starting Backend Server...
start "Datuk Backend" cmd /k "cd backend && python main.py"

echo Waiting for backend to initialize...
timeout /t 5 /nobreak >nul

echo Starting Flutter Application...
start "Datuk Mobile App" cmd /k "flutter run"

echo ==========================================
echo Both services have been requested to start.
echo Please check the new windows for status.
echo ==========================================
