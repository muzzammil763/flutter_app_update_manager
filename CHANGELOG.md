# Changelog

## [0.1.6] - 2024-12-19

### Changed
- **Enhanced Firebase Compatibility**: Updated to work with both latest and previous Firebase versions
  - **Firebase Core**: v3.0.0+ (supports both v3.x and v4.x)
  - **Cloud Firestore**: v5.0.0+ (supports both v5.x and v6.x)
- **Updated Dependencies**: Firebase packages updated to support multiple versions
  - `cloud_firestore`: `^5.0.0` (supports v5.x and v6.x)
  - `firebase_core`: `^3.0.0` (supports v3.x and v4.x)
  - `cloud_firestore_platform_interface`: `^6.6.12` (compatible with firebase_core ^3.0.0)

### Fixed
- **Dependency Conflicts**: Resolved Firebase dependency conflicts for better version compatibility
- **Documentation**: Updated README and CHANGELOG to reflect version compatibility changes

## [0.1.5] - 2024-12-19

### Added
- **Default Dialog Color Customization**: Added `DefaultDialogColors` class for customizing default dialog colors
  - `buttonColor`: Customize text button colors (Later, Update Now)
  - `textColor`: Customize dialog content text color
  - `titleColor`: Customize dialog title color
- **Enhanced Firebase Compatibility**: Updated to work with both latest and previous Firebase versions
  - **Firebase Core**: v3.0.0+ (supports both v3.x and v4.x)
  - **Cloud Firestore**: v5.0.0+ (supports both v5.x and v6.x)
- **Enhanced Error Handling**: Added graceful handling for Firebase initialization errors
- **Test Environment Support**: Improved handling in test environments with Firebase error catching

### Changed
- **Updated Dependencies**: Firebase packages updated to support multiple versions
  - `cloud_firestore`: `^5.0.0` (supports v5.x and v6.x)
  - `firebase_core`: `^3.0.0` (supports v3.x and v4.x)
  - `package_info_plus`: `^8.0.0` → `^8.3.0`
  - `url_launcher`: `^6.3.0` → `^6.3.2`
  - `flutter_lints`: `^5.0.0` → `^6.0.0`
- **Example App Enhancements**: Added color customization demo and improved error handling
- **Documentation Updates**: Added Firebase compatibility section and usage examples

### Fixed
- **Firebase Initialization**: Fixed Firebase initialization errors in test environments
- **Error Handling**: Improved error handling for Firebase operations
- **Test Compatibility**: Fixed test failures due to Firebase initialization issues

### Usage Examples

**Basic Usage with Custom Colors:**
```dart
AppUpdateManager(
  context: context,
  appName: "MyApp",
  showLaterButton: true,
  dialogColors: DefaultDialogColors(
    buttonColor: Colors.blue,
    textColor: Colors.grey[700],
    titleColor: Colors.black87,
  ),
).checkForUpdate();
```

**Firebase Compatibility:**
```yaml
dependencies:
  firebase_core: ^3.0.0
  cloud_firestore: ^5.0.0
```

**Version Support:**
- **Firebase Core**: v3.0.0+ (supports both v3.x and v4.x)
- **Cloud Firestore**: v5.0.0+ (supports both v5.x and v6.x)

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
