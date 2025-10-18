# Firebase 配置模板

## 🔧 配置步驟

### 1. 創建 Firebase 項目後，您需要：

#### A. 下載配置文件
- **Android**: 下載 `google-services.json` 放到 `android/app/` 目錄
- **iOS**: 下載 `GoogleService-Info.plist` 放到 `ios/Runner/` 目錄

#### B. 更新 build.gradle 文件

**在 `android/build.gradle.kts` 中添加：**
```kotlin
buildscript {
    dependencies {
        classpath("com.google.gms:google-services:4.3.15")
    }
}
```

**在 `android/app/build.gradle.kts` 中添加：**
```kotlin
plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services") // 添加這行
}
```

#### C. 更新 firebase_options.dart

將您的實際配置替換到 `lib/firebase_options.dart` 中：

```dart
static const FirebaseOptions android = FirebaseOptions(
  apiKey: '您的-Android-API-Key',
  appId: '您的-Android-App-ID',
  messagingSenderId: '您的-Messaging-Sender-ID',
  projectId: '您的-Project-ID',
  storageBucket: '您的-Project-ID.appspot.com',
);

static const FirebaseOptions ios = FirebaseOptions(
  apiKey: '您的-iOS-API-Key',
  appId: '您的-iOS-App-ID',
  messagingSenderId: '您的-Messaging-Sender-ID',
  projectId: '您的-Project-ID',
  storageBucket: '您的-Project-ID.appspot.com',
  iosBundleId: 'com.example.new_bilibili_clone',
);
```

## 📱 套件名稱

**Android**: `com.example.new_bilibili_clone`
**iOS**: `com.example.new_bilibili_clone`

## 🔑 獲取 SHA-1 憑證指紋（用於 Google 登入）

在終端機中執行：
```bash
keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android
```

## 🚀 測試步驟

1. 配置完成後，執行：
```bash
flutter clean
flutter pub get
flutter run
```

2. 在真實設備上測試：
- 註冊功能
- 登入功能
- 頭像上傳
- 權限請求
