# Flutter App Update Manager

A powerful Flutter package to easily manage in-app updates using Firebase Firestore with multiple dialog styles and custom dialog support.

![Flutter App Update Manager](https://via.placeholder.com/800x400/4A90E2/FFFFFF?text=Flutter+App+Update+Manager)

## Features

- ✅ **Multiple Dialog Styles**: Choose from default, modern, material, or custom dialogs
- ✅ **Custom Dialog Support**: Create your own beautiful update dialogs
- ✅ **App Name Customization**: Display your app name in update dialogs
- ✅ **Force Update Handling**: Automatically hide "Later" button for force updates
- ✅ **Firebase Firestore Integration**: Manage versions through Firestore
- ✅ **Auto Setup**: Easy first-time setup with sample data
- ✅ **Platform Support**: Works on Android and iOS
- ✅ **Smart URL Generation**: Automatically generates store URLs from app IDs

## Installation

Add this to your `pubspec.yaml`:

```yaml
dependencies:
  flutter_app_update_manager: ^0.0.3
```

## Quick Start

### 1. Basic Usage

```dart
import 'package:flutter_app_update_manager/flutter_app_update_manager.dart';

// Simple usage
AppUpdateManager(
  context: context,
  androidId: 'com.example.myapp',
  iosId: '123456789',
  appName: "MyApp",
).checkForUpdate();
```

### 2. With Custom Dialog Style

```dart
AppUpdateManager(
  context: context,
  androidId: 'com.example.myapp',
  iosId: '123456789',
  appName: "XTREM",
  dialogStyle: DialogStyle.modernStyle, // or DialogStyle.materialStyle
).checkForUpdate();
```

### 3. With Custom Dialog

```dart
AppUpdateManager(
  context: context,
  androidId: 'com.example.myapp',
  iosId: '123456789',
  appName: "XTREM",
  dialogStyle: DialogStyle.custom,
  customDialog: MyCustomDialog(),
).checkForUpdate();
```

## API Reference

### AppUpdateManager Class

The main class for managing app updates with Firebase Firestore integration.

#### Constructor

```dart
AppUpdateManager({
  required BuildContext context,
  String? androidId,
  String? iosId,
  String? appName,
  FirebaseFirestore? firestore,
  bool autoSetup = false,
  DialogStyle dialogStyle = DialogStyle.defaultStyle,
  CustomUpdateDialog? customDialog,
})
```

#### Parameters

| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| `context` | `BuildContext` | ✅ | - | **The build context** - Used to show dialogs and detect platform. Must be a valid context from a MaterialApp widget tree. |
| `androidId` | `String?` | ❌ | `null` | **Android package ID** - Your app's package name (e.g., 'com.example.myapp'). Can also be configured in Firestore for centralized management. |
| `iosId` | `String?` | ❌ | `null` | **iOS App Store ID** - Your app's numeric ID from the App Store (e.g., '123456789'). Can also be configured in Firestore. |
| `appName` | `String?` | ❌ | `null` | **App name for dialogs** - The name to display in update dialogs (e.g., "MyApp"). Falls back to "App" if not provided. |
| `firestore` | `FirebaseFirestore?` | ❌ | `FirebaseFirestore.instance` | **Custom Firestore instance** - Use this to provide a custom Firestore instance for testing or different environments. |
| `autoSetup` | `bool` | ❌ | `false` | **Auto setup Firestore** - When true, creates the required Firestore structure with sample data. ⚠️ Set to false after first run to prevent data overwrites. |
| `dialogStyle` | `DialogStyle` | ❌ | `DialogStyle.defaultStyle` | **Dialog appearance** - Choose from predefined styles or use custom. See DialogStyle enum for options. |
| `customDialog` | `CustomUpdateDialog?` | ❌ | `null` | **Custom dialog implementation** - Your own dialog widget. Required when dialogStyle is DialogStyle.custom. |

#### Methods

##### `checkForUpdate()`

Checks for available updates by comparing the current app version with versions stored in Firebase Firestore.

```dart
Future<void> checkForUpdate()
```

**Returns:** `Future<void>` - Completes when the update check is finished

**Behavior:**
- Fetches current app version using `package_info_plus`
- Detects platform (Android/iOS) automatically
- Queries Firestore for available versions
- Shows update dialog if newer version is found
- Handles force updates and discontinued versions
- Launches store URL when user chooses to update

### DialogStyle Enum

Defines the available dialog styles for update notifications.

```dart
enum DialogStyle {
  defaultStyle,    // Classic AlertDialog with clean design
  modernStyle,     // Modern rounded dialog with icons
  materialStyle,   // Material Design 3 inspired style
  custom,          // Custom dialog implementation
}
```

#### Values

| Value | Description | Visual Style |
|-------|-------------|--------------|
| `defaultStyle` | **Classic AlertDialog** - Simple, clean design with standard Material Design buttons | Standard AlertDialog with title, content, and action buttons |
| `modernStyle` | **Modern rounded dialog** - Enhanced with icons, better typography, and rounded corners | Rounded corners, update icon, improved spacing and typography |
| `materialStyle` | **Material Design 3** - Latest Material Design with gradient backgrounds and enhanced visuals | Material 3 styling with gradients, larger icons, and modern button styles |
| `custom` | **Custom implementation** - Use your own dialog widget | Fully customizable - implement CustomUpdateDialog interface |

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

#### Implementation Example

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
          gradient: LinearGradient(
            colors: [Colors.blue.shade50, Colors.purple.shade50],
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.rocket_launch, size: 48, color: Colors.blue.shade700),
            SizedBox(height: 16),
            Text(
              '🚀 New Version Available!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            RichText(
              textAlign: TextAlign.center,
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
            SizedBox(height: 24),
            Row(
              children: [
                if (!isForceUpdate && onLater != null)
                  Expanded(
                    child: OutlinedButton(
                      child: Text('Maybe Later'),
                      onPressed: onLater,
                    ),
                  ),
                Expanded(
                  child: ElevatedButton(
                    child: Text('Update Now'),
                    onPressed: onUpdate,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
```

## Firebase Firestore Setup

### Auto Setup (Recommended for First Time)

```dart
AppUpdateManager(
  context: context,
  androidId: 'com.example.myapp',
  iosId: '123456789',
  appName: "XTREM",
  autoSetup: true, // Set to false after first run
).checkForUpdate();
```

### Manual Firestore Structure

Create a collection named `AppUpdateManager` with documents for each platform:

**Document: Android**
```json
{
  "androidId": "com.example.myapp",
  "iosId": "123456789",
  "versions": [
    {
      "version": "1.0.0",
      "isDiscontinued": true,
      "forceUpdate": true
    },
    {
      "version": "1.1.0",
      "isDiscontinued": false,
      "forceUpdate": false
    }
  ]
}
```

**Document: Ios**
```json
{
  "androidId": "com.example.myapp",
  "iosId": "123456789",
  "versions": [
    {
      "version": "1.0.0",
      "isDiscontinued": true,
      "forceUpdate": true
    },
    {
      "version": "1.1.0",
      "isDiscontinued": false,
      "forceUpdate": false
    }
  ]
}
```

## Firestore Configuration

### App IDs Configuration

You can configure your app IDs in two ways:

1. **In your code** (as before):
   ```dart
   AppUpdateManager(
     context: context,
     androidId: 'com.example.myapp',
     iosId: '123456789',
   ).checkForUpdate();
   ```

2. **In Firestore** (recommended for centralized management):
   - Add `androidId` and `iosId` fields to your Firestore documents
   - The package will use Firestore values if available, otherwise fall back to code values
   - This allows you to update app IDs without releasing a new app version

### Version Management

### Adding New Versions

1. **Go to Firebase Console**
2. **Navigate to Firestore**
3. **Find the `AppUpdateManager` collection**
4. **Select your platform document (Android/Ios)**
5. **Add a new version object to the `versions` array**

### Version Object Structure

```json
{
  "version": "1.2.0",
  "isDiscontinued": false,
  "forceUpdate": false
}
```

### Force Update Configuration

- **`isDiscontinued: true`**: Current version is discontinued, force update
- **`forceUpdate: true`**: New version requires force update (hides "Later" button)
- **`forceUpdate: false`**: Optional update (shows "Later" button)

## Example App

Run the example app to see all dialog styles in action:

```bash
cd example
flutter run
```

The example app demonstrates:
- All dialog styles
- Custom dialog implementation
- App name customization
- Force update scenarios

## Screenshots

![Default Dialog](https://via.placeholder.com/300x200/4A90E2/FFFFFF?text=Default+Dialog)
![Modern Dialog](https://via.placeholder.com/300x200/4A90E2/FFFFFF?text=Modern+Dialog)
![Material Dialog](https://via.placeholder.com/300x200/4A90E2/FFFFFF?text=Material+Dialog)
![Custom Dialog](https://via.placeholder.com/300x200/4A90E2/FFFFFF?text=Custom+Dialog)

## Getting Started Guide

### Step 1: Initial Setup

1. **Add the package to your `pubspec.yaml`**
2. **Run `flutter pub get`**
3. **Configure Firebase in your project**

### Step 2: First Run with Auto Setup

```dart
void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
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
    
    // First run with auto setup
    AppUpdateManager(
      context: context,
      androidId: 'com.example.myapp',
      iosId: '123456789',
      appName: "XTREM",
      autoSetup: true, // ⚠️ Set to false after first run
    ).checkForUpdate();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('My App')),
      body: Center(child: Text('Welcome to XTREM!')),
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
      "isDiscontinued": true,
      "forceUpdate": true
    },
    {
      "version": "1.1.0",
      "isDiscontinued": false,
      "forceUpdate": false
    },
    {
      "version": "1.2.0",
      "isDiscontinued": false,
      "forceUpdate": false
    }
  ]
}
```

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Support

If you encounter any issues or have questions, please open an issue on GitHub.