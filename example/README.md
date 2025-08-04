# Flutter App Update Manager Example

This example app demonstrates all the features of the Flutter App Update Manager package.

## Features Demonstrated

- ✅ **Basic Usage**: Simple update check with default dialog
- ✅ **Custom Dialog**: Beautiful custom update dialog implementation
- ✅ **Auto Setup**: Automatic Firestore structure creation
- ✅ **Configuration Options**: App name, show later button, etc.
- ✅ **Management Screen**: Built-in screen for managing update settings
- ✅ **Firebase Integration**: Complete Firebase Firestore setup

## Getting Started

### 1. Setup Firebase

1. Create a new Firebase project
2. Enable Firestore Database
3. Add your Android and iOS apps to the project
4. Download and add the configuration files:
   - `google-services.json` for Android
   - `GoogleService-Info.plist` for iOS

### 2. Run the Example

```bash
cd example
flutter pub get
flutter run
```

### 3. Test Features

The example app includes:

- **App Configuration**: Change app name and settings
- **Custom Dialog**: Toggle between default and custom dialog
- **Test Button**: Trigger update dialog manually
- **Management Screen**: Access via settings icon in app bar

### 4. Auto Setup

For first-time users, enable "Auto Setup" to automatically create the Firestore structure:

```dart
AppUpdateManager(
  context: context,
  autoSetup: true, // ⚠️ Set to false after first run
).checkForUpdate();
```

### 5. Custom Dialog Example

The example includes a beautiful custom dialog implementation:

```dart
class CustomUpdateDialogImpl implements CustomUpdateDialog {
  @override
  Widget build(BuildContext context, {
    required bool isForceUpdate,
    required String appName,
    required VoidCallback onUpdate,
    required VoidCallback? onLater,
  }) {
    // Custom dialog implementation
  }
}
```

## Firestore Structure

The package expects this Firestore structure:

```
AppUpdateManager/
├── Android/
│   ├── androidId: "com.example.myapp"
│   └── versions: [
│       ├── {version: "1.0.0", forceUpdate: true}
│       └── {version: "1.1.0", forceUpdate: false}
│   ]
└── Ios/
    ├── iosId: "123456789"
    └── versions: [
        ├── {version: "1.0.0", forceUpdate: true}
        └── {version: "1.1.0", forceUpdate: false}
    ]
```

## Screenshots

The example app demonstrates:
- Modern Material Design 3 UI
- Interactive configuration options
- Real-time feature testing
- Comprehensive documentation

## Learn More

- [Package Documentation](../README.md)
- [API Reference](../README.md#api-reference)
- [Getting Started Guide](../README.md#getting-started-guide) 