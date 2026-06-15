@echo off
title Ventura Application Suite
cls

:main
cls
echo ===================================================
echo             VENTURA APPLICATION SUITE
echo ===================================================
echo.

:: Check for Node.js
where node >nul 2>nul
if %errorlevel% neq 0 (
    echo [ERROR] Node.js is not installed or not in PATH.
    echo Please install Node.js from https://nodejs.org/ before running.
    pause
    exit /b 1
)

:: Check for Flutter
where flutter >nul 2>nul
if %errorlevel% neq 0 (
    echo [ERROR] Flutter is not installed or not in PATH.
    echo Please install Flutter from https://flutter.dev/ before running.
    pause
    exit /b 1
)

:: Check if root node_modules exists
if not exist node_modules (
    echo [INFO] Root node_modules not found. Installing runner dependencies...
    call npm install
)

:: Check if backend services have node_modules
if not exist backend\api-gateway\node_modules (
    echo [INFO] Backend dependencies not found. Installing dependencies...
    call npm run install:all
) else if not exist VenturaProject-frontend\.dart_tool (
    echo [INFO] Frontend packages not found. Fetching flutter packages...
    call npm run install:frontend
)

:prompt
echo Please select how you want to run the Ventura App:
echo [1] Run Backend Services + Frontend (Windows Desktop)
echo [2] Run Backend Services + Frontend (Chrome Web Browser)
echo [3] Run Backend Services Only
echo [4] Install / Reinstall All Dependencies (Backend + Frontend)
echo [5] Exit
echo.

set /p choice="Enter choice [1-5]: "

if "%choice%"=="1" (
    echo Starting Backend Services and Flutter Windows Desktop App...
    npm run start:all:windows
) else if "%choice%"=="2" (
    echo Starting Backend Services and Flutter Chrome App...
    npm run start:all:chrome
) else if "%choice%"=="3" (
    echo Starting Backend Services Only...
    npm run start:backend
) else if "%choice%"=="4" (
    echo Reinstalling all dependencies...
    call npm run install:all
    echo Dependencies installed. Press any key to return to main menu...
    pause
    goto :main
) else if "%choice%"=="5" (
    exit /b 0
) else (
    echo Invalid choice, please choose 1-5.
    pause
    goto :prompt
)
