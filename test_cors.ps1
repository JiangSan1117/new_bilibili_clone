# 測試CORS修復
Write-Host "🧪 測試CORS修復" -ForegroundColor Cyan
Write-Host "================" -ForegroundColor Cyan

# 測試從不同端口訪問API
$ports = @(3000, 63859, 35040, 8080, 5000)

foreach ($port in $ports) {
    Write-Host "`n測試端口 $port..." -ForegroundColor Yellow
    try {
        $response = Invoke-RestMethod -Uri "http://127.0.0.1:3000/health" -Method GET -Headers @{
            "Origin" = "http://localhost:$port"
            "Access-Control-Request-Method" = "POST"
            "Access-Control-Request-Headers" = "Content-Type,Authorization"
        }
        Write-Host "✅ 端口 $port 可以訪問API" -ForegroundColor Green
    } catch {
        Write-Host "❌ 端口 $port 無法訪問API: $($_.Exception.Message)" -ForegroundColor Red
    }
}

Write-Host "`n🎯 CORS測試完成！" -ForegroundColor Cyan
Write-Host "現在可以測試Flutter應用了。" -ForegroundColor Green



