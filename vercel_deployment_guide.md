# Vercel 部署指南

## 🌐 步驟1：準備Flutter Web構建

### 1.1 構建Flutter Web
```bash
flutter build web --release
```

### 1.2 檢查構建輸出
構建完成後，檢查 `build/web/` 目錄是否包含：
- `index.html`
- `main.dart.js`
- `assets/` 目錄

## 🚀 步驟2：部署到Vercel

### 方法A：使用Vercel CLI（推薦）

1. 安裝Vercel CLI：
```bash
npm install -g vercel
```

2. 登入Vercel：
```bash
vercel login
```

3. 部署項目：
```bash
vercel --prod
```

### 方法B：使用GitHub集成

1. 訪問 [Vercel](https://vercel.com)
2. 使用GitHub登入
3. 點擊 "New Project"
4. 選擇你的 `new_bilibili_clone` 倉庫
5. 配置構建設置：
   - **Framework Preset**: Other
   - **Build Command**: `flutter build web --release`
   - **Output Directory**: `build/web`
   - **Install Command**: `flutter pub get`

## ⚙️ 步驟3：配置環境變數

在Vercel項目設置中添加：

```bash
# 後端API URL
REACT_APP_API_URL=https://your-app.railway.app/api

# 或者如果使用Flutter環境變數
FLUTTER_API_URL=https://your-app.railway.app/api
```

## 🔧 步驟4：更新API配置

更新 `lib/services/real_api_service.dart`：

```dart
class RealApiService {
  // 使用環境變數或直接設置生產URL
  static const String baseUrl = String.fromEnvironment(
    'API_URL',
    defaultValue: 'https://your-app.railway.app/api'
  );
}
```

## 📱 步驟5：測試部署

1. 訪問你的Vercel URL
2. 測試所有功能：
   - 用戶註冊/登入
   - 文章列表
   - 搜索功能
   - 發布文章

## 🔄 步驟6：設置自定義域名（可選）

1. 在Vercel項目設置中
2. 點擊 "Domains"
3. 添加你的自定義域名
4. 配置DNS記錄

## ✅ 完成！

你的Flutter Web應用現在已經部署到Vercel！
