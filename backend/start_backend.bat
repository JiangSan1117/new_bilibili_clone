@echo off
echo 🚀 啟動想享APP後端服務...
echo.

echo 📋 檢查Node.js...
node --version
if %errorlevel% neq 0 (
    echo ❌ Node.js未安裝，請先安裝Node.js
    pause
    exit /b 1
)

echo 📋 檢查npm...
npm --version
if %errorlevel% neq 0 (
    echo ❌ npm未安裝，請先安裝npm
    pause
    exit /b 1
)

echo.
echo 📦 安裝依賴包...
npm install
if %errorlevel% neq 0 (
    echo ❌ 依賴安裝失敗
    pause
    exit /b 1
)

echo.
echo 📋 檢查環境配置...
if not exist .env (
    echo ⚠️  .env文件不存在，從模板創建...
    copy env.example .env
    echo ✅ 已創建.env文件，請編輯其中的配置
)

echo.
echo 🔍 檢查MongoDB連接...
echo 請確保MongoDB服務正在運行

echo.
echo 🚀 啟動開發服務器...
echo 服務將在 http://localhost:3000 啟動
echo 按 Ctrl+C 停止服務
echo.

npm run dev



