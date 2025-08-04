import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// A comprehensive screen for managing app update configurations.
/// 
/// This screen provides a user-friendly interface for:
/// - Managing version configurations for Android and iOS
/// - Setting force update flags
/// - Adding/removing versions
/// - Configuring app store URLs
/// 
/// ## Features:
/// - Platform-specific tabs (Android/iOS)
/// - Version management with force update controls
/// - Real-time Firestore synchronization
/// - Modern UI with blur effects and smooth animations
class AppUpdateManagerScreen extends StatefulWidget {
  /// The screen title.
  final String title;
  
  /// Creates an AppUpdateManagerScreen.
  /// 
  /// [title] - The screen title (optional, defaults to "App Update Manager")
  const AppUpdateManagerScreen({
    super.key,
    this.title = "App Update Manager",
  });

  @override
  State<AppUpdateManagerScreen> createState() => _AppUpdateManagerScreenState();
}

class _AppUpdateManagerScreenState extends State<AppUpdateManagerScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _loading = true;
  bool _saving = false;
  
  // Platform tab selection (0 = Android, 1 = iOS)
  int _selectedPlatformIndex = 0;
  
  // Form controllers
  late TextEditingController _appStoreController;
  late TextEditingController _playStoreController;
  List<TextEditingController> _versionControllers = [];
  List<TextEditingController> _versionControllersIos = [];
  
  // Data storage
  Map<String, dynamic> _settings = {};
  List<Map<String, dynamic>> _versions = [];
  List<Map<String, dynamic>> _versionsIos = [];
  Map<String, dynamic> _originalSettings = {};
  List<Map<String, dynamic>> _originalVersions = [];
  List<Map<String, dynamic>> _originalVersionsIos = [];
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    _appStoreController = TextEditingController();
    _playStoreController = TextEditingController();
    _fetchSettings();
  }

  @override
  void dispose() {
    _appStoreController.dispose();
    _playStoreController.dispose();
    for (var controller in _versionControllers) {
      controller.dispose();
    }
    for (var controller in _versionControllersIos) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _fetchSettings() async {
    setState(() => _loading = true);
    
    try {
      // Fetch Android settings
      final androidDoc = await _firestore.collection('AppUpdateManager').doc('Android').get();
      final iosDoc = await _firestore.collection('AppUpdateManager').doc('Ios').get();
      
      setState(() {
        if (androidDoc.exists) {
          final androidData = androidDoc.data()!;
          _settings['androidId'] = androidData['androidId'] ?? '';
          _versions = List<Map<String, dynamic>>.from(androidData['versions'] ?? []);
        }
        
        if (iosDoc.exists) {
          final iosData = iosDoc.data()!;
          _settings['iosId'] = iosData['iosId'] ?? '';
          _versionsIos = List<Map<String, dynamic>>.from(iosData['versions'] ?? []);
        }
        
        _originalSettings = Map<String, dynamic>.from(_settings);
        _originalVersions = List<Map<String, dynamic>>.from(_versions.map((e) => Map<String, dynamic>.from(e)));
        _originalVersionsIos = List<Map<String, dynamic>>.from(_versionsIos.map((e) => Map<String, dynamic>.from(e)));
        
        _appStoreController.text = _settings['iosId'] ?? '';
        _playStoreController.text = _settings['androidId'] ?? '';
        
        // Initialize version controllers
        _initializeVersionControllers();
        
        _hasChanges = false;
        _loading = false;
      });
    } catch (e) {
      print('Error fetching settings: $e');
      setState(() => _loading = false);
    }
  }

  void _initializeVersionControllers() {
    // Dispose existing controllers
    for (var controller in _versionControllers) {
      controller.dispose();
    }
    for (var controller in _versionControllersIos) {
      controller.dispose();
    }
    
    // Create new controllers
    _versionControllers = List.generate(
      _versions.length,
      (i) => TextEditingController(text: _versions[i]['version'] ?? ''),
    );
    
    _versionControllersIos = List.generate(
      _versionsIos.length,
      (i) => TextEditingController(text: _versionsIos[i]['version'] ?? ''),
    );
  }

  void _checkForChanges() {
    bool changed = false;
    
    // Check app IDs
    if (_appStoreController.text != (_originalSettings['iosId'] ?? '')) {
      changed = true;
    }
    if (_playStoreController.text != (_originalSettings['androidId'] ?? '')) {
      changed = true;
    }
    
    // Check Android versions
    if (_versions.length != _originalVersions.length) {
      changed = true;
    } else {
      for (int i = 0; i < _versions.length; i++) {
        if (i >= _originalVersions.length) {
          changed = true;
          break;
        }
        final a = _versions[i];
        final b = _originalVersions[i];
        if (a['version'] != b['version'] ||
            a['forceUpdate'] != b['forceUpdate']) {
          changed = true;
          break;
        }
      }
    }
    
    // Check iOS versions
    if (_versionsIos.length != _originalVersionsIos.length) {
      changed = true;
    } else {
      for (int i = 0; i < _versionsIos.length; i++) {
        if (i >= _originalVersionsIos.length) {
          changed = true;
          break;
        }
        final a = _versionsIos[i];
        final b = _originalVersionsIos[i];
        if (a['version'] != b['version'] ||
            a['forceUpdate'] != b['forceUpdate']) {
          changed = true;
          break;
        }
      }
    }
    
    if (_hasChanges != changed) {
      setState(() {
        _hasChanges = changed;
      });
    }
  }

  Future<void> _saveSettings() async {
    setState(() => _saving = true);
    
    try {
      // Update Android document
      await _firestore.collection('AppUpdateManager').doc('Android').set({
        'androidId': _playStoreController.text,
        'versions': _versions,
      });
      
      // Update iOS document
      await _firestore.collection('AppUpdateManager').doc('Ios').set({
        'iosId': _appStoreController.text,
        'versions': _versionsIos,
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Settings updated successfully!')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update settings: $e')),
        );
      }
    } finally {
      setState(() => _saving = false);
    }
  }

  Widget _buildVersionsList() {
    final isAndroid = _selectedPlatformIndex == 0;
    final versionsList = isAndroid ? _versions : _versionsIos;
    final versionControllersList = isAndroid ? _versionControllers : _versionControllersIos;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Version Management',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
            IconButton(
              icon: Icon(Icons.add, color: Colors.blue),
              onPressed: () {
                setState(() {
                  if (isAndroid) {
                    _versions.add({
                      'version': '',
                      'forceUpdate': false,
                    });
                    _versionControllers.add(TextEditingController());
                  } else {
                    _versionsIos.add({
                      'version': '',
                      'forceUpdate': false,
                    });
                    _versionControllersIos.add(TextEditingController());
                  }
                });
                _checkForChanges();
              },
            ),
          ],
        ),
        SizedBox(height: 16),
        if (versionsList.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Center(
              child: Text(
                'No versions configured',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ),
          )
        else
          ...versionsList.asMap().entries.map((entry) {
            final idx = entry.key;
            final item = entry.value;
            
            return Dismissible(
              key: ValueKey('version_$idx'),
              direction: DismissDirection.horizontal,
              background: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.red,
                ),
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Icon(Icons.delete, color: Colors.white),
              ),
              secondaryBackground: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.red,
                ),
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Icon(Icons.delete, color: Colors.white),
              ),
              onDismissed: (direction) {
                setState(() {
                  if (isAndroid) {
                    _versions.removeAt(idx);
                    _versionControllers.removeAt(idx);
                  } else {
                    _versionsIos.removeAt(idx);
                    _versionControllersIos.removeAt(idx);
                  }
                });
                _checkForChanges();
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      TextField(
                        controller: versionControllersList[idx],
                        decoration: InputDecoration(
                          labelText: 'Version (e.g., 1.0.0+1)',
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (val) {
                          if (isAndroid) {
                            _versions[idx]['version'] = val;
                          } else {
                            _versionsIos[idx]['version'] = val;
                          }
                          _checkForChanges();
                        },
                      ),
                      SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                Text('Force Update: '),
                                CupertinoSwitch(
                                  value: item['forceUpdate'] ?? false,
                                  onChanged: (val) {
                                    setState(() {
                                      if (isAndroid) {
                                        _versions[idx]['forceUpdate'] = val;
                                      } else {
                                        _versionsIos[idx]['forceUpdate'] = val;
                                      }
                                    });
                                    _checkForChanges();
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: _loading
          ? Center(child: CircularProgressIndicator())
          : SafeArea(
              child: SingleChildScrollView(
                physics: BouncingScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Platform selector
                    Container(
                      width: double.infinity,
                      child: CupertinoSegmentedControl<int>(
                        children: {
                          0: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                            child: Text('Android', style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                          1: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                            child: Text('iOS', style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                        },
                        onValueChanged: (int value) {
                          setState(() {
                            _selectedPlatformIndex = value;
                          });
                        },
                        groupValue: _selectedPlatformIndex,
                        selectedColor: Colors.blue,
                        borderColor: Colors.blue,
                        padding: const EdgeInsets.all(4),
                      ),
                    ),
                    SizedBox(height: 24),
                    
                    // App Store URLs
                    TextField(
                      controller: _appStoreController,
                      decoration: InputDecoration(
                        labelText: 'iOS App Store ID',
                        border: OutlineInputBorder(),
                        hintText: 'e.g., 123456789',
                      ),
                      onChanged: (val) {
                        _settings['iosId'] = val;
                        _checkForChanges();
                      },
                    ),
                    SizedBox(height: 12),
                    TextField(
                      controller: _playStoreController,
                      decoration: InputDecoration(
                        labelText: 'Android Package ID',
                        border: OutlineInputBorder(),
                        hintText: 'e.g., com.example.myapp',
                      ),
                      onChanged: (val) {
                        _settings['androidId'] = val;
                        _checkForChanges();
                      },
                    ),
                    SizedBox(height: 24),
                    
                    // Version management
                    _buildVersionsList(),
                    SizedBox(height: 24),
                    
                    // Save button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _hasChanges && !_saving ? _saveSettings : null,
                        child: _saving 
                            ? SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : Text('Save Changes'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
} 