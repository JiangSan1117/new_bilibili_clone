# 使用curl測試API

Write-Host "🧪 使用curl測試API" -ForegroundColor Green

# 測試註冊
Write-Host "`n測試用戶註冊..." -ForegroundColor Yellow
$curlCommand = 'curl -X POST http://localhost:3000/api/auth/register -H "Content-Type: application/json" -d "{\"email\":\"test@example.com\",\"password\":\"123456\",\"nickname\":\"測試用戶\",\"realName\":\"王小明\",\"idCardNumber\":\"A123456789\"}" -v'

Write-Host "執行命令: $curlCommand" -ForegroundColor Cyan
Invoke-Expression $curlCommand

Write-Host "`n🎉 curl測試完成！" -ForegroundColor Green



