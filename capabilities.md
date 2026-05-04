# Capabilities Configuration

## Analysis
Based on operation guide analysis:
- CallKit / CallDirectory Extension: Required for call blocking
- MessageFilter Extension: Required for SMS filtering
- App Group: Required for data sharing between main app and extensions
- Contacts: Required for contact protection (excluding contacts from blocklist)
- Network: Required for blocklist sync from GitHub

## Auto-Configured Capabilities
| Capability | Status | Method |
|------------|--------|--------|
| CallKit (CallDirectory Extension) | ✅ Configured | xcodegen project.yml |
| MessageFilter Extension | ✅ Configured | xcodegen project.yml |
| App Group | ✅ Configured | xcodegen project.yml |
| Contacts | ✅ Configured | Info.plist NSContactsUsageDescription |

## Manual Configuration Required
| Capability | Status | Steps |
|------------|--------|-------|
| None | ✅ N/A | All capabilities auto-configured |

## No Configuration Needed
- Push Notifications: Not needed (no remote push)
- iCloud: Not needed (local-only storage)
- HealthKit: Not applicable
- Camera: Not applicable
- Location: Not applicable
- Siri: Not needed for MVP
- In-App Purchase: Not needed (paid download model)

## Verification
- Build succeeded after configuration: Pending
- All entitlements correct: Pending
