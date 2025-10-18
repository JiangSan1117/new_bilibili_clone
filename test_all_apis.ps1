# 🧪 想享APP API完整測試腳本

Write-Host "🚀 想享APP後端API測試開始..." -ForegroundColor Green
Write-Host "📍 服務器地址: http://localhost:3000" -ForegroundColor Cyan
Write-Host ""

# 測試1: 健康檢查
Write-Host "1️⃣ 測試健康檢查..." -ForegroundColor Yellow
try {
    $health = Invoke-RestMethod -Uri "http://localhost:3000/health" -Method GET
    Write-Host "✅ 健康檢查成功" -ForegroundColor Green
    Write-Host "   狀態: $($health.status)" -ForegroundColor White
    Write-Host "   運行時間: $([math]::Round($health.uptime/60, 2)) 分鐘" -ForegroundColor White
} catch {
    Write-Host "❌ 健康檢查失敗: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

Write-Host ""

# 測試2: API文檔
Write-Host "2️⃣ 測試API文檔..." -ForegroundColor Yellow
try {
    $docs = Invoke-RestMethod -Uri "http://localhost:3000/api/docs" -Method GET
    Write-Host "✅ API文檔獲取成功" -ForegroundColor Green
    Write-Host "   版本: $($docs.version)" -ForegroundColor White
    Write-Host "   可用端點: $($docs.endpoints.Count) 個" -ForegroundColor White
} catch {
    Write-Host "❌ API文檔獲取失敗: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host ""

# 測試3: 用戶註冊
Write-Host "3️⃣ 測試用戶註冊..." -ForegroundColor Yellow
$registerData = @{
    email = "test@example.com"
    password = "123456"
    nickname = "測試用戶"
    realName = "王小明"
    idCardNumber = "A123456789"
} | ConvertTo-Json

try {
    $registerResponse = Invoke-RestMethod -Uri "http://localhost:3000/api/auth/register" -Method POST -Body $registerData -ContentType "application/json"
    Write-Host "✅ 用戶註冊成功" -ForegroundColor Green
    Write-Host "   訊息: $($registerResponse.message)" -ForegroundColor White
    Write-Host "   用戶ID: $($registerResponse.user.id)" -ForegroundColor White
    Write-Host "   暱稱: $($registerResponse.user.nickname)" -ForegroundColor White
    Write-Host "   會員等級: $($registerResponse.user.levelNum)" -ForegroundColor White
    
    # 保存Token用於後續測試
    $global:testToken = $registerResponse.token
    Write-Host "   Token: $($global:testToken.Substring(0,20))..." -ForegroundColor Cyan
} catch {
    Write-Host "❌ 用戶註冊失敗: $($_.Exception.Message)" -ForegroundColor Red
    if ($_.Exception.Response) {
        $statusCode = $_.Exception.Response.StatusCode
        Write-Host "   狀態碼: $statusCode" -ForegroundColor Red
    }
}

Write-Host ""

# 測試4: 用戶登入
Write-Host "4️⃣ 測試用戶登入..." -ForegroundColor Yellow
$loginData = @{
    email = "test@example.com"
    password = "123456"
} | ConvertTo-Json

try {
    $loginResponse = Invoke-RestMethod -Uri "http://localhost:3000/api/auth/login" -Method POST -Body $loginData -ContentType "application/json"
    Write-Host "✅ 用戶登入成功" -ForegroundColor Green
    Write-Host "   訊息: $($loginResponse.message)" -ForegroundColor White
    Write-Host "   文章數: $($loginResponse.user.posts)" -ForegroundColor White
    Write-Host "   粉絲數: $($loginResponse.user.followers)" -ForegroundColor White
    Write-Host "   關注數: $($loginResponse.user.following)" -ForegroundColor White
    Write-Host "   獲讚數: $($loginResponse.user.likes)" -ForegroundColor White
} catch {
    Write-Host "❌ 用戶登入失敗: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host ""

# 測試5: 獲取用戶資料
if ($global:testToken) {
    Write-Host "5️⃣ 測試獲取用戶資料..." -ForegroundColor Yellow
    $headers = @{
        "Authorization" = "Bearer $($global:testToken)"
        "Content-Type" = "application/json"
    }
    
    try {
        $profileResponse = Invoke-RestMethod -Uri "http://localhost:3000/api/auth/profile" -Method GET -Headers $headers
        Write-Host "✅ 獲取用戶資料成功" -ForegroundColor Green
        Write-Host "   真實姓名: $($profileResponse.user.realName)" -ForegroundColor White
        Write-Host "   手機號碼: $($profileResponse.user.phone)" -ForegroundColor White
        Write-Host "   所在地: $($profileResponse.user.location)" -ForegroundColor White
        Write-Host "   認證狀態: $($profileResponse.user.verificationStatus)" -ForegroundColor White
        Write-Host "   會員類型: $($profileResponse.user.membershipType)" -ForegroundColor White
    } catch {
        Write-Host "❌ 獲取用戶資料失敗: $($_.Exception.Message)" -ForegroundColor Red
    }
} else {
    Write-Host "5️⃣ 跳過獲取用戶資料測試 (沒有Token)" -ForegroundColor Gray
}

Write-Host ""

# 測試總結
Write-Host "🎉 API測試完成！" -ForegroundColor Green
Write-Host "💡 提示:" -ForegroundColor Cyan
Write-Host "   - 所有測試都在模擬模式下運行" -ForegroundColor White
Write-Host "   - 數據不會持久化保存" -ForegroundColor White
Write-Host "   - 如需真實數據庫，請安裝MongoDB" -ForegroundColor White
Write-Host ""
Write-Host "📱 下一步建議:" -ForegroundColor Cyan
Write-Host "   1. 在Flutter應用中集成這些API" -ForegroundColor White
Write-Host "   2. 實裝文章發布和搜索功能" -ForegroundColor White
Write-Host "   3. 添加互動功能（點讚、評論、關注）" -ForegroundColor White



