library flutter_app_update_manager;

import 'dart:ui'; // Added for ImageFilter

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

// Export the management screen
export 'app_update_manager_screen.dart';

/// Custom colors for the default dialog.
///
/// Use this class to customize the colors of the default dialog.
class DefaultDialogColors {
  /// The color for text buttons (Later, Update Now).
  final Color? buttonColor;

  /// The color for the dialog text content.
  final Color? textColor;

  /// The color for the dialog title.
  final Color? titleColor;

  /// Creates DefaultDialogColors instance.
  ///
  /// [buttonColor] - Color for text buttons (optional)
  /// [textColor] - Color for dialog text content (optional)
  /// [titleColor] - Color for dialog title (optional)
  const DefaultDialogColors({
    this.buttonColor,
    this.textColor,
    this.titleColor,
  });
}

/// Abstract interface for creating custom update dialogs.
///
/// Implement this interface to create your own beautiful update dialogs
/// with full control over design and behavior.
abstract class CustomUpdateDialog {
  /// Builds the custom update dialog widget.
  ///
  /// [context] - Build context for navigation and theme access
  /// [isForceUpdate] - True when update is mandatory (hide "Later" button)
  /// [appName] - The app name to display in the dialog
  /// [onUpdate] - Callback when user chooses to update
  /// [onLater] - Callback when user chooses to update later (null if force update)
  Widget build(
    BuildContext context, {
    required bool isForceUpdate,
    required String appName,
    required VoidCallback onUpdate,
    required VoidCallback? onLater,
  });
}

/// Main class for managing app updates with Firebase Firestore integration.
///
/// This class provides a complete solution for in-app update management,
/// including version checking, dialog display, and store URL launching.
///
/// ## Features:
/// - Automatic version comparison with Firestore
/// - Default dialog style with blur background
/// - Force update handling
/// - Platform-specific store URL generation
/// - Auto setup for first-time configuration
///
/// ## Example:
/// ```dart
/// AppUpdateManager(
///   context: context,
///   appName: "MyApp",
/// ).checkForUpdate();
/// ```
class AppUpdateManager {
  /// The build context used for showing dialogs and detecting platform.
  ///
  /// Must be a valid context from a MaterialApp widget tree.
  final BuildContext context;

  /// App name to display in update dialogs.
  ///
  /// Falls back to "App" if not provided.
  /// Example: "MyApp"
  final String? appName;

  /// Whether to show the "Later" button for optional updates.
  ///
  /// When true, users can dismiss non-force updates.
  /// When false, only "Update Now" button is shown.
  /// Defaults to false for force updates.
  final bool? showLaterButton;

  /// Firebase Firestore instance for version management.
  ///
  /// Uses FirebaseFirestore.instance by default.
  /// Can be customized for testing or different environments.
  final FirebaseFirestore firestore;

  /// Auto setup flag for creating Firestore structure.
  ///
  /// When true, creates the required Firestore collection and documents
  /// with sample data. ⚠️ Set to false after first run to prevent data overwrites.
  final bool autoSetup;

  /// Custom dialog implementation.
  ///
  /// When provided, uses custom dialog instead of default dialog.
  /// Implement CustomUpdateDialog interface to create your own dialog.
  final CustomUpdateDialog? customDialog;

  /// Custom colors for the default dialog.
  ///
  /// When provided, overrides the default colors in the default dialog.
  final DefaultDialogColors? dialogColors;

  /// Creates an AppUpdateManager instance.
  ///
  /// [context] - The build context (required)
  /// [appName] - App name for dialogs (optional, defaults to "App")
  /// [showLaterButton] - Show "Later" button for optional updates (optional, defaults to false)
  /// [firestore] - Custom Firestore instance (optional, uses default)
  /// [autoSetup] - Auto create Firestore structure (optional, defaults to false)
  /// [customDialog] - Custom dialog implementation (optional)
  /// [dialogColors] - Custom colors for default dialog (optional)
  AppUpdateManager({
    required this.context,
    this.appName,
    this.showLaterButton,
    FirebaseFirestore? firestore,
    this.autoSetup = false,
    this.customDialog,
    this.dialogColors,
  }) : firestore = firestore ?? FirebaseFirestore.instance;

  /// Checks for available updates by comparing current app version with Firestore.
  ///
  /// This method:
  /// 1. Fetches current app version using package_info_plus
  /// 2. Detects platform (Android/iOS) automatically
  /// 3. Queries Firestore for available versions
  /// 4. Shows update dialog if exact version match is found
  /// 5. Handles force updates and optional updates
  /// 6. Launches store URL when user chooses to update
  ///
  /// ## Firestore Structure:
  /// Expects a collection named 'AppUpdateManager' with documents for each platform:
  /// - Document 'Android' for Android platform
  /// - Document 'Ios' for iOS platform
  ///
  /// Each document should contain:
  /// - `androidId` and `iosId` fields (for store URLs)
  /// - `versions` array with version objects
  ///
  /// Version object structure:
  /// ```json
  /// {
  ///   "version": "1.2.0",
  ///   "forceUpdate": false
  /// }
  /// ```
  ///
  /// ## Returns:
  /// Future<void> - Completes when the update check is finished
  ///
  /// ## Throws:
  /// May throw exceptions for network errors or invalid Firestore data
  Future<void> checkForUpdate() async {
    debugPrint('AppUpdateManager: Starting update check...');

    // Auto setup if enabled
    if (autoSetup) {
      await _autoSetupFirestore();
    }

    final packageInfo = await PackageInfo.fromPlatform();
    final currentVersion = packageInfo.version;
    debugPrint('AppUpdateManager: Current app version: $currentVersion');

    final platform = Theme.of(context).platform == TargetPlatform.android
        ? 'Android'
        : 'Ios';
    debugPrint('AppUpdateManager: Platform detected: $platform');

    try {
      // Firebase is always initialized since it's required in constructor

      final doc = await firestore
          .collection('AppUpdateManager')
          .doc(platform)
          .get();
      debugPrint('AppUpdateManager: Firestore document exists: ${doc.exists}');

      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;

        // App IDs are fetched later when needed for URL generation

        // Check for new simplified structure first
        if (data.containsKey('versions') && data['versions'] is List) {
          final versions = data['versions'] as List<dynamic>;
          debugPrint('AppUpdateManager: Using simplified version structure');
          debugPrint('AppUpdateManager: Versions from Firestore: $versions');

          // Find exact version match
          bool foundExactMatch = false;
          bool shouldShowDialog = false;
          bool isForceUpdate = false;

          for (var versionData in versions) {
            final version = versionData['version'] as String;
            final forceUpdate = versionData['forceUpdate'] as bool? ?? false;

            debugPrint(
              'AppUpdateManager: Checking version: $version (forceUpdate: $forceUpdate)',
            );
            debugPrint(
              'AppUpdateManager: Current app version: $currentVersion',
            );

            // Check for exact match first (version + build number)
            if (version == currentVersion) {
              foundExactMatch = true;
              shouldShowDialog = true;
              isForceUpdate = forceUpdate;
              debugPrint(
                'AppUpdateManager: Exact version match found, showing dialog',
              );
              break;
            }

            // If no exact match, check if Firestore version is without build number
            // and current version has build number, then compare version parts
            if (!version.contains('+') && currentVersion.contains('+')) {
              final currentVersionWithoutBuild = currentVersion.split('+')[0];
              if (version == currentVersionWithoutBuild) {
                foundExactMatch = true;
                shouldShowDialog = true;
                isForceUpdate = forceUpdate;
                debugPrint(
                  'AppUpdateManager: Version match found (Firestore without build, app with build), showing dialog',
                );
                break;
              }
            }

            // If Firestore version has build number but app version doesn't, compare version parts
            if (version.contains('+') && !currentVersion.contains('+')) {
              final firestoreVersionWithoutBuild = version.split('+')[0];
              if (firestoreVersionWithoutBuild == currentVersion) {
                foundExactMatch = true;
                shouldShowDialog = true;
                isForceUpdate = forceUpdate;
                debugPrint(
                  'AppUpdateManager: Version match found (Firestore with build, app without build), showing dialog',
                );
                break;
              }
            }
          }

          if (shouldShowDialog) {
            _showUpdateDialog(isForceUpdate: isForceUpdate);
            return;
          }

          if (!foundExactMatch) {
            debugPrint(
              'AppUpdateManager: No exact version match found, no update needed',
            );
          }
          return;
        }

        // Fallback to original structure
        final versions = data['versions'] as List<dynamic>;

        debugPrint('AppUpdateManager: Using original version structure');
        debugPrint('AppUpdateManager: Versions from Firestore: $versions');

        // Check for newer versions
        for (var versionData in versions) {
          final firestoreVersion = versionData['version'] as String;

          // Check for exact match first
          if (firestoreVersion == currentVersion) {
            debugPrint(
              'AppUpdateManager: Exact version match found, showing update dialog',
            );
            _showUpdateDialog(isForceUpdate: versionData['forceUpdate']);
            break;
          }

          // If no exact match, check if Firestore version is without build number
          // and current version has build number, then compare version parts
          if (!firestoreVersion.contains('+') && currentVersion.contains('+')) {
            final currentVersionWithoutBuild = currentVersion.split('+')[0];
            if (firestoreVersion == currentVersionWithoutBuild) {
              debugPrint(
                'AppUpdateManager: Version match found (Firestore without build, app with build), showing dialog',
              );
              _showUpdateDialog(isForceUpdate: versionData['forceUpdate']);
              break;
            }
          }

          // If Firestore version has build number but app version doesn't, compare version parts
          if (firestoreVersion.contains('+') && !currentVersion.contains('+')) {
            final firestoreVersionWithoutBuild = firestoreVersion.split('+')[0];
            if (firestoreVersionWithoutBuild == currentVersion) {
              debugPrint(
                'AppUpdateManager: Version match found (Firestore with build, app without build), showing dialog',
              );
              _showUpdateDialog(isForceUpdate: versionData['forceUpdate']);
              break;
            }
          }
        }
      } else {
        debugPrint(
          'AppUpdateManager: No Firestore document found for platform: $platform',
        );
      }
    } catch (e) {
      debugPrint('AppUpdateManager: Error during update check: $e');
    }
  }

  /// Automatically sets up the required Firestore structure with sample data.
  ///
  /// This method creates:
  /// - Collection: 'AppUpdateManager'
  /// - Documents: 'Android' and 'Ios'
  /// - Sample version data for testing
  ///
  /// ⚠️ **Important**: Set autoSetup to false after first run to prevent data overwrites.
  ///
  /// ## Firestore Structure Created:
  /// ```json
  /// {
  ///   "androidId": "com.example.myapp",
  ///   "versions": [
  ///     {
  ///       "version": "0.0.1+1",
  ///       "forceUpdate": true
  ///     }
  ///   ]
  /// }
  /// ```
  Future<void> _autoSetupFirestore() async {
    debugPrint(
      'AppUpdateManager: Auto setup enabled, creating Firestore structure...',
    );

    try {
      // Create collection and documents for both platforms
      final collection = firestore.collection('AppUpdateManager');

      // Setup for Android
      await collection.doc('Android').set({
        'androidId': 'com.example.myapp',
        'versions': [
          {'version': '0.0.1+1', 'forceUpdate': true},
        ],
      });

      // Setup for iOS
      await collection.doc('Ios').set({
        'iosId': '123456789',
        'versions': [
          {'version': '0.0.1+1', 'forceUpdate': true},
        ],
      });

      debugPrint('AppUpdateManager: Firestore structure created successfully!');
      debugPrint('AppUpdateManager: Collection: AppUpdateManager');
      debugPrint('AppUpdateManager: Documents: Android, Ios');
      debugPrint(
        'AppUpdateManager: Structure: Simplified (versions array with forceUpdate flag)',
      );
      debugPrint(
        'AppUpdateManager: ⚠️  IMPORTANT: Set autoSetup: false after first run to prevent overwriting your data!',
      );
    } catch (e) {
      debugPrint('AppUpdateManager: Error during auto setup: $e');
    }
  }

  /// Shows the update dialog based on the configured dialog style.
  ///
  /// [isForceUpdate] - Whether this is a force update (hides "Later" button)
  /// [androidId] - Android package ID for store URL (optional, uses instance androidId if not provided)
  /// [iosId] - iOS App Store ID for store URL (optional, uses instance iosId if not provided)
  ///
  /// ## Dialog Selection Logic:
  /// 1. If dialogStyle is DialogStyle.custom and customDialog is provided, uses custom dialog
  /// 2. Otherwise, uses predefined dialog based on dialogStyle
  /// 3. For force updates, barrierDismissible is set to false
  ///
  /// ## Context Validation:
  /// - Checks if context is still mounted
  /// - Verifies MaterialApp ancestor exists
  /// - Skips dialog if validation fails
  void _showUpdateDialog({required bool isForceUpdate}) {
    debugPrint(
      'AppUpdateManager: _showUpdateDialog called with isForceUpdate: $isForceUpdate',
    );

    // Check if context is still valid and mounted
    if (!context.mounted) {
      debugPrint('AppUpdateManager: Context is not mounted, skipping dialog');
      return;
    }

    // Check if we have MaterialApp ancestor
    final materialApp = context.findAncestorWidgetOfExactType<MaterialApp>();
    if (materialApp == null) {
      debugPrint(
        'AppUpdateManager: No MaterialApp found in widget tree, skipping dialog',
      );
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: !isForceUpdate,
      builder: (BuildContext context) {
        debugPrint('AppUpdateManager: Building dialog...');

        // Use custom dialog if provided
        if (customDialog != null) {
          return customDialog!.build(
            context,
            isForceUpdate: isForceUpdate,
            appName: appName ?? 'App',
            onUpdate: () {
              _launchURL();
            },
            onLater: isForceUpdate
                ? null
                : () {
                    Navigator.of(context).pop();
                  },
          );
        }

        // Use default dialog
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: PopScope(
            canPop: !isForceUpdate,
            child: AlertDialog(
              title: Text(
                'Update Available',
                style: dialogColors?.titleColor != null
                    ? TextStyle(color: dialogColors!.titleColor)
                    : null,
              ),
              content: Text(
                'A new version of ${appName ?? "the app"} is available. Please update to the latest version.',
                style: dialogColors?.textColor != null
                    ? TextStyle(color: dialogColors!.textColor)
                    : null,
              ),
              actions: <Widget>[
                if (showLaterButton == true && !isForceUpdate)
                  TextButton(
                    style: dialogColors?.buttonColor != null
                        ? TextButton.styleFrom(
                            foregroundColor: dialogColors!.buttonColor,
                          )
                        : null,
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text('Later'),
                  ),
                TextButton(
                  style: dialogColors?.buttonColor != null
                      ? TextButton.styleFrom(
                          foregroundColor: dialogColors!.buttonColor,
                        )
                      : null,
                  onPressed: () {
                    _launchURL();
                  },
                  child: Text('Update Now'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Launches the appropriate store URL based on platform and app IDs from Firestore.
  ///
  /// [androidId] - Android package ID for Play Store URL (optional, uses Firestore if not provided)
  /// [iosId] - iOS App Store ID for App Store URL (optional, uses Firestore if not provided)
  ///
  /// ## URL Generation:
  /// - **Android**: `https://play.google.com/store/apps/details?id={androidId}`
  /// - **iOS**: `https://apps.apple.com/app/id{iosId}`
  ///
  /// ## Platform Detection:
  /// Uses `Theme.of(context).platform` to detect Android or iOS
  ///
  /// ## Throws:
  /// Throws exception if URL cannot be launched or if app IDs are missing
  Future<void> _launchURL({String? androidId, String? iosId}) async {
    final platform = Theme.of(context).platform;
    String? url;

    // If app IDs not provided, fetch from Firestore
    String? finalAndroidId = androidId;
    String? finalIosId = iosId;

    if (finalAndroidId == null || finalIosId == null) {
      try {
        final platformDoc = Theme.of(context).platform == TargetPlatform.android
            ? 'Android'
            : 'Ios';
        final doc = await firestore
            .collection('AppUpdateManager')
            .doc(platformDoc)
            .get();

        if (doc.exists) {
          final data = doc.data() as Map<String, dynamic>;
          finalAndroidId = finalAndroidId ?? data['androidId'] as String?;
          finalIosId = finalIosId ?? data['iosId'] as String?;
        }
      } catch (e) {
        debugPrint(
          'AppUpdateManager: Error fetching app IDs from Firestore: $e',
        );
      }
    }

    if (platform == TargetPlatform.android) {
      url =
          'https://play.google.com/store/apps/details?id=${finalAndroidId ?? 'com.example.myapp'}';
    } else if (platform == TargetPlatform.iOS) {
      url = 'https://apps.apple.com/app/id${finalIosId ?? '123456789'}';
    }

    debugPrint('AppUpdateManager: Launching URL: $url');

    if (url != null && await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      throw 'Could not launch $url';
    }
  }
}
