# SpamSentry - iOS Development Guide

## Executive Summary

SpamSentry is a privacy-first, on-device spam call and message blocker for iPhone. Unlike competitors that upload user contacts and call logs to build their databases, SpamSentry processes everything locally on the device, ensuring zero data leakage. Priced at a one-time $3.99 purchase, it undercuts subscription-based competitors by 10-30x while delivering superior functionality through intelligent CallDirectory Extension management, community-verified blocklists, and fine-grained blocking rules.

**Target Audience**: US iPhone users aged 25-65 who receive frequent spam/robocalls and value privacy.

**Key Differentiators**:
- 100% on-device processing - zero data upload, zero privacy risk
- One-time purchase $3.99 vs $36-120/year subscriptions
- Smart Extension health monitoring with auto-repair
- Fine-grained blocking rules (area code, wildcard, time-based)
- Community-verified blocklists with PGP signature validation
- Built-in MessageFilter Extension for SMS spam

## Competitive Analysis

| App | Strengths | Weaknesses | Our Advantage |
|-----|-----------|------------|---------------|
| Truecaller | 450M+ users, caller ID, AI assistant | $9.99/mo subscription, uploads contacts/call logs, data breaches | Zero data upload, one-time purchase, no privacy risk |
| RoboKiller | 99% spam detection, answer bot | $4.99/mo subscription, large app size (202MB), extension failures | Extension health monitoring, 10x cheaper, lightweight |
| Hiya | Carrier partnerships, real-time alerts | Uploads call data, extension bugs known to Apple, limited free tier | On-device only, auto-repair extension, full features included |
| Nomorobo | Good robocall blocking, allows important calls | Blocks legitimate calls, no fine-grained control, subscription | Contact protection, area code rules, temporary pause |
| VetoSpam | Privacy-focused marketing | Still new, limited features, subscription model | True on-device, more features, one-time price |

## Apple Design Guidelines Compliance

- **CallKit Integration**: Follow Apple's CallDirectory Extension template for identifying and blocking calls
- **App Extension Lifecycle**: Handle `beginRequest(with:)` correctly, support incremental updates
- **Privacy**: No data collection, no analytics, no third-party frameworks - full App Store Review compliance
- **Human Interface Guidelines**: Use native SwiftUI components, system colors, standard navigation patterns
- **App Extensions**: Proper App Group container for shared data between main app and extensions
- **MessageFilter**: Follow MessageFilter framework guidelines for SMS filtering
- **Background Processing**: No background modes needed - CallDirectory Extension is system-managed

## Technical Architecture

- **Language**: Swift 5.9+
- **Framework**: SwiftUI (primary), CallKit, MessageFilter
- **Data**: SQLite (via GRDB or raw sqlite3) for blocklist storage, UserDefaults + App Group for shared state
- **Networking**: URLSession for blocklist sync from GitHub repositories
- **Security**: PGP signature verification for blocklist integrity
- **Architecture Pattern**: MVVM (Model-View-ViewModel)

## Module Structure

```
SpamSentry/
├── SpamSentry/                          # Main App Target
│   ├── SpamSentryApp.swift              # @main entry point
│   ├── Views/
│   │   ├── MainTabView.swift            # Tab navigation
│   │   ├── DashboardView.swift          # Home dashboard
│   │   ├── BlocklistView.swift          # Blocklist management
│   │   ├── SettingsView.swift           # Settings page
│   │   ├── NumberSearchView.swift       # Number lookup
│   │   ├── ContactSupportView.swift     # Support form
│   │   └── Components/
│   │       ├── ShieldBadge.swift        # Protection status badge
│   │       ├── BlocklistRow.swift       # Blocklist entry row
│   │       └── HealthIndicator.swift    # Extension health indicator
│   ├── ViewModels/
│   │   ├── BlockerViewModel.swift       # Core blocking logic
│   │   ├── SyncViewModel.swift          # Blocklist sync logic
│   │   └── StatsViewModel.swift         # Statistics logic
│   ├── Services/
│   │   ├── ExtensionHealthService.swift # Extension health monitoring
│   │   ├── ContactProtectionService.swift # Contact exclusion
│   │   └── NotificationService.swift    # Local notifications
│   └── Models/
│       ├── BlockedNumber.swift          # Blocked number model
│       ├── BlockRule.swift              # Blocking rule model
│       └── SyncRecord.swift             # Sync record model
├── SpamSentryCallBlocker/               # CallDirectory Extension Target
│   ├── CallDirectoryHandler.swift       # Call blocking core
│   └── Info.plist
├── SpamSentryMessageFilter/             # MessageFilter Extension Target
│   ├── MessageFilterHandler.swift       # SMS filtering core
│   └── Info.plist
└── Shared/                              # Shared code layer
    ├── SpamSentryShared.swift           # App Group communication
    ├── BlocklistDatabase.swift          # SQLite database
    ├── BlocklistSyncService.swift       # Blocklist sync service
    ├── BlocklistModels.swift            # Shared data models
    └── SignatureVerifier.swift          # PGP signature verification
```

## Implementation Flow

1. Set up App Group container and shared UserDefaults
2. Implement SpamSentryShared.swift for inter-process communication
3. Create BlocklistDatabase with SQLite for blocklist storage
4. Implement CallDirectoryHandler for system-level call blocking
5. Build BlocklistSyncService for GitHub-based blocklist sync
6. Create ContactProtectionService to exclude contacts
7. Implement ExtensionHealthService for monitoring and auto-repair
8. Build main app UI with SwiftUI (Dashboard, Blocklist, Settings, Search)
9. Add MessageFilter Extension for SMS filtering
10. Implement fine-grained blocking rules (area code, wildcard)
11. Add temporary pause functionality
12. Integrate ContactSupportView and policy page links
13. Test on iPhone and iPad simulators

## UI/UX Design Specifications

- **Color Scheme**: 
  - Primary: #007AFF (iOS Blue) for trust and security
  - Success: #34C759 (Green) for active protection
  - Warning: #FF9500 (Orange) for paused/attention states
  - Danger: #FF3B30 (Red) for threats/blocked calls
  - Background: System backgrounds (auto dark mode)
  
- **Typography**: SF Pro system font
  - Large Title: 34pt for page headers
  - Title 2: 22pt for section headers
  - Body: 17pt for content
  - Caption: 12pt for metadata

- **Layout**:
  - Tab-based navigation: Dashboard, Blocklist, Search, Settings
  - Card-based dashboard with protection status, stats, health
  - List-based blocklist with swipe actions
  - Max content width 720pt for iPad

- **Animations**:
  - Shield pulse animation for active protection
  - Smooth list transitions for blocklist changes
  - Progress indicator for sync operations

## Code Generation Rules

- Use Swift 5.9+ with SwiftUI and Observation framework (@Observable)
- No third-party dependencies except GRDB for SQLite (if needed)
- All data stored on-device via SQLite and App Group UserDefaults
- No comments in code unless explicitly requested
- Follow MVVM pattern with @Observable ViewModels
- Use async/await for all asynchronous operations
- Use Actor for thread-safe services
- Proper error handling with do/catch
- Support dynamic type and accessibility

## Build & Deployment Checklist

1. Verify Bundle ID: com.zzoutuo.SpamSentry
2. Verify Deployment Target: iOS 17.0
3. Configure App Group: group.com.zzoutuo.SpamSentry.shared
4. Add CallDirectory Extension target
5. Add MessageFilter Extension target
6. Enable CallKit capability
7. Configure App Icons
8. Test on iPhone XS Max simulator
9. Test on iPad Pro 13-inch (M4) simulator
10. Verify Extension health monitoring works
11. Push to GitHub repository
12. Deploy policy pages to GitHub Pages
13. Prepare App Store Connect metadata
