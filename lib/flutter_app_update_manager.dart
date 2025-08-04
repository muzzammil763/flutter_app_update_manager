library flutter_app_update_manager;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:ui'; // Added for ImageFilter

// Export the management screen
export 'app_update_manager_screen.dart';

/// Dialog style options for update notifications.
/// 
/// Choose from predefined styles or implement your own custom dialog.
enum DialogStyle {
  /// Classic AlertDialog with clean design and standard Material Design buttons.
  defaultStyle,
  
  /// Modern rounded dialog with icons, enhanced typography, and improved spacing.
  modernStyle,
  
  /// Material Design 3 inspired style with gradient backgrounds and modern visuals.
  materialStyle,
  
  /// Custom dialog implementation - use your own dialog widget.
  custom,
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
  Widget build(BuildContext context, {
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
/// - Multiple dialog styles (default, modern, material, custom)
/// - Force update handling
/// - Platform-specific store URL generation
/// - Auto setup for first-time configuration
/// 
/// ## Example:
/// ```dart
/// AppUpdateManager(
///   context: context,
///   androidId: 'com.example.myapp',
///   iosId: '123456789',
///   appName: "MyApp",
///   dialogStyle: DialogStyle.modernStyle,
/// ).checkForUpdate();
/// ```
class AppUpdateManager {
  /// The build context used for showing dialogs and detecting platform.
  /// 
  /// Must be a valid context from a MaterialApp widget tree.
  final BuildContext context;
  
  /// Android package ID for generating Play Store URLs.
  /// 
  /// Example: 'com.example.myapp'
  /// Can also be configured in Firestore for centralized management.
  final String? androidId;
  
  /// iOS App Store ID for generating App Store URLs.
  /// 
  /// Example: '123456789'
  /// Can also be configured in Firestore for centralized management.
  final String? iosId;
  
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
  
  /// Dialog style for update notifications.
  /// 
  /// Choose from predefined styles or use DialogStyle.custom with a custom dialog.
  final DialogStyle dialogStyle;
  
  /// Custom dialog implementation.
  /// 
  /// Required when dialogStyle is DialogStyle.custom.
  /// Implement CustomUpdateDialog interface to create your own dialog.
  final CustomUpdateDialog? customDialog;

  /// Creates an AppUpdateManager instance.
  /// 
  /// [context] - The build context (required)
  /// [androidId] - Android package ID (optional, can be set in Firestore)
  /// [iosId] - iOS App Store ID (optional, can be set in Firestore)
  /// [appName] - App name for dialogs (optional, defaults to "App")
  /// [showLaterButton] - Show "Later" button for optional updates (optional, defaults to false)
  /// [firestore] - Custom Firestore instance (optional, uses default)
  /// [autoSetup] - Auto create Firestore structure (optional, defaults to false)
  /// [dialogStyle] - Dialog appearance (optional, defaults to defaultStyle)
  /// [customDialog] - Custom dialog implementation (optional, required for custom style)
  AppUpdateManager({
    required this.context,
    this.androidId,
    this.iosId,
    this.appName,
    this.showLaterButton,
    FirebaseFirestore? firestore,
    this.autoSetup = false,
    this.dialogStyle = DialogStyle.defaultStyle,
    this.customDialog,
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
  /// - `androidId` and `iosId` fields (optional, can be set in code)
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

    final platform = Theme.of(context).platform == TargetPlatform.android ? 'Android' : 'Ios';
    debugPrint('AppUpdateManager: Platform detected: $platform');

    try {
      final doc = await firestore.collection('AppUpdateManager').doc(platform).get();
      debugPrint('AppUpdateManager: Firestore document exists: ${doc.exists}');

      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        
        // Get app IDs from Firestore
        final firestoreAndroidId = data['androidId'] as String? ?? androidId;
        final firestoreIosId = data['iosId'] as String? ?? iosId;
        
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
            
            debugPrint('AppUpdateManager: Checking version: $version (forceUpdate: $forceUpdate)');
            debugPrint('AppUpdateManager: Current app version: $currentVersion');
            
            // Exact match check (version + build number)
            if (version == currentVersion) {
              foundExactMatch = true;
              shouldShowDialog = true;
              isForceUpdate = forceUpdate;
              debugPrint('AppUpdateManager: Exact version match found, showing dialog');
              break;
            }
          }
          
          if (shouldShowDialog) {
            _showUpdateDialog(isForceUpdate: isForceUpdate);
            return;
          }
          
          if (!foundExactMatch) {
            debugPrint('AppUpdateManager: No exact version match found, no update needed');
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
          
          // Remove build number for comparison if present
          final currentVersionWithoutBuild = currentVersion.split('+')[0];
          final firestoreVersionWithoutBuild = firestoreVersion.split('+')[0];
          
          if (firestoreVersionWithoutBuild != currentVersionWithoutBuild) {
            debugPrint('AppUpdateManager: Newer version found, showing update dialog');
            _showUpdateDialog(isForceUpdate: versionData['forceUpdate']);
            break;
          }
        }
      } else {
        debugPrint('AppUpdateManager: No Firestore document found for platform: $platform');
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
  ///   "androidId": "",
  ///   "iosId": "",
  ///   "versions": [
  ///     {
  ///       "version": "0.0.1+1",
  ///       "forceUpdate": true
  ///     },
  ///     {
  ///       "version": "0.0.2+1",
  ///       "forceUpdate": false
  ///     }
  ///   ]
  /// }
  /// ```
  Future<void> _autoSetupFirestore() async {
    debugPrint('AppUpdateManager: Auto setup enabled, creating Firestore structure...');
    
    try {
      // Create collection and documents for both platforms
      final collection = firestore.collection('AppUpdateManager');
      
      // Setup for Android
      await collection.doc('Android').set({
        'androidId': 'com.example.myapp',
        'versions': [
          {
            'version': '0.0.1+1',
            'forceUpdate': true
          },
          {
            'version': '0.0.2+1',
            'forceUpdate': false
          }
        ]
      });
      
      // Setup for iOS
      await collection.doc('Ios').set({
        'iosId': '123456789',
        'versions': [
          {
            'version': '0.0.1+1',
            'forceUpdate': true
          },
          {
            'version': '0.0.2+1',
            'forceUpdate': false
          }
        ]
      });
      
      debugPrint('AppUpdateManager: Firestore structure created successfully!');
      debugPrint('AppUpdateManager: Collection: AppUpdateManager');
      debugPrint('AppUpdateManager: Documents: Android, Ios');
      debugPrint('AppUpdateManager: Structure: Simplified (versions array with forceUpdate flag)');
      debugPrint('AppUpdateManager: ⚠️  IMPORTANT: Set autoSetup: false after first run to prevent overwriting your data!');
      
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
    debugPrint('AppUpdateManager: _showUpdateDialog called with isForceUpdate: $isForceUpdate');
    
    // Check if context is still valid and mounted
    if (!context.mounted) {
      debugPrint('AppUpdateManager: Context is not mounted, skipping dialog');
      return;
    }
    
    // Check if we have MaterialApp ancestor
    final materialApp = context.findAncestorWidgetOfExactType<MaterialApp>();
    if (materialApp == null) {
      debugPrint('AppUpdateManager: No MaterialApp found in widget tree, skipping dialog');
      return;
    }
    
    showDialog(
      context: context,
      barrierDismissible: !isForceUpdate,
      builder: (BuildContext context) {
        debugPrint('AppUpdateManager: Building dialog...');
        
        // Use custom dialog if provided
        if (dialogStyle == DialogStyle.custom && customDialog != null) {
          return customDialog!.build(
            context,
            isForceUpdate: isForceUpdate,
            appName: appName ?? 'App',
            onUpdate: () {
              Navigator.of(context).pop();
              _launchURL();
            },
            onLater: isForceUpdate ? null : () {
              Navigator.of(context).pop();
            },
          );
        }
        
        // Use predefined dialog styles
        switch (dialogStyle) {
          case DialogStyle.defaultStyle:
            return _buildDefaultDialog(context, isForceUpdate);
          case DialogStyle.modernStyle:
            return _buildModernDialog(context, isForceUpdate);
          case DialogStyle.materialStyle:
            return _buildMaterialDialog(context, isForceUpdate);
          case DialogStyle.custom:
            return _buildDefaultDialog(context, isForceUpdate);
        }
      },
    );
  }

  /// Builds the default dialog style - classic AlertDialog with clean design.
  /// 
  /// [context] - Build context for the dialog
  /// [isForceUpdate] - Whether this is a force update (hides "Later" button)
  /// 
  /// ## Features:
  /// - Standard AlertDialog design
  /// - Clean typography and spacing
  /// - Conditional "Later" button based on force update status
  /// - "Update Now" button that launches store URL
  Widget _buildDefaultDialog(BuildContext context, bool isForceUpdate) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
      child: WillPopScope(
        onWillPop: () async {
          // Prevent back button from closing force update dialogs
          return !isForceUpdate;
        },
        child: AlertDialog(
          title: Text('Update Available'),
          content: Text('A new version of ${appName ?? "the app"} is available. Please update to the latest version.'),
          actions: <Widget>[
            if (showLaterButton == true && !isForceUpdate)
              TextButton(
                child: Text('Later'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            TextButton(
              child: Text('Update Now'),
              onPressed: () {
                Navigator.of(context).pop();
                _launchURL();
              },
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the modern dialog style - enhanced design with icons and better typography.
  /// 
  /// [context] - Build context for the dialog
  /// [isForceUpdate] - Whether this is a force update (hides "Later" button)
  /// 
  /// ## Features:
  /// - Rounded corners (20px border radius)
  /// - Update icon in title
  /// - Enhanced typography with different font sizes
  /// - Improved content layout with spacing
  /// - Elevated button for "Update Now" action
  /// - Conditional "Later" button based on force update status
  Widget _buildModernDialog(BuildContext context, bool isForceUpdate) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
      child: WillPopScope(
        onWillPop: () async {
          // Prevent back button from closing force update dialogs
          return !isForceUpdate;
        },
        child: Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.system_update,
                    color: Colors.blue,
                    size: 28,
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  'Update Available',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'A new version of ${appName ?? "the app"} is available. Please update to the latest version.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black54,
                  ),
                ),
                SizedBox(height: 24),
                Row(
                  children: [
                    if (showLaterButton == true && !isForceUpdate)
                      Expanded(
                        child: TextButton(
                          child: Text('Later'),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                      ),
                    if (showLaterButton == true && !isForceUpdate)
                      SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        child: Text('Update Now'),
                        onPressed: () {
                          _launchURL();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Builds the material dialog style - Material Design 3 inspired with gradient backgrounds.
  /// 
  /// [context] - Build context for the dialog
  /// [isForceUpdate] - Whether this is a force update (hides "Later" button)
  /// 
  /// ## Features:
  /// - Material Design 3 inspired styling
  /// - Gradient backgrounds and modern visuals
  /// - Large update icon with background
  /// - Enhanced typography and spacing
  /// - Outlined and Elevated button styles
  /// - Conditional "Later" button based on force update status
  Widget _buildMaterialDialog(BuildContext context, bool isForceUpdate) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
      child: WillPopScope(
        onWillPop: () async {
          // Prevent back button from closing force update dialogs
          return !isForceUpdate;
        },
        child: Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: Container(
            padding: EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.system_update,
                    size: 48,
                    color: Colors.blue,
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  'Update Available',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'A new version of ${appName ?? "the app"} is available.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[700],
                  ),
                ),
                SizedBox(height: 24),
                Row(
                  children: [
                    if (showLaterButton == true && !isForceUpdate) ...[
                      Expanded(
                        child: OutlinedButton(
                          child: Text('Later'),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                      ),
                      SizedBox(width: 12),
                    ],
                    Expanded(
                      child: ElevatedButton(
                        child: Text('Update Now'),
                        onPressed: () {
                          Navigator.of(context).pop();
                          _launchURL();
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Launches the appropriate store URL based on platform and app IDs.
  /// 
  /// [androidId] - Android package ID for Play Store URL (optional, uses instance androidId if not provided)
  /// [iosId] - iOS App Store ID for App Store URL (optional, uses instance iosId if not provided)
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

    if (platform == TargetPlatform.android) {
      url = 'https://play.google.com/store/apps/details?id=${androidId ?? this.androidId}';
    } else if (platform == TargetPlatform.iOS) {
      url = 'https://apps.apple.com/app/id${iosId ?? this.iosId}';
    }

    if (url != null && await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      throw 'Could not launch $url';
    }
  }
}