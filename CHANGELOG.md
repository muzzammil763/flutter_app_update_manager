# Changelog

## [0.1.0] - 2024-01-XX

### Added
- **Multiple Dialog Styles**: Added support for different dialog styles including:
  - `DialogStyle.defaultStyle`: Classic AlertDialog
  - `DialogStyle.modernStyle`: Modern rounded dialog with icons
  - `DialogStyle.materialStyle`: Material Design 3 inspired dialog
  - `DialogStyle.custom`: Custom dialog support
- **Custom Dialog Interface**: Added `CustomUpdateDialog` interface for creating custom update dialogs
- **App Name Customization**: Added `appName` parameter to display app name in dialogs
- **Smart Force Update Handling**: Automatically hide "Later" button when `forceUpdate` is true
- **Enhanced Dialog Content**: Improved dialog text to show app name when provided
- **Firestore App ID Management**: App IDs can now be configured in Firestore for centralized management

### Changed
- **Removed Parameters**: Removed `showLaterButton`, `playStoreUrl`, and `appStoreUrl` parameters
- **Simplified URL Generation**: URLs are now automatically generated from `androidId` and `iosId`
- **Improved Auto Setup**: Enhanced auto setup with better documentation and warnings
- **Updated Example App**: Completely redesigned example app with interactive dialog style selection
- **Enhanced Firestore Integration**: App IDs can now be managed centrally in Firestore

### Fixed
- **Deprecated Method Usage**: Fixed `withOpacity` usage to use `withValues` for better precision
- **Test Coverage**: Improved test coverage with simplified test structure

### Breaking Changes
- `showLaterButton` parameter removed - "Later" button now automatically shows/hides based on `forceUpdate`
- `playStoreUrl` and `appStoreUrl` parameters removed - URLs now generated from app IDs
- Constructor signature changed to support new dialog styles and custom dialogs

### Migration Guide
To migrate from version 0.0.3 to 0.1.0:

**Before:**
```dart
AppUpdateManager(
  context: context,
  androidId: 'com.example.app',
  iosId: '123456789',
  showLaterButton: true,
  appName: 'MyApp',
  playStoreUrl: 'https://play.google.com/store/apps/details?id=com.example.app',
  appStoreUrl: 'https://apps.apple.com/app/id123456789',
).checkForUpdate();
```

**After:**
```dart
AppUpdateManager(
  context: context,
  androidId: 'com.example.app',
  iosId: '123456789',
  appName: 'MyApp',
  dialogStyle: DialogStyle.defaultStyle, // or other styles
).checkForUpdate();
```

## [0.0.3] - 2024-01-XX

### Added
- Initial release with basic update management functionality
- Firebase Firestore integration
- Auto setup feature
- Platform-specific configuration
- Force and optional updates support
