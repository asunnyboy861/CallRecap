# CallRecap - iOS Development Guide

## Executive Summary

**CallRecap** is an AI-powered call recording and smart notes app for iPhone that solves the three biggest pain points in the call recording market: iOS 18's forced recording announcement, exorbitant subscription pricing ($120-$571/year), and clunky 3-way calling workflows. By leveraging on-device Whisper transcription and Apple Intelligence summarization, CallRecap delivers private, affordable, and effortless call recording at $29.99/year — 95% cheaper than TapeACall.

**Target Audience**: Professionals, journalists, legal workers, and anyone who needs to record and review phone conversations in the US market (one-party consent states).

**Key Differentiators**:
- One-tap recording — no 3-way calling required
- On-device AI transcription (Whisper.cpp) — zero server dependency, full privacy
- AI-powered summaries with action item extraction — no competitor offers this at this price
- Recycle bin with 30-day retention — prevent accidental data loss
- $29.99/year or $79.99 lifetime — the only app offering a one-time purchase option

## Competitive Analysis

| App | Strengths | Weaknesses | Our Advantage |
|-----|-----------|------------|---------------|
| TapeACall | Most reliable on iPhone; AWS transcription 99% accuracy | $571.48/year; 3-way calling; server-side processing; buzzing audio | 95% cheaper; one-tap recording; on-device AI; no server dependency |
| Cube ACR | Basic recording + transcription; reasonable price | $119.88/year; "doesn't work" reviews; no AI summary; no recycle bin | AI summary + action items; recycle bin; local privacy; one-time purchase |
| Rev Call Recorder | Free recording; per-minute transcription ($0.25/min) | US only; expensive transcription; no AI summary; no offline mode | Flat pricing; on-device transcription; AI summary; works offline |
| Otter.ai | AI meeting notes; good transcription | $203.88/year; meeting-focused (not phone calls); server-side | Phone-call focused; on-device; 85% cheaper; one-time purchase option |
| iOS 18 Native | Free; built-in; basic transcription | Forced "this call will be recorded" announcement; no AI summary; region-locked (EU blocked) | No forced announcement; AI summary; action items; global availability |

## Feature Inventory (MANDATORY — Every Feature Must Be Listed)

### Primary Features

| # | Feature | User Operation Flow | Data Input | Processing | Data Output | Persistence | Acceptance Criteria |
|---|---------|--------------------|------------|------------|-------------|-------------|---------------------|
| 1 | Auto Call Recording | 1. User receives/makes call → 2. CallRecap auto-detects via CallKit → 3. Recording starts automatically → 4. Call ends → 5. Recording saved | Phone call audio (incoming + outgoing) | CXCallObserver detects call state → AVAudioSession captures audio → AAC encoding → M4A file | M4A audio file saved to Documents/Recordings/YYYY-MM/ | Core Data: Recording entity (id, filePath, date, duration, contactName, phoneNumber, callType) | Recording file exists after call; duration matches call length; file plays back correctly |
| 2 | Manual Recording | 1. User opens CallRecap → 2. Taps REC button → 3. Recording starts → 4. User taps stop → 5. Recording saved | User tap on REC button | AVAudioSession activated → AudioEngine captures mic → AAC encoding | M4A audio file + Recording entity in Core Data | Same as Feature 1 | REC button starts/stops recording; file saved; duration tracked |
| 3 | On-Device Transcription (Whisper) | 1. Recording completes → 2. Auto-triggers transcription → 3. Progress shown → 4. Transcript ready notification | M4A audio file | M4A → WAV conversion → whisper.cpp segmentation (30s chunks) → timestamp alignment → speaker diarization | TranscriptResult: fullText, segments with timestamps, language | Core Data: Recording.transcriptText, TranscriptSegment entities | Full transcript generated; timestamps aligned with audio; processing completes within 2x recording duration |
| 4 | AI Summary Generation | 1. Transcription completes → 2. Auto-triggers summary → 3. Summary appears in detail view | Transcript text | iOS 18+: Apple On-Device LLM → JSON summary; iOS 17: Local rules engine (keyword extraction) | CallSummary: overview, keyPoints, actionItems, sentiment, topics | Core Data: Recording.summaryJSON (encoded CallSummary) | One-sentence overview; 3-5 key points; action items with deadlines; sentiment classification |
| 5 | Recording Library | 1. User opens CallRecap → 2. Sees grouped list (Today/Yesterday/Earlier) → 3. Search by keyword → 4. Tap recording → 5. View detail | User navigation + search text | Core Data fetch with sort descriptors + NSPredicate for search | Grouped recording list with summary previews | Core Data query results | Recordings grouped by date; search filters results; each row shows contact, duration, summary preview |
| 6 | Recording Detail View | 1. User taps recording → 2. Three-tab view: Summary / Transcript / Play → 3. Switch between tabs | Recording entity from Core Data | Load summary JSON, transcript segments, audio file | Summary tab: overview + key points + action items; Transcript tab: timestamped text; Play tab: audio player with sync | Read from Core Data + file system | All three tabs render correctly; audio plays; transcript scrolls with playback |
| 7 | Action Items & Reminders | 1. User views summary → 2. Sees action items → 3. Taps "Add to Reminders" → 4. Items added to Apple Reminders | Action items from CallSummary | EventKit framework → create EKReminder for each action item | Reminders created in user's default Reminders list | Apple Reminders (EventKit) | Action items appear in Apple Reminders app; deadline preserved if available |
| 8 | Recycle Bin | 1. User swipes to delete recording → 2. Recording moves to trash → 3. User can restore within 30 days → 4. Auto-permanent delete after 30 days | Swipe-to-delete gesture | Set Recording.isDeleted=true, deletedAt=Date() → Background task cleans expired items | Recording hidden from main list; visible in trash section | Core Data: isDeleted, deletedAt fields | Deleted recordings appear in trash; restore works; auto-cleanup after 30 days |
| 9 | iCloud Sync | 1. Recording saved → 2. Metadata synced via CloudKit → 3. Audio file synced on WiFi → 4. Available on all devices | Recording entity changes | CloudKit CKRecord sync → conflict resolution (latest wins) → audio file upload to iCloud Drive | Synced data available on all user's devices | CloudKit + iCloud Drive | Recording appears on second device within minutes; no data loss on conflict |
| 10 | Settings & Preferences | 1. User taps Settings tab → 2. Configure: audio quality, auto-record, model size, Face ID lock, export format | User selections | UserDefaults + Core Data updates | Settings persisted across app launches | UserDefaults + Core Data | Settings persist; auto-record toggle works; model download triggers correctly |
| 11 | Export & Share | 1. User taps Share in detail view → 2. Choose format (PDF/SRT/TXT/Audio) → 3. Share sheet appears → 4. Send to destination | Recording + transcript + summary data | Generate PDF/SRT/TXT from data → UIActivityViewController | Shared file in chosen format | Temporary file in tmp/ directory | Export creates valid files; share sheet shows correct options; all formats render properly |
| 12 | Onboarding & Permissions | 1. First launch → 2. 3-page welcome → 3. Microphone permission → 4. Call detection permission → 5. Notification permission → 6. AI model download | First launch detection | Permission requests (AVAudioSession, CXCallObserver, UNUserNotificationCenter) → Model download from HuggingFace | Permissions granted; base.en model downloaded | UserDefaults: onboardingComplete; App Support: WhisperModels/ | All permissions requested sequentially; model downloads successfully; onboarding shows only once |
| 13 | Paywall / Subscription | 1. User taps Pro feature → 2. Paywall appears → 3. Choose plan (Monthly $3.99 / Yearly $29.99 / Lifetime $79.99) → 4. 7-day free trial → 5. Purchase via StoreKit | User tap on Pro feature or upgrade button | StoreKit 2 transaction → verify receipt → update premium status | Premium features unlocked; subscription active | StoreKit transaction + UserDefaults premium flag | Paywall shows correct pricing; trial starts; premium features unlock after purchase; restore purchases works |
| 14 | Face ID / Touch ID Lock | 1. User enables lock in Settings → 2. App requires biometric on launch → 3. Authenticated → 4. Access granted | Face ID / Touch ID scan | LocalAuthentication framework → LAContext.evaluatePolicy | App locked/unlocked state | UserDefaults: biometricLockEnabled | App requires biometric on launch when enabled; falls back to passcode; toggle works |
| 15 | Widget (Home Screen) | 1. User adds CallRecap widget → 2. Widget shows REC button + today's count → 3. Tap REC → 4. App opens in recording mode | Widget tap | WidgetKit timeline provider → deep link to recording | Widget displays recording count + quick action | WidgetKit timeline | Widget updates; REC button launches app; count accurate |

### Sub-Features & Detail Interactions

| # | Parent Feature | Sub-Feature | Detail Description | Interaction Pattern |
|---|---------------|-------------|-------------------|--------------------|
| 1.1 | Auto Call Recording | Call state detection | CXCallObserver monitors incoming/outgoing calls, tracks idle→dialing→connected→disconnected state machine | Automatic, no user interaction |
| 1.2 | Auto Call Recording | Recording banner | Thin banner at top of screen shows "Recording" with red dot during active call recording | Visual indicator only |
| 1.3 | Auto Call Recording | Background recording | Audio background mode keeps recording active when app goes to background | Automatic |
| 3.1 | On-Device Transcription | Model management | Download base.en (74MB) on first launch; optional small.en (244MB) download in Settings | Settings toggle + progress bar |
| 3.2 | On-Device Transcription | Transcription progress | Progress bar shown in recording detail while transcription is running | Visual indicator |
| 3.3 | On-Device Transcription | Speaker diarization | Separate speakers in transcript based on audio channel (stereo recording) | Automatic, shown in transcript view |
| 4.1 | AI Summary Generation | Sentiment analysis | Classify call as Positive/Neutral/Negative/Mixed based on word patterns | Shown as badge in summary view |
| 4.2 | AI Summary Generation | Topic extraction | Extract key topics (budget, project, meeting, etc.) from transcript | Shown as tags in summary view |
| 5.1 | Recording Library | Smart grouping | Group recordings by Today / Yesterday / This Week / Earlier | Automatic list sectioning |
| 5.2 | Recording Library | Search | Full-text search across transcript content and contact names | Search bar with real-time filtering |
| 5.3 | Recording Library | Swipe actions | Swipe left to delete; swipe right to favorite | Swipe gesture |
| 6.1 | Recording Detail View | Playback with sync | Audio playback with transcript text highlighting current segment | Tap play button; auto-scroll transcript |
| 6.2 | Recording Detail View | Summary card | Overview + key points + action items in scrollable card layout | Scroll, tap action items |
| 8.1 | Recycle Bin | Restore recording | Tap restore to move recording back to main list | Tap restore button |
| 8.2 | Recycle Bin | Permanent delete | Tap delete permanently to remove recording and audio file | Tap delete button with confirmation |
| 13.1 | Paywall | Free tier limits | 5 transcriptions per month; no AI summary; no action items; no export | Counter shown in Settings |
| 13.2 | Paywall | Upgrade prompt | When free limit reached, show upgrade prompt with pricing comparison | Alert with upgrade button |
| 13.3 | Paywall | Restore purchases | Button to restore previous purchases on new device | Tap restore button |

### Cross-Feature Dependencies

| Dependency | Source Feature | Target Feature | Data Passed | Trigger Condition |
|------------|---------------|----------------|-------------|-------------------|
| Recording → Transcription | Auto/Manual Recording | On-Device Transcription | M4A file URL | Recording completes (call ends or user stops) |
| Transcription → Summary | On-Device Transcription | AI Summary Generation | Transcript full text | Transcription completes successfully |
| Summary → Action Items | AI Summary Generation | Action Items & Reminders | CallSummary.actionItems array | User taps "Add to Reminders" |
| Recording → Library | Auto/Manual Recording | Recording Library | Recording entity | Recording saved to Core Data |
| Recording → Detail | Recording Library | Recording Detail View | Recording entity (Core Data NSManagedObjectID) | User taps recording row |
| Recording → Trash | Recording Library | Recycle Bin | Recording.isDeleted=true | User swipes to delete |
| Recording → Sync | Auto/Manual Recording | iCloud Sync | Recording entity changes | CloudKit auto-sync trigger |
| Settings → Recording | Settings & Preferences | Auto Call Recording | autoRecordEnabled (Bool) | User toggles auto-record |
| Settings → Transcription | Settings & Preferences | On-Device Transcription | selectedModel (ModelSize) | User changes model in settings |
| Paywall → Features | Paywall / Subscription | All Pro features | isPremium (Bool) | User subscribes or purchases |

## Apple Design Guidelines Compliance

- **HIG Layout**: Tab-based navigation with max 5 tabs (Recordings, Search, Settings); 44pt minimum touch targets; SF Pro font family
- **HIG Color**: System colors with dynamic light/dark mode; red for recording indicator; semantic colors for all UI elements
- **HIG Privacy**: Microphone usage description required; CallKit integration requires entitlement; all AI processing on-device
- **HIG Accessibility**: VoiceOver labels on all interactive elements; Dynamic Type support; Reduce Motion respect; high contrast support
- **HIG Feedback**: Haptic feedback on recording start/stop; progress indicators for transcription; success/failure toasts
- **HIG Navigation**: NavigationStack for hierarchical navigation; sheet presentations for modals; standard back button behavior
- **App Store Review 2.1**: App completeness — microphone permission must be clearly justified; CallKit usage must follow guidelines
- **App Store Review 3.1.2**: Subscription pricing — must include Privacy Policy link, Terms of Use link, and auto-renewal disclosure in paywall
- **App Store Review 5.1.1**: Data collection — minimal data collection; on-device processing; no server-side audio storage

## Technical Architecture

- **Language**: Swift 5.9+
- **Framework**: SwiftUI (primary UI), UIKit (AVAudioSession configuration), CallKit (call detection)
- **Data**: Core Data (local persistence) + CloudKit (iCloud sync) + UserDefaults (preferences)
- **Audio**: AVFoundation (recording/playback) + AudioToolbox (format conversion)
- **AI Transcription**: whisper.cpp via WhisperCppKit Swift Package (on-device)
- **AI Summary**: Apple Intelligence (iOS 18+) / Local rules engine (iOS 17 fallback)
- **Networking**: URLSession (model download only)
- **Biometric**: LocalAuthentication (Face ID / Touch ID)
- **Reminders**: EventKit (action item integration)
- **Widgets**: WidgetKit (home screen quick actions)
- **Payments**: StoreKit 2 (subscriptions + one-time purchase)

## Module Structure

```
CallRecap/
├── CallRecapApp.swift
├── Models/
│   ├── Recording.swift          (Core Data NSManagedObject)
│   ├── TranscriptSegment.swift  (Codable struct)
│   ├── CallSummary.swift        (Codable struct with ActionItem, Sentiment)
│   └── CallInfo.swift           (CallKit call info)
├── Services/
│   ├── CallDetectionService.swift   (CXCallObserver wrapper)
│   ├── AudioRecordingEngine.swift   (AVAudioEngine + AVAudioSession)
│   ├── TranscriptionEngine.swift    (whisper.cpp wrapper)
│   ├── SummaryEngine.swift          (Apple Intelligence + local fallback)
│   ├── DataSyncService.swift        (CloudKit sync manager)
│   ├── RemindersService.swift       (EventKit integration)
│   ├── ModelDownloadService.swift   (Whisper model download)
│   └── SubscriptionManager.swift    (StoreKit 2)
├── Views/
│   ├── Onboarding/
│   │   ├── OnboardingView.swift
│   │   └── PermissionStepView.swift
│   ├── Recording/
│   │   ├── RecordingListView.swift
│   │   ├── RecordingRow.swift
│   │   └── RecordingDetailView.swift
│   ├── Summary/
│   │   ├── SummaryView.swift
│   │   └── ActionItemsView.swift
│   ├── Transcript/
│   │   └── TranscriptView.swift
│   ├── Player/
│   │   └── AudioPlayerView.swift
│   ├── Trash/
│   │   └── TrashView.swift
│   ├── Settings/
│   │   └── SettingsView.swift
│   ├── Paywall/
│   │   └── PaywallView.swift
│   └── Components/
│       ├── RecordingIndicator.swift
│       └── SearchBar.swift
├── ViewModels/
│   ├── RecordingListViewModel.swift
│   ├── RecordingDetailViewModel.swift
│   ├── TranscriptionViewModel.swift
│   └── SettingsViewModel.swift
├── Extensions/
│   ├── Color+Theme.swift
│   ├── Date+Formatting.swift
│   └── UserDefaults+Keys.swift
├── Resources/
│   ├── Assets.xcassets
│   └── Localizable.strings
└── Widget/
    ├── CallRecapWidget.swift
    └── CallRecapWidgetBundle.swift
```

## Data Flow Diagram (MANDATORY — Every Feature's Data Lifecycle)

```
Feature 1: Auto Call Recording
┌───────────────────────────────────────────────────────────┐
│  User Input                                                │
│  └── Phone call (incoming/outgoing) detected by system    │
│       │                                                    │
│  ViewModel Processing                                      │
│  └── CallDetectionService.swift                            │
│      ├── CXCallObserver.callChanged handler                │
│      ├── State: idle → dialing → connected → disconnected │
│      └── On connected: notify AudioRecordingEngine         │
│       │                                                    │
│  Model/Persistence                                         │
│  └── AudioRecordingEngine.swift                            │
│      ├── AVAudioSession.setCategory(.playAndRecord)        │
│      ├── AVAudioEngine.inputNode.installTap → write buffer │
│      ├── AVAudioFile writes to M4A (AAC 44.1kHz stereo)   │
│      └── On disconnected: stop recording, save to Core Data│
│       │                                                    │
│  Display Output                                            │
│  └── RecordingIndicator (red pulsing dot + "Recording")    │
│  └── Notification: "Call recorded — 12:34 with John"       │
│       │                                                    │
│  Cross-Feature Output                                      │
│  └── Recording entity → triggers TranscriptionEngine       │
└───────────────────────────────────────────────────────────┘

Feature 3: On-Device Transcription
┌───────────────────────────────────────────────────────────┐
│  User Input                                                │
│  └── None (auto-triggered after recording)                 │
│       │                                                    │
│  ViewModel Processing                                      │
│  └── TranscriptionViewModel.swift                          │
│      ├── Observe Recording.isTranscribed flag              │
│      ├── Show progress bar during transcription            │
│      └── Update UI when complete                           │
│       │                                                    │
│  Model/Persistence                                         │
│  └── TranscriptionEngine.swift                             │
│      ├── Load M4A file → convert to WAV (PCM 16-bit)      │
│      ├── Load whisper.cpp model (base.en or small.en)      │
│      ├── Process in 30-second segments                     │
│      ├── whisper_full() → text + timestamps                │
│      ├── Save TranscriptSegments to Core Data              │
│      └── Update Recording.isTranscribed = true             │
│       │                                                    │
│  Display Output                                            │
│  └── TranscriptView: timestamped text with speaker labels  │
│  └── Notification: "Summary ready — Call with John"        │
│       │                                                    │
│  Cross-Feature Output                                      │
│  └── Transcript full text → triggers SummaryEngine         │
└───────────────────────────────────────────────────────────┘

Feature 4: AI Summary Generation
┌───────────────────────────────────────────────────────────┐
│  User Input                                                │
│  └── None (auto-triggered after transcription)             │
│       │                                                    │
│  ViewModel Processing                                      │
│  └── RecordingDetailViewModel.swift                        │
│      ├── Observe Recording.isSummarized flag               │
│      ├── Decode summaryJSON → CallSummary struct           │
│      └── Render summary, key points, action items          │
│       │                                                    │
│  Model/Persistence                                         │
│  └── SummaryEngine.swift                                   │
│      ├── iOS 18+: Apple On-Device LLM → JSON output       │
│      ├── iOS 17: Local rules engine (keyword extraction)   │
│      ├── JSON encode CallSummary → Recording.summaryJSON   │
│      └── Update Recording.isSummarized = true              │
│       │                                                    │
│  Display Output                                            │
│  └── SummaryView: overview + key points + action items     │
│  └── Sentiment badge (Positive/Neutral/Negative/Mixed)     │
│  └── Topic tags                                            │
│       │                                                    │
│  Cross-Feature Output                                      │
│  └── ActionItems → RemindersService (on user tap)          │
│  └── Summary preview → RecordingListView row subtitle      │
└───────────────────────────────────────────────────────────┘

Feature 5: Recording Library
┌───────────────────────────────────────────────────────────┐
│  User Input                                                │
│  └── App launch / navigation to Recordings tab             │
│  └── Search text input                                     │
│       │                                                    │
│  ViewModel Processing                                      │
│  └── RecordingListViewModel.swift                          │
│      ├── Fetch recordings from Core Data                   │
│      ├── Sort by date, group by Today/Yesterday/Earlier    │
│      ├── Filter by search text (contact name + transcript) │
│      └── Publish grouped recordings to view                │
│       │                                                    │
│  Model/Persistence                                         │
│  └── Core Data: Recording entity                           │
│      ├── NSFetchRequest with sort by date descending       │
│      ├── NSPredicate for search: contactName CONTAINS[cd]  │
│      └── Filter: isDeleted == false                        │
│       │                                                    │
│  Display Output                                            │
│  └── RecordingListView: grouped list with summary previews │
│  └── Each row: contact, duration, summary preview, time    │
│       │                                                    │
│  Cross-Feature Output                                      │
│  └── Selected recording → RecordingDetailView              │
└───────────────────────────────────────────────────────────┘

Feature 7: Action Items & Reminders
┌───────────────────────────────────────────────────────────┐
│  User Input                                                │
│  └── Tap "Add to Reminders" button in SummaryView          │
│       │                                                    │
│  ViewModel Processing                                      │
│  └── RecordingDetailViewModel.swift                        │
│      ├── Decode CallSummary from Recording.summaryJSON     │
│      ├── Extract actionItems array                         │
│      └── Call RemindersService.createReminders()           │
│       │                                                    │
│  Model/Persistence                                         │
│  └── RemindersService.swift                                │
│      ├── EKEventStore.requestFullAccessToReminders()       │
│      ├── Create EKReminder for each ActionItem             │
│      ├── Set title = ActionItem.text                       │
│      ├── Set dueDate = ActionItem.deadline (if present)    │
│      └── Save to default calendar                          │
│       │                                                    │
│  Display Output                                            │
│  └── Success toast: "Added X items to Reminders"           │
│  └── Checkmark animation on action items                   │
│       │                                                    │
│  Cross-Feature Output                                      │
│  └── Items visible in Apple Reminders app                  │
└───────────────────────────────────────────────────────────┘

Feature 8: Recycle Bin
┌───────────────────────────────────────────────────────────┐
│  User Input                                                │
│  └── Swipe left on recording → tap Delete                  │
│  └── In Trash: tap Restore or Delete Permanently           │
│       │                                                    │
│  ViewModel Processing                                      │
│  └── RecordingListViewModel.swift                          │
│      ├── On delete: set isDeleted=true, deletedAt=now      │
│      ├── On restore: set isDeleted=false, deletedAt=nil    │
│      └── On permanent delete: delete from Core Data + file │
│       │                                                    │
│  Model/Persistence                                         │
│  └── Core Data: Recording.isDeleted, Recording.deletedAt   │
│      ├── Main list: isDeleted == false                     │
│      ├── Trash list: isDeleted == true                     │
│      └── Background task: delete where deletedAt < 30 days│
│       │                                                    │
│  Display Output                                            │
│  └── Recording removed from main list with slide animation │
│  └── Recording appears in Trash section                    │
│       │                                                    │
│  Cross-Feature Output                                      │
│  └── None (self-contained)                                 │
└───────────────────────────────────────────────────────────┘

Feature 13: Paywall / Subscription
┌───────────────────────────────────────────────────────────┐
│  User Input                                                │
│  └── Tap Pro feature (unlimited transcription, AI summary) │
│  └── Tap upgrade button in Settings                        │
│       │                                                    │
│  ViewModel Processing                                      │
│  └── SubscriptionManager.swift (StoreKit 2)                │
│      ├── Check isPremium status from Transaction.updates   │
│      ├── Present PaywallView with 3 plan options           │
│      ├── Process purchase via Product.purchase()           │
│      └── Update isPremium flag on success                  │
│       │                                                    │
│  Model/Persistence                                         │
│  └── StoreKit 2 (system-managed)                           │
│      ├── Products: monthly ($3.99), yearly ($29.99),       │
│      │   lifetime ($79.99)                                 │
│      ├── Transaction history for restore                   │
│      └── Subscription status checking                      │
│       │                                                    │
│  Display Output                                            │
│  └── PaywallView: pricing comparison + plan selection      │
│  └── Pro features unlocked immediately after purchase      │
│       │                                                    │
│  Cross-Feature Output                                      │
│  └── isPremium flag gates all Pro features app-wide        │
└───────────────────────────────────────────────────────────┘
```

## Implementation Flow

1. Create Xcode project with SwiftUI + Core Data, configure entitlements (microphone, background audio, CallKit, iCloud, CloudKit)
2. Integrate WhisperCppKit Swift Package for on-device transcription
3. Implement CallDetectionService with CXCallObserver for call state monitoring
4. Implement AudioRecordingEngine with AVAudioSession + AVAudioEngine for recording
5. Implement TranscriptionEngine wrapping whisper.cpp for on-device transcription
6. Implement SummaryEngine with Apple Intelligence (iOS 18+) and local rules fallback (iOS 17)
7. Build Core Data model (Recording entity with transcript/summary fields)
8. Build RecordingListView with grouped list, search, and swipe actions
9. Build RecordingDetailView with Summary/Transcript/Play tabs
10. Implement RemindersService for action item integration via EventKit
11. Implement Recycle Bin with 30-day auto-cleanup
12. Implement CloudKit sync for cross-device data
13. Build Settings view with all configuration options
14. Build PaywallView with StoreKit 2 integration
15. Implement Face ID/Touch ID lock via LocalAuthentication
16. Build WidgetKit home screen widget
17. Build Onboarding flow with permission requests
18. Implement Export/Share functionality (PDF, SRT, TXT, Audio)
19. Comprehensive testing (unit, UI, performance)
20. App Store submission preparation

## UI/UX Design Specifications

- **Color Scheme**:
  - Light: Primary #007AFF, Background #F2F2F7, Card #FFFFFF, Text #1C1C1E
  - Dark: Primary #0A84FF, Background #000000 (OLED), Card #1C1C1E, Text #F2F2F7
  - Recording indicator: Red #FF3B30 (light) / #FF453A (dark) with pulse animation
- **Typography**: SF Pro Display for titles (34pt/28pt), SF Pro Text for body (17pt), SF Mono for duration display (48pt)
- **Layout**: Inset grouped list style; 16pt horizontal margins; 12pt vertical spacing between rows; tab bar with 3 items (Recordings, Search, Settings)
- **Animations**: Spring animation for recording start/stop (0.3s); easeOut for summary card slide-in (0.5s); linear for transcription progress; spring for action item checkmark (0.4s)
- **Dark Mode**: OLED black (#000000) background; pure black maximizes contrast and saves battery on OLED iPhones
- **Accessibility**: VoiceOver labels on all controls; Dynamic Type support; minimum 44x44pt touch targets; WCAG AA contrast ratios

## Code Generation Rules

- One feature per module, high cohesion, low coupling
- Semantic naming, clear file structure
- Never add comments in code unless asked
- Apple native first: prioritize SwiftUI/Swift/AVFoundation/CallKit
- Open source first: integrate WhisperCppKit for whisper.cpp
- MVVM architecture: Views → ViewModels → Services → Core Data
- async/await for all asynchronous operations
- Combine for reactive state management
- All AI processing on-device by default; network only for model download
- StoreKit 2 for all in-app purchases
- Core Data with CloudKit for data persistence and sync

## Build & Deployment Checklist

- [ ] Xcode project created with SwiftUI + Core Data
- [ ] Entitlements configured: Microphone, Background Audio, CallKit, iCloud, CloudKit
- [ ] WhisperCppKit Swift Package integrated
- [ ] Info.plist: NSMicrophoneUsageDescription, UIBackgroundModes (audio)
- [ ] Core Data model with Recording entity and all fields
- [ ] All 15 primary features implemented and tested
- [ ] StoreKit 2 subscription products configured in App Store Connect
- [ ] Privacy Policy page deployed
- [ ] Terms of Use page deployed
- [ ] App Store metadata prepared (keytext.md)
- [ ] TestFlight beta testing completed
- [ ] App Store submission ready

## App Store Compliance — AI Features

### Guideline 2.1(a) — App Completeness
This app uses on-device AI (whisper.cpp) for transcription and Apple Intelligence for summaries. No external API keys required for core functionality.

**For iOS 17 fallback**: Local rules engine provides basic summary without any API. OpenAI API is optional (BYO key) for enhanced summaries.

**Required Actions**:
1. App Review can test all features without any API key configuration
2. On-device transcription works out of the box after model download
3. Local rules engine provides summary on iOS 17 without any external service
4. OpenAI BYO key is purely optional enhancement, not required for app functionality

## App Store Compliance — Subscriptions

### Guideline 3.1.2(c) — Subscription Information
Apple REQUIRES the following in the Paywall view:
- Functional link to Privacy Policy
- Functional link to Terms of Use (EULA)
- Subscription title, length, and price
- Auto-renewal disclosure text

### Free Tier + Subscription Model
- Free tier: Unlimited recording + 5 transcriptions/month + basic playback
- Subscription value: "Unlock Pro Features" — unlimited transcription, AI summaries, action items, export
- Paywall feature list: Lead with app features (unlimited transcription, AI summary, action items, export)
- 7-day free trial for yearly plan
