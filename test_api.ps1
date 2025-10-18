# 測試API的PowerShell腳本

Write-Host "🚀 開始測試想享APP後端API..." -ForegroundColor Green

# 測試1: 健康檢查
Write-Host "`n📋 測試1: 健康檢查" -ForegroundColor Yellow
try {
    $healthResponse = Invoke-RestMethod -Uri "http://localhost:3000/health" -Method GET
    Write-Host "✅ 健康檢查成功:" -ForegroundColor Green
    $healthResponse | ConvertTo-Json -Depth 3
} catch {
    Write-Host "❌ 健康檢查失敗: $($_.Exception.Message)" -ForegroundColor Red
}

# 測試2: API文檔
Write-Host "`n📋 測試2: API文檔" -ForegroundColor Yellow
try {
    $docsResponse = Invoke-RestMethod -Uri "http://localhost:3000/api/docs" -Method GET
    Write-Host "✅ API文檔獲取成功:" -ForegroundColor Green
    $docsResponse | ConvertTo-Json -Depth 3
} catch {
    Write-Host "❌ API文檔獲取失敗: $($_.Exception.Message)" -ForegroundColor Red
}

# 測試3: 用戶註冊
Write-Host "`n📋 測試3: 用戶註冊" -ForegroundColor Yellow
$registerData = @{
    email = "test@example.com"
    password = "123456"
    nickname = "測試用戶"
    realName = "王小明"
    idCardNumber = "A123456789"
} | ConvertTo-Json

try {
    $registerResponse = Invoke-RestMethod -Uri "http://localhost:3000/api/auth/register" -Method POST -Body $registerData -ContentType "application/json"
    Write-Host "✅ 用戶註冊成功:" -ForegroundColor Green
    $registerResponse | ConvertTo-Json -Depth 3
    
    # 保存token用於後續測試
    $global:testToken = $registerResponse.token
    Write-Host "💾 Token已保存: $($global:testToken.Substring(0,20))..." -ForegroundColor Cyan
} catch {
    Write-Host "❌ 用戶註冊失敗: $($_.Exception.Message)" -ForegroundColor Red
    if ($_.Exception.Response) {
        $reader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
        $responseBody = $reader.ReadToEnd()
        Write-Host "錯誤詳情: $responseBody" -ForegroundColor Red
    }
}

# 測試4: 用戶登入
Write-Host "`n📋 測試4: 用戶登入" -ForegroundColor Yellow
$loginData = @{
    email = "test@example.com"
    password = "123456"
} | ConvertTo-Json

try {
    $loginResponse = Invoke-RestMethod -Uri "http://localhost:3000/api/auth/login" -Method POST -Body $loginData -ContentType "application/json"
    Write-Host "✅ 用戶登入成功:" -ForegroundColor Green
    $loginResponse | ConvertTo-Json -Depth 3
} catch {
    Write-Host "❌ 用戶登入失敗: $($_.Exception.Message)" -ForegroundColor Red
    if ($_.Exception.Response) {
        $reader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
        $responseBody = $reader.ReadToEnd()
        Write-Host "錯誤詳情: $responseBody" -ForegroundColor Red
    }
}

# 測試5: 獲取用戶資料（需要認證）
if ($global:testToken) {
    Write-Host "`n📋 測試5: 獲取用戶資料" -ForegroundColor Yellow
    $headers = @{
        "Authorization" = "Bearer $($global:testToken)"
        "Content-Type" = "application/json"
    }
    
    try {
        $profileResponse = Invoke-RestMethod -Uri "http://localhost:3000/api/auth/profile" -Method GET -Headers $headers
        Write-Host "✅ 獲取用戶資料成功:" -ForegroundColor Green
        $profileResponse | ConvertTo-Json -Depth 3
    } catch {
        Write-Host "❌ 獲取用戶資料失敗: $($_.Exception.Message)" -ForegroundColor Red
    }
}

Write-Host "`n🎉 API測試完成！" -ForegroundColor Green
Write-Host "💡 提示：所有測試都在模擬模式下運行（沒有真實數據庫）" -ForegroundColor Cyan



