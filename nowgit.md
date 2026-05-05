# Git Repositories

## Main App (iOS Application)

| Item | Value |
|------|-------|
| **Repository Name** | SpamSentry |
| **Git URL** | git@github.com:asunnyboy861/SpamSentry.git |
| **Repo URL** | https://github.com/asunnyboy861/SpamSentry |
| **Visibility** | Public |
| **Primary Language** | Swift |
| **GitHub Pages** | ✅ **ENABLED** (from `/docs` folder) |

## Policy Pages (Deployed from Main Repository /docs)

| Page | URL | Status |
|------|-----|--------|
| Landing Page | https://asunnyboy861.github.io/SpamSentry/ | ✅ Live |
| Support | https://asunnyboy861.github.io/SpamSentry/support.html | ✅ Live |
| Privacy Policy | https://asunnyboy861.github.io/SpamSentry/privacy.html | ✅ Live |

**Note**: Terms of Use not required for Paid Download apps.

## Repository Structure

### Main App Repository
```
SpamSentry/
├── .github/
│   └── workflows/
│       └── deploy.yml                # GitHub Pages deployment workflow
├── SpamSentry/                        # iOS App Source Code
│   ├── SpamSentry.xcodeproj/          # Xcode Project
│   ├── SpamSentry/                    # Main App Swift Source Files
│   │   ├── Assets.xcassets/           # App Icons & Colors
│   │   ├── Views/
│   │   │   ├── DashboardView.swift
│   │   │   ├── BlocklistView.swift
│   │   │   ├── SettingsView.swift
│   │   │   ├── NumberSearchView.swift
│   │   │   ├── ContactSupportView.swift
│   │   │   └── MainTabView.swift
│   │   ├── Models/
│   │   │   ├── BlockRule.swift
│   │   │   └── BlockedNumber.swift
│   │   ├── ViewModels/
│   │   │   ├── BlockerViewModel.swift
│   │   │   ├── StatsViewModel.swift
│   │   │   └── SyncViewModel.swift
│   │   ├── Services/
│   │   │   ├── ContactProtectionService.swift
│   │   │   ├── ExtensionHealthService.swift
│   │   │   └── NotificationService.swift
│   │   ├── SpamSentryApp.swift
│   │   └── SpamSentry.entitlements
│   ├── SpamSentryCallBlocker/         # CallDirectory Extension
│   │   ├── CallDirectoryHandler.swift
│   │   ├── Info.plist
│   │   └── SpamSentryCallBlocker.entitlements
│   ├── SpamSentryMessageFilter/       # MessageFilter Extension
│   │   ├── MessageFilterHandler.swift
│   │   ├── Info.plist
│   │   └── SpamSentryMessageFilter.entitlements
│   ├── Shared/                        # Shared code between targets
│   │   ├── SpamSentryShared.swift
│   │   ├── BlocklistDatabase.swift
│   │   ├── BlocklistModels.swift
│   │   └── BlocklistSyncService.swift
│   ├── SpamSentryTests/
│   └── SpamSentryUITests/
├── SpamSentry-pic/                    # App Store Screenshots
│   ├── iphone/
│   │   ├── 01_dashboard.png
│   │   ├── 02_blocklist.png
│   │   ├── 03_settings.png
│   │   └── 04_search.png
│   └── ipad/
│       ├── 01_dashboard.png
│       └── 02_blocklist.png
├── docs/                              # Policy pages for GitHub Pages
│   ├── index.html                     # Landing Page
│   ├── support.html                   # Support Page
│   └── privacy.html                   # Privacy Policy
├── us.md                              # English Development Guide
├── keytext.md                         # App Store Metadata
├── capabilities.md                    # Capabilities Configuration
├── icon.md                            # App Icon Details
├── price.md                           # Pricing Configuration
├── nowgit.md                          # This File
└── .gitignore                         # Git ignore rules
```

## Deployment Summary

| Component | Platform | Status |
|-----------|----------|--------|
| iOS App | App Store (pending submission) | ✅ Built & Tested |
| Policy Pages | GitHub Pages | ✅ Live |
| Source Code | GitHub Repository | ✅ Pushed |

## App Store Connect Information

| Item | Value |
|------|-------|
| **App Name** | SpamSentry |
| **Bundle ID** | com.zzoutuo.SpamSentry |
| **Price** | $3.99 (Paid Download) |
| **Category** | Utilities |
| **Minimum iOS** | 17.0 |
