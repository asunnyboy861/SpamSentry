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
| Landing Page | https://asunnyboy861.github.io/SpamSentry/ | ⏳ Pending |
| Support | https://asunnyboy861.github.io/SpamSentry/support.html | ⏳ Pending |
| Privacy Policy | https://asunnyboy861.github.io/SpamSentry/privacy.html | ⏳ Pending |

**Note**: Terms of Use not required for Paid Download apps.

## Repository Structure

### Main App Repository
```
SpamSentry/
├── SpamSentry/                        # iOS App Source Code
│   ├── SpamSentry.xcodeproj/          # Xcode Project
│   ├── SpamSentry/                    # Main App Swift Source Files
│   │   ├── Views/
│   │   ├── Models/
│   │   ├── ViewModels/
│   │   ├── Services/
│   │   └── SpamSentryApp.swift
│   ├── SpamSentryCallBlocker/         # CallDirectory Extension
│   ├── SpamSentryMessageFilter/       # MessageFilter Extension
│   └── Shared/                        # Shared code between targets
├── docs/                              # Policy pages for GitHub Pages
│   ├── index.html
│   ├── support.html
│   └── privacy.html
├── us.md                              # English Development Guide
├── keytext.md                         # App Store Metadata
├── capabilities.md                    # Capabilities Configuration
├── icon.md                            # App Icon Details
├── price.md                           # Pricing Configuration
└── nowgit.md                          # This File
```
