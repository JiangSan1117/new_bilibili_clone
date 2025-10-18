# 簡單的API測試

Write-Host "🧪 簡單API測試" -ForegroundColor Green

# 測試健康檢查
Write-Host "`n1. 測試健康檢查..." -ForegroundColor Yellow
try {
    $response = Invoke-RestMethod -Uri "http://localhost:3000/health" -Method GET
    Write-Host "✅ 健康檢查成功" -ForegroundColor Green
    Write-Host "狀態: $($response.status)" -ForegroundColor White
    Write-Host "時間: $($response.timestamp)" -ForegroundColor White
} catch {
    Write-Host "❌ 健康檢查失敗: $($_.Exception.Message)" -ForegroundColor Red
}

# 測試API文檔
Write-Host "`n2. 測試API文檔..." -ForegroundColor Yellow
try {
    $response = Invoke-RestMethod -Uri "http://localhost:3000/api/docs" -Method GET
    Write-Host "✅ API文檔獲取成功" -ForegroundColor Green
    Write-Host "版本: $($response.version)" -ForegroundColor White
    Write-Host "端點數量: $($response.endpoints.Count)" -ForegroundColor White
} catch {
    Write-Host "❌ API文檔獲取失敗: $($_.Exception.Message)" -ForegroundColor Red
}

# 測試註冊（使用更簡單的方法）
Write-Host "`n3. 測試用戶註冊..." -ForegroundColor Yellow
$body = '{"email":"test@example.com","password":"123456","nickname":"測試用戶","realName":"王小明","idCardNumber":"A123456789"}'

try {
    $response = Invoke-WebRequest -Uri "http://localhost:3000/api/auth/register" -Method POST -Body $body -ContentType "application/json" -UseBasicParsing
    Write-Host "✅ 註冊成功 (狀態碼: $($response.StatusCode))" -ForegroundColor Green
    
    # 解析JSON響應
    $jsonResponse = $response.Content | ConvertFrom-Json
    Write-Host "訊息: $($jsonResponse.message)" -ForegroundColor White
    
    if ($jsonResponse.token) {
        Write-Host "Token: $($jsonResponse.token.Substring(0,20))..." -ForegroundColor Cyan
        $global:token = $jsonResponse.token
    }
} catch {
    Write-Host "❌ 註冊失敗: $($_.Exception.Message)" -ForegroundColor Red
    if ($_.Exception.Response) {
        $stream = $_.Exception.Response.GetResponseStream()
        $reader = New-Object System.IO.StreamReader($stream)
        $responseBody = $reader.ReadToEnd()
        Write-Host "錯誤詳情: $responseBody" -ForegroundColor Red
    }
}

Write-Host "`n🎉 測試完成！" -ForegroundColor Green



