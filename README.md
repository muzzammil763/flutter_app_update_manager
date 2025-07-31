# Flutter App Update Manager

A Flutter package to easily manage in-app updates using Firebase Firestore.

## Features

*   **Automatic Update Checks**: Automatically checks for new app versions from Firebase Firestore.
*   **Customizable Update Dialog**: Easily customize the update dialog to match your app's UI.
*   **Force and Optional Updates**: Configure updates to be either mandatory (force update) or optional.
*   **Platform-Specific Configuration**: Separate update configurations for Android and iOS.
*   **Discontinued Versions Support**: Notify users of discontinued app versions and prompt them to update.
*   **Auto Setup**: Automatically create Firestore structure with a single parameter.

## Getting Started

### Prerequisites

*   Flutter installed on your machine.
*   A Flutter project with Firebase configured.

### Installation

Add the following to your `pubspec.yaml` file:

```yaml
dependencies:
  flutter_app_update_manager: ^1.0.0 # Replace with the latest version
```

Then, run `flutter pub get`.

## Usage

### Quick Start with Auto Setup

For the easiest setup, use the `autoSetup` parameter to automatically create the Firestore structure:

```dart
AppUpdateManager(
  context: context,
  androidId: 'your.android.app.id',
  iosId: 'your.ios.app.id',
  autoSetup: true, // This will create the Firestore structure automatically
).checkForUpdate();
```

**⚠️ Important**: Set `autoSetup: false` after the first run to prevent overwriting your data!

### Manual Firebase Firestore Setup

If you prefer to set up Firestore manually:

1.  Go to your Firebase project console and create a Firestore database.
2.  Create a collection named `AppUpdateManager`.
3.  Inside the `AppUpdateManager` collection, create two documents: `Android` and `Ios`.

#### Document Structure

**Simplified Structure (Recommended):**

```json
{
  "versions": [
    {
      "version": "0.0.1+1",
      "isDiscontinued": true,
      "forceUpdate": true
    },
    {
      "version": "0.0.2+1",
      "isDiscontinued": false,
      "forceUpdate": false
    }
  ]
}
```

**Original Structure (Legacy):**

```json
{
  "versions": [
    {
      "version": "0.0.2+1",
      "forceUpdate": false
    }
  ],
  "discontinuedVersions": ["0.0.1+1"]
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
    androidId: 'your.android.app.id',
    iosId: 'your.ios.app.id',
    autoSetup: true, // Remove this after first run
  ).checkForUpdate();
}
```

### Customization

You can customize the update dialog by passing additional parameters to the `AppUpdateManager` constructor:

```dart
AppUpdateManager(
  context: context,
  androidId: 'your.android.app.id',
  iosId: 'your.ios.app.id',
  showLaterButton: true, // Show a "Later" button for optional updates
  appName: 'My Awesome App', // Your app's name
  playStoreUrl: 'https://play.google.com/store/apps/details?id=your.android.app.id', // Custom Play Store URL
  appStoreUrl: 'https://apps.apple.com/app/id-your.ios.app.id', // Custom App Store URL
  autoSetup: false, // Set to false after initial setup
).checkForUpdate();
```

## Version Management

### Simplified Structure Benefits

The simplified structure makes version management much easier:

- **All version info in one place**: No need for separate arrays
- **Clear flags**: Each version has `isDiscontinued` and `forceUpdate` flags
- **Easy to manage**: Just add new versions to the array
- **Flexible**: Supports both discontinued and newer version scenarios

### Version Format

Versions should follow the format: `major.minor.patch+build` (e.g., `1.0.0+1`)

- The package automatically handles build number comparison
- Version comparison ignores build numbers for semantic versioning
- Build numbers are preserved for reference

## Example

For a complete example, please see the `/example` folder in this package.

## Additional Information

*   **Contributing**: Contributions are welcome! Please feel free to submit a pull request.
*   **Issues**: If you find any issues or have a feature request, please file an issue on our [GitHub repository](https://github.com/your-repo-link).
*   **License**: This package is licensed under the MIT License.