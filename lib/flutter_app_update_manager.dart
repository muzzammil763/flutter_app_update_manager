library flutter_app_update_manager;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class AppUpdateManager {
  final BuildContext context;
  final String? androidId;
  final String? iosId;
  final bool? showLaterButton;
  final String? appName;
  final String? playStoreUrl;
  final String? appStoreUrl;
  final FirebaseFirestore firestore;
  final bool autoSetup;

  AppUpdateManager({
    required this.context,
    this.androidId,
    this.iosId,
    this.showLaterButton,
    this.appName,
    this.playStoreUrl,
    this.appStoreUrl,
    FirebaseFirestore? firestore,
    this.autoSetup = false,
  }) : firestore = firestore ?? FirebaseFirestore.instance;

  Future<void> checkForUpdate() async {
    print('AppUpdateManager: Starting update check...');
    
    // Auto setup if enabled
    if (autoSetup) {
      await _autoSetupFirestore();
    }
    
    final packageInfo = await PackageInfo.fromPlatform();
    final currentVersion = packageInfo.version;
    print('AppUpdateManager: Current app version: $currentVersion');

    final platform = Theme.of(context).platform == TargetPlatform.android ? 'Android' : 'Ios';
    print('AppUpdateManager: Platform detected: $platform');

    try {
      final doc = await firestore.collection('AppUpdateManager').doc(platform).get();
      print('AppUpdateManager: Firestore document exists: ${doc.exists}');

      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        
        // Check for new simplified structure first
        if (data.containsKey('versions') && data['versions'] is List) {
          final versions = data['versions'] as List<dynamic>;
          print('AppUpdateManager: Using simplified version structure');
          print('AppUpdateManager: Versions from Firestore: $versions');
          
          // Find current version in the array
          bool foundCurrentVersion = false;
          bool shouldShowDialog = false;
          bool isForceUpdate = false;
          
          for (var versionData in versions) {
            final version = versionData['version'] as String;
            final isDiscontinued = versionData['isDiscontinued'] as bool? ?? false;
            final forceUpdate = versionData['forceUpdate'] as bool? ?? false;
            
            // Remove build number for comparison
            final currentVersionWithoutBuild = currentVersion.split('+')[0];
            final versionWithoutBuild = version.split('+')[0];
            
            print('AppUpdateManager: Checking version: $version (discontinued: $isDiscontinued, forceUpdate: $forceUpdate)');
            
            if (versionWithoutBuild == currentVersionWithoutBuild) {
              foundCurrentVersion = true;
              if (isDiscontinued) {
                shouldShowDialog = true;
                isForceUpdate = true;
                print('AppUpdateManager: Current version is discontinued');
                break;
              }
            } else if (versionWithoutBuild != currentVersionWithoutBuild) {
              // This is a different version, check if it's newer
              shouldShowDialog = true;
              isForceUpdate = forceUpdate;
              print('AppUpdateManager: Found different version, showing update dialog');
              break;
            }
          }
          
          if (shouldShowDialog) {
            _showUpdateDialog(isForceUpdate: isForceUpdate);
            return;
          }
          
          if (!foundCurrentVersion) {
            print('AppUpdateManager: Current version not found in Firestore, no update needed');
          }
          return;
        }
        
        // Fallback to original structure
        final versions = data['versions'] as List<dynamic>;
        final discontinuedVersions = data['discontinuedVersions'] as List<dynamic>;
        
        print('AppUpdateManager: Using original version structure');
        print('AppUpdateManager: Versions from Firestore: $versions');
        print('AppUpdateManager: Discontinued versions: $discontinuedVersions');

        if (discontinuedVersions.contains(currentVersion)) {
          print('AppUpdateManager: Current version is discontinued, showing force update dialog');
          print('AppUpdateManager: Current version: "$currentVersion"');
          print('AppUpdateManager: Discontinued versions: $discontinuedVersions');
          print('AppUpdateManager: Contains check result: ${discontinuedVersions.contains(currentVersion)}');
          _showUpdateDialog(isForceUpdate: true);
          return;
        } else {
          print('AppUpdateManager: Current version is NOT discontinued');
          print('AppUpdateManager: Current version: "$currentVersion"');
          print('AppUpdateManager: Discontinued versions: $discontinuedVersions');
        }

        // Check for newer versions
        for (var versionData in versions) {
          print('AppUpdateManager: Checking version data: $versionData');
          final firestoreVersion = versionData['version'] as String;
          
          // Remove build number for comparison if present
          final currentVersionWithoutBuild = currentVersion.split('+')[0];
          final firestoreVersionWithoutBuild = firestoreVersion.split('+')[0];
          
          print('AppUpdateManager: Comparing versions - Current: $currentVersionWithoutBuild, Firestore: $firestoreVersionWithoutBuild');
          
          // Check if this is a newer version that requires update
          if (firestoreVersionWithoutBuild != currentVersionWithoutBuild) {
            print('AppUpdateManager: Newer version found, showing update dialog');
            _showUpdateDialog(isForceUpdate: versionData['forceUpdate']);
            break;
          }
        }
      } else {
        print('AppUpdateManager: No Firestore document found for platform: $platform');
      }
    } catch (e) {
      print('AppUpdateManager: Error during update check: $e');
    }
  }

  Future<void> _autoSetupFirestore() async {
    print('AppUpdateManager: Auto setup enabled, creating Firestore structure...');
    
    try {
      // Create collection and documents for both platforms
      final collection = firestore.collection('AppUpdateManager');
      
      // Setup for Android
      await collection.doc('Android').set({
        'versions': [
          {
            'version': '0.0.1+1',
            'isDiscontinued': true,
            'forceUpdate': true
          },
          {
            'version': '0.0.2+1',
            'isDiscontinued': false,
            'forceUpdate': false
          }
        ]
      });
      
      // Setup for iOS
      await collection.doc('Ios').set({
        'versions': [
          {
            'version': '0.0.1+1',
            'isDiscontinued': true,
            'forceUpdate': true
          },
          {
            'version': '0.0.2+1',
            'isDiscontinued': false,
            'forceUpdate': false
          }
        ]
      });
      
      print('AppUpdateManager: Firestore structure created successfully!');
      print('AppUpdateManager: Collection: AppUpdateManager');
      print('AppUpdateManager: Documents: Android, Ios');
      print('AppUpdateManager: Structure: Simplified (versions array with isDiscontinued and forceUpdate flags)');
      print('AppUpdateManager: ⚠️  IMPORTANT: Set autoSetup: false after first run to prevent overwriting your data!');
      
    } catch (e) {
      print('AppUpdateManager: Error during auto setup: $e');
    }
  }

  void _showUpdateDialog({required bool isForceUpdate}) {
    print('AppUpdateManager: _showUpdateDialog called with isForceUpdate: $isForceUpdate');
    
    // Check if context is still valid and mounted
    if (!context.mounted) {
      print('AppUpdateManager: Context is not mounted, skipping dialog');
      return;
    }
    
    // Check if we have MaterialApp ancestor
    final materialApp = context.findAncestorWidgetOfExactType<MaterialApp>();
    if (materialApp == null) {
      print('AppUpdateManager: No MaterialApp found in widget tree, skipping dialog');
      return;
    }
    
    showDialog(
      context: context,
      barrierDismissible: !isForceUpdate,
      builder: (BuildContext context) {
        print('AppUpdateManager: Building dialog...');
        return AlertDialog(
          title: Text('Update Available'),
          content: Text('A new version of the app is available. Please update to the latest version.'),
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
                _launchURL();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _launchURL() async {
    final platform = Theme.of(context).platform;
    String? url;

    if (platform == TargetPlatform.android) {
      url = playStoreUrl ?? 'https://play.google.com/store/apps/details?id=$androidId';
    } else if (platform == TargetPlatform.iOS) {
      url = appStoreUrl ?? 'https://apps.apple.com/app/id$iosId';
    }

    if (url != null && await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      throw 'Could not launch $url';
    }
  }
}