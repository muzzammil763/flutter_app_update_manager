# Flutter App Update Manager

A Powerful Flutter Package To Easily Manage In-App Updates Using Firebase Firestore With Custom Dialog Support And Comprehensive Management Features.

![Flutter App Update Manager](Screenshots/app_update_manager.png)

## Features

*   **Automatic Update Checks**: Automatically checks for new app versions from Firebase Firestore.
*   **Default Dialog Style**: Clean AlertDialog with blur background and proper force update handling.
*   **Custom Dialog Support**: Create your own beautiful update dialogs with full control.
*   **Force and Optional Updates**: Configure updates to be either mandatory (force update) or optional.
*   **Platform-Specific Configuration**: Separate update configurations for Android and iOS.
*   **Auto Setup**: Automatically create Firestore structure with a single parameter.
*   **Management Screen**: Built-in screen for managing update configurations.
*   **Store URL Auto-Generation**: Automatically generates platform-specific store URLs.
*   **Version Comparison**: Smart version comparison with build number support.
*   **Default Dialog Customization**: Customize colors for title, text, and buttons.
*   **Latest Firebase Compatibility**: Updated to work with Firebase v5.0.0+ and Firebase Core v3.0.0+.

## Screenshots

### Default Dialog

![Default Dialog](Screenshots/default.jpeg)

### Usage Examples

#### Basic Usage
```dart
AppUpdateManager(
  context: context,
  appName: "App Name",
  showLaterButton: true,
).checkForUpdate();
```

#### With Custom Colors
```dart
AppUpdateManager(
  context: context,
  appName: "App Name",
  showLaterButton: true,
  dialogColors: DefaultDialogColors(
    buttonColor: Colors.blue,
    textColor: Colors.grey[700],
    titleColor: Colors.black87,
  ),
).checkForUpdate();
```

### Custom Dialog

![Custom Dialog](Screenshots/custom.jpeg)

### Usage Examples

#### Basic Usage
```dart
AppUpdateManager(
  customDialog: MyCustomDialog(),
  context: context,
  appName: "App Name",
  showLaterButton: true,
).checkForUpdate();
```

### Custom Dialog
```dart
class MyCustomDialog implements CustomUpdateDialog {
  @override
  Widget build(BuildContext context, {
    required bool isForceUpdate,
    required String appName,
    required VoidCallback onUpdate,
    required VoidCallback? onLater,
  }) {
    return Dialog(
      child: Container(
        padding: EdgeInsets.all(24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(colors: [Colors.blue, Colors.purple]),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.rocket_launch, size: 48, color: Colors.white),
            SizedBox(height: 16),
            Text('🚀 New Version Available!', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text('A new version of $appName is available!'),
            SizedBox(height: 24),
            Row(
              children: [
                if (onLater != null)
                  Expanded(child: OutlinedButton(onPressed: onLater, child: Text('Later'))),
                SizedBox(width: 12),
                Expanded(child: ElevatedButton(onPressed: onUpdate, child: Text('Update Now'))),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

AppUpdateManager(
  context: context,
  customDialog: MyCustomDialog(),
  showLaterButton: true,
).checkForUpdate();
```

### Auto Setup (First Time)
```dart
AppUpdateManager(
  context: context,
  autoSetup: true, // ⚠️ Set To False After First Run
).checkForUpdate();
```

## Installation

Add this to your `pubspec.yaml`:

```yaml
dependencies:
  flutter_app_update_manager: ^0.1.5
```

### Firebase Compatibility

This package is compatible with both the latest and previous Firebase packages:

```yaml
dependencies:
  firebase_core: ^3.0.0
  cloud_firestore: ^5.0.0
```

**Version Support:**
- **Firebase Core**: v3.0.0+ (supports both v3.x and v4.x)
- **Cloud Firestore**: v5.0.0+ (supports both v5.x and v6.x)

## Example App

Check out the [example app](example/) for a complete demonstration of all features:

- **Interactive Configuration**: Test different settings in real-time
- **Custom Dialog Example**: Beautiful custom dialog implementation
- **Auto Setup Demo**: See how auto setup works
- **Management Screen**: Built-in configuration management
- **Firebase Integration**: Complete setup guide

Run the example:
```bash
cd example
flutter pub get
flutter run
```

## Quick Start

### 1. Basic Usage

```dart
import 'package:flutter_app_update_manager/flutter_app_update_manager.dart';

// Simple usage
AppUpdateManager(
  context: context,
  appName: "MyApp",
  showLaterButton: true,
).checkForUpdate();
```

### 2. With Custom Dialog

```dart
AppUpdateManager(
  context: context,
  appName: "MyApp",
  customDialog: MyCustomDialog(),
  showLaterButton: true,
).checkForUpdate();
```

### 3. With Auto Setup (First Time)

```dart
AppUpdateManager(
  context: context,
  autoSetup: true, // ⚠️ Set to false after first run
).checkForUpdate();
```

**⚠️ Important**: Set `autoSetup: false` after the first run to prevent overwriting your data!

## API Reference

### AppUpdateManager Class

The main class for managing app updates with Firebase Firestore integration.

#### Constructor

```dart
AppUpdateManager({
  required BuildContext context,
  String? appName,
  bool? showLaterButton,
  FirebaseFirestore? firestore,
  bool autoSetup = false,
  CustomUpdateDialog? customDialog,
})
```

#### Parameters

| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| `context` | `BuildContext` | ✅ | - | **Build context** - Used for showing dialogs and detecting platform |
| `appName` | `String?` | ❌ | `"App"` | **App name** - The app name to display in update dialogs |
| `showLaterButton` | `bool?` | ❌ | `false` | **Show later button** - When true, users can dismiss non-force updates |
| `firestore` | `FirebaseFirestore?` | ❌ | `FirebaseFirestore.instance` | **Firestore instance** - Custom Firestore instance for testing |
| `autoSetup` | `bool` | ❌ | `false` | **Auto setup** - Creates Firestore structure automatically |
| `customDialog` | `CustomUpdateDialog?` | ❌ | `null` | **Custom dialog** - Your own dialog implementation |
| `dialogColors` | `DefaultDialogColors?` | ❌ | `null` | **Dialog colors** - Custom colors for default dialog |

#### Methods

| Method | Description |
|--------|-------------|
| `checkForUpdate()` | Checks for available updates and shows dialog if needed |

### DefaultDialogColors Class

Class for customizing the default dialog colors.

```dart
class DefaultDialogColors {
  final Color? buttonColor;   // Color for text buttons
  final Color? textColor;     // Color for dialog text content
  final Color? titleColor;    // Color for dialog title

  const DefaultDialogColors({
    this.buttonColor,
    this.textColor,
    this.titleColor,
  });
}
```

### CustomUpdateDialog Interface

Abstract interface for creating custom update dialogs.

```dart
abstract class CustomUpdateDialog {
  Widget build(BuildContext context, {
    required bool isForceUpdate,
    required String appName,
    required VoidCallback onUpdate,
    required VoidCallback? onLater,
  });
}
```

#### Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `context` | `BuildContext` | ✅ | **Build context** - Used for navigation and theme access |
| `isForceUpdate` | `bool` | ✅ | **Force update flag** - True when update is mandatory (hide "Later" button) |
| `appName` | `String` | ✅ | **App name** - The app name to display in the dialog |
| `onUpdate` | `VoidCallback` | ✅ | **Update callback** - Call this when user chooses to update |
| `onLater` | `VoidCallback?` | ✅ | **Later callback** - Call this when user chooses to update later (null if force update) |

## Getting Started Guide

### Step 1: Initial Setup

1. **Add the package to your `pubspec.yaml`**
2. **Run `flutter pub get`**
3. **Configure Firebase in your project**

### Step 2: First Run with Auto Setup

```dart
import 'package:flutter/material.dart';
import 'package:flutter_app_update_manager/flutter_app_update_manager.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'App Update Manager Demo',
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  void initState() {
    super.initState();
    
    // Check for updates
    AppUpdateManager(
      context: context,
      appName: "App Name",
      autoSetup: true, // ⚠️ Set to false after first run
    ).checkForUpdate();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('My App')),
      body: Center(child: Text('Welcome To My App')),
    );
  }
}
```

### Step 3: Configure Firestore

After the first run with `autoSetup: true`:

1. **Go to Firebase Console**
2. **Navigate to Firestore**
3. **Find the `AppUpdateManager` collection**
4. **Update the versions with your actual app versions**
5. **Set `autoSetup: false` in your code**

### Step 4: Add New Versions

When you release a new version:

1. **Update your app's version in `pubspec.yaml`**
2. **Add the new version to Firestore**
3. **Configure force update if needed**

Example Firestore update:
```json
{
  "versions": [
    {
      "version": "1.0.0",
      "forceUpdate": true
    },
    {
      "version": "1.1.0",
      "forceUpdate": false
    },
    {
      "version": "1.2.0",
      "forceUpdate": false
    }
  ]
}
```

### Implementation

In your app, import the package and initialize the `AppUpdateManager` in your `initState` or any other suitable place:

```dart
import 'package:flutter_app_update_manager/flutter_app_update_manager.dart';

@override
void initState() {
  super.initState();
  AppUpdateManager(
    context: context,
    showLaterButton: true, // Show "Later" button for optional updates
    appName: "MyApp",
    autoSetup: true, // Remove this after first run
  ).checkForUpdate();
}
```

**How it works:**
- App IDs are automatically fetched from Firestore (`AppUpdateManager/Android/androidId` and `AppUpdateManager/Ios/iosId`)
- If your app version is `0.0.1+1` and Firestore has `{"version": "0.0.1+1", "forceUpdate": true}`, dialog shows
- If your app version is `0.0.1+1` and Firestore has `{"version": "0.0.1+0", "forceUpdate": false}`, no dialog
- If your app version is `0.0.1+1` and Firestore has `{"version": "0.0.0+1", "forceUpdate": false}`, no dialog

### Management Screen

The package includes a built-in management screen for configuring update settings:

```dart
// Navigate to the management screen
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => AppUpdateManagerScreen(),
  ),
);
```

The management screen provides:
- **Platform-specific tabs** (Android/iOS)
- **Version management** with force update controls
- **App store URL configuration**
- **Real-time Firestore synchronization**
- **Modern UI** with smooth animations

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Support

If you encounter any issues or have questions, please open an issue on GitHub.

### Customization

You can customize the update dialog by passing additional parameters to the `AppUpdateManager` constructor:

```dart
AppUpdateManager(
  context: context,
  showLaterButton: true, // Show a "Later" button for optional updates
  appName: 'My Awesome App', // Your app's name
  autoSetup: false, // Set to false after initial setup
).checkForUpdate();
```

### Dialog Features

The Package Supports:

```dart
// Default Dialog - Clean AlertDialog With Blur Background
AppUpdateManager(context: context).checkForUpdate();

// Custom Dialog - Your Own Implementation
AppUpdateManager(
  context: context,
  customDialog: MyCustomDialog(),
).checkForUpdate();

// Force Update Handling - Hides "Later" Button Automatically
// Configured In Firestore With forceUpdate: true
```

### Custom Dialog Implementation

Create Your Own Dialog By Implementing `CustomUpdateDialog`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_app_update_manager/flutter_app_update_manager.dart';

class MyCustomDialog implements CustomUpdateDialog {
  @override
  Widget build(
          BuildContext context, {
            required bool isForceUpdate,
            required String appName,
            required VoidCallback onUpdate,
            required VoidCallback? onLater,
          }) {
    return WillPopScope(
      onWillPop: () async => !isForceUpdate,
      child: Dialog(
        child: Container(
          padding: EdgeInsets.all(24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(colors: [Colors.blue, Colors.purple]),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.rocket_launch, size: 48, color: Colors.white),
              SizedBox(height: 16),
              Text(
                '🚀 New Version Available!',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Align(
                alignment: Alignment.centerLeft,
                child: RichText(
                  textAlign: TextAlign.start,
                  text: TextSpan(
                    children: [
                      TextSpan(text: 'A new version of '),
                      TextSpan(
                        text: appName,
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      TextSpan(text: ' is available!'),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 24),
              Column(
                spacing: 8,
                children: [
                  if (!isForceUpdate && onLater != null)
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: onLater,
                        child: Text('Maybe Later'),
                      ),
                    ),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: onUpdate,
                      child: Text('Update Now'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Use Custom Dialog
AppUpdateManager(
  context: context,
  customDialog: MyCustomDialog(),
).checkForUpdate();
```

## Additional Information

*   **Contributing**: Contributions Are Welcome! Please Feel Free To Submit A Pull Request.
*   **Issues**: If You Find Any Issues Or Have A Feature Request, Please File An Issue On Our [GitHub repository](https://github.com/muzzammil763/flutter_app_update_manager).
*   **License**: This Package Is Licensed Under The MIT License.

---

## Author

<div align="center">
  
  **Muzamil Ghafoor**
  
  Flutter Developer | Passionate About Crafting Seamless Apps With Flutter & Dart
  
  [![GitHub](https://img.shields.io/badge/GitHub-100000?style=for-the-badge&logo=github&logoColor=white)](https://github.com/muzzammil763)
  [![LinkedIn](https://img.shields.io/badge/LinkedIn-0077B5?style=for-the-badge&logo=linkedin&logoColor=white)](https://www.linkedin.com/in/muzamil-ghafoor-181840344?utm_source=share&utm_campaign=share_via&utm_content=profile&utm_medium=ios_app)
</div>