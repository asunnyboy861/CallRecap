# Capabilities Configuration

## Analysis
Based on operation guide analysis, the following capabilities are required:

| Keyword Found | Capability Required |
|---------------|-------------------|
| "录音" / "recording" / "麦克风" / "microphone" | Microphone Access |
| "后台" / "background" / "Audio" | Background Modes (Audio) |
| "CallKit" / "通话检测" / "CXCallObserver" | CallKit |
| "iCloud" / "同步" / "CloudKit" | iCloud + CloudKit |
| "订阅" / "premium" / "Pro" / "购买" | In-App Purchase |
| "通知" / "notification" / "推送" | Push Notifications |
| "Face ID" / "Touch ID" / "生物识别" | LocalAuthentication |
| "Reminders" / "提醒" / "EventKit" | EventKit (Reminders) |
| "Widget" / "小组件" | WidgetKit |

## Auto-Configured Capabilities
| Capability | Status | Method |
|------------|--------|--------|
| Microphone Access | ✅ Will configure | NSMicrophoneUsageDescription in Info.plist |
| Background Modes (Audio) | ✅ Will configure | UIBackgroundModes in Info.plist |
| CallKit | ✅ Will configure | Framework import (no entitlement needed) |
| In-App Purchase | ✅ Will configure | StoreKit 2 (no special entitlement needed for code) |
| LocalAuthentication | ✅ Will configure | Framework import (no entitlement needed) |
| EventKit (Reminders) | ✅ Will configure | NSRemindersUsageDescription in Info.plist |
| WidgetKit | ✅ Will configure | Widget extension target |

## Manual Configuration Required
| Capability | Status | Steps |
|------------|--------|-------|
| iCloud + CloudKit | ⏳ Pending | 1. Enable iCloud capability in Xcode Signing & Capabilities 2. Create CloudKit container in Apple Developer Portal (com.zzoutuo.CallRecap) 3. Add CloudKit entitlement to .entitlements file |
| Push Notifications | ⏳ Pending | 1. Enable Push Notifications capability in Xcode 2. Configure APNS in Apple Developer Portal 3. No server-side push needed (local notifications only for this app) |

## No Configuration Needed
- Siri (not used in this app)
- HealthKit (not applicable)
- Location Services (not applicable)
- Camera/Photo Library (not applicable)
- Apple Watch (not in v1)
- Sign in with Apple (not used)

## Verification
- Build succeeded after configuration: Pending (will verify in build step)
- All entitlements correct: Pending
