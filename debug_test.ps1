# 調試API測試

Write-Host "🔍 調試API測試" -ForegroundColor Green

# 測試註冊API並獲取詳細錯誤信息
Write-Host "`n測試用戶註冊..." -ForegroundColor Yellow
$body = '{"email":"test@example.com","password":"123456","nickname":"測試用戶","realName":"王小明","idCardNumber":"A123456789"}'

try {
    $response = Invoke-WebRequest -Uri "http://localhost:3000/api/auth/register" -Method POST -Body $body -ContentType "application/json" -UseBasicParsing
    Write-Host "✅ 註冊成功 (狀態碼: $($response.StatusCode))" -ForegroundColor Green
    $response.Content | ConvertFrom-Json | ConvertTo-Json -Depth 3
} catch {
    Write-Host "❌ 註冊失敗: $($_.Exception.Message)" -ForegroundColor Red
    
    if ($_.Exception.Response) {
        $statusCode = $_.Exception.Response.StatusCode
        Write-Host "狀態碼: $statusCode" -ForegroundColor Red
        
        # 嘗試讀取響應內容
        try {
            $responseStream = $_.Exception.Response.GetResponseStream()
            $reader = New-Object System.IO.StreamReader($responseStream)
            $responseBody = $reader.ReadToEnd()
            Write-Host "響應內容: $responseBody" -ForegroundColor Red
        } catch {
            Write-Host "無法讀取響應內容: $($_.Exception.Message)" -ForegroundColor Red
        }
    }
}

Write-Host "`n🎉 調試測試完成！" -ForegroundColor Green



