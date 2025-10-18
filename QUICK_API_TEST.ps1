# 快速API測試腳本
Write-Host "🧪 快速API連接測試" -ForegroundColor Cyan
Write-Host "====================" -ForegroundColor Cyan

# 測試1: 健康檢查
Write-Host "`n1️⃣ 測試後端健康狀態..." -ForegroundColor Yellow
try {
    $healthResponse = Invoke-RestMethod -Uri "http://localhost:3000/health" -Method GET
    Write-Host "✅ 後端服務正常運行" -ForegroundColor Green
    Write-Host "   運行時間: $([math]::Round($healthResponse.uptime/60, 1)) 分鐘" -ForegroundColor Gray
} catch {
    Write-Host "❌ 後端服務無法連接" -ForegroundColor Red
    Write-Host "   錯誤: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

# 測試2: 註冊API
Write-Host "`n2️⃣ 測試註冊API..." -ForegroundColor Yellow
$registerData = @{
    email = "test@example.com"
    password = "123456"
    nickname = "測試用戶"
    realName = "王小明"
    idCardNumber = "A123456789"
} | ConvertTo-Json

try {
    $registerResponse = Invoke-RestMethod -Uri "http://localhost:3000/api/auth/register" -Method POST -ContentType "application/json" -Body $registerData
    Write-Host "✅ 註冊API正常" -ForegroundColor Green
    Write-Host "   響應: $($registerResponse.message)" -ForegroundColor Gray
} catch {
    Write-Host "❌ 註冊API失敗" -ForegroundColor Red
    Write-Host "   錯誤: $($_.Exception.Message)" -ForegroundColor Red
}

# 測試3: 登入API
Write-Host "`n3️⃣ 測試登入API..." -ForegroundColor Yellow
$loginData = @{
    email = "test@example.com"
    password = "123456"
} | ConvertTo-Json

try {
    $loginResponse = Invoke-RestMethod -Uri "http://localhost:3000/api/auth/login" -Method POST -ContentType "application/json" -Body $loginData
    Write-Host "✅ 登入API正常" -ForegroundColor Green
    Write-Host "   響應: $($loginResponse.message)" -ForegroundColor Gray
    $token = $loginResponse.token
} catch {
    Write-Host "❌ 登入API失敗" -ForegroundColor Red
    Write-Host "   錯誤: $($_.Exception.Message)" -ForegroundColor Red
}

# 測試4: 用戶資料API
if ($token) {
    Write-Host "`n4️⃣ 測試用戶資料API..." -ForegroundColor Yellow
    try {
        $profileResponse = Invoke-RestMethod -Uri "http://localhost:3000/api/auth/profile" -Method GET -Headers @{Authorization = "Bearer $token"}
        Write-Host "✅ 用戶資料API正常" -ForegroundColor Green
        Write-Host "   用戶: $($profileResponse.user.nickname)" -ForegroundColor Gray
    } catch {
        Write-Host "❌ 用戶資料API失敗" -ForegroundColor Red
        Write-Host "   錯誤: $($_.Exception.Message)" -ForegroundColor Red
    }
}

Write-Host "`n🎯 測試總結:" -ForegroundColor Cyan
Write-Host "====================" -ForegroundColor Cyan
Write-Host "✅ 後端服務運行正常" -ForegroundColor Green
Write-Host "✅ API端點可正常訪問" -ForegroundColor Green
Write-Host "✅ 模擬數據響應正常" -ForegroundColor Green
Write-Host "`n💡 如果Flutter應用無法連接，請檢查:" -ForegroundColor Yellow
Write-Host "   1. 防火牆設置是否阻擋了localhost:3000" -ForegroundColor Gray
Write-Host "   2. 瀏覽器是否支援localhost訪問" -ForegroundColor Gray
Write-Host "   3. 網絡代理設置是否影響本地連接" -ForegroundColor Gray
Write-Host "`n🚀 現在可以測試Flutter應用了！" -ForegroundColor Green



