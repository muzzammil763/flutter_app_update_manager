import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_update_manager/flutter_app_update_manager.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp();
  } catch (e) {
    // Handle Firebase initialization errors (e.g., in test environments)
    print('Firebase initialization failed: $e');
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter App Update Manager Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'App Update Manager Demo'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String appName = "Demo App";
  bool showLaterButton = true;
  bool autoSetup = false;
  CustomUpdateDialog? selectedCustomDialog;
  DefaultDialogColors? selectedDialogColors;

  @override
  void initState() {
    super.initState();
    // Show update dialog on app start for demo purposes (skip in test environment)
    if (kDebugMode) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showUpdateDialog();
      });
    }
  }

  void _showUpdateDialog() {
    try {
      AppUpdateManager(
        context: context,
        appName: appName,
        showLaterButton: showLaterButton,
        autoSetup: autoSetup,
        customDialog: selectedCustomDialog,
        dialogColors: selectedDialogColors,
      ).checkForUpdate();
    } catch (e) {
      // Handle Firebase initialization errors (e.g., in test environments)
      debugPrint('Failed to show update dialog: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AppUpdateManagerScreen(),
                ),
              );
            },
            tooltip: 'Manage Update Settings',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // App Configuration Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'App Configuration',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        decoration: const InputDecoration(
                          labelText: 'App Name',
                          border: OutlineInputBorder(),
                          hintText: 'Enter app name (e.g., Demo App)',
                        ),
                        onChanged: (value) {
                          setState(() {
                            appName = value.isNotEmpty ? value : "Demo App";
                          });
                        },
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: CheckboxListTile(
                              title: const Text('Show Later Button'),
                              subtitle: const Text('Allow users to dismiss optional updates'),
                              value: showLaterButton,
                              onChanged: (value) {
                                setState(() {
                                  showLaterButton = value ?? true;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: CheckboxListTile(
                              title: const Text('Auto Setup'),
                              subtitle: const Text('Create Firestore structure automatically'),
                              value: autoSetup,
                              onChanged: (value) {
                                setState(() {
                                  autoSetup = value ?? false;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Custom Dialog Selection Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Dialog Configuration',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: selectedCustomDialog == null ? 'Default' : 'Custom',
                        decoration: const InputDecoration(
                          labelText: 'Dialog Style',
                          border: OutlineInputBorder(),
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: 'Default',
                            child: Text('Default Dialog'),
                          ),
                          DropdownMenuItem(
                            value: 'Custom',
                            child: Text('Custom Dialog'),
                          ),
                        ],
                        onChanged: (value) {
                          setState(() {
                            selectedCustomDialog = value == 'Custom' 
                                ? CustomUpdateDialogImpl() 
                                : null;
                          });
                        },
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        value: selectedDialogColors == null ? 'Default Colors' : 'Custom Colors',
                        decoration: const InputDecoration(
                          labelText: 'Dialog Colors',
                          border: OutlineInputBorder(),
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: 'Default Colors',
                            child: Text('Default Colors'),
                          ),
                          DropdownMenuItem(
                            value: 'Custom Colors',
                            child: Text('Custom Colors'),
                          ),
                        ],
                        onChanged: (value) {
                          setState(() {
                            selectedDialogColors = value == 'Custom Colors' 
                                ? DefaultDialogColors(
                                    buttonColor: Colors.blue,
                                    textColor: Colors.grey[700],
                                    titleColor: Colors.black87,
                                  )
                                : null;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Test Button
              ElevatedButton.icon(
                onPressed: _showUpdateDialog,
                icon: const Icon(Icons.system_update),
                label: const Text('Test Update Dialog'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
              const SizedBox(height: 16),

              // Features Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Package Features',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 16),
                      _buildFeatureItem('✅ Firebase Firestore integration'),
                      _buildFeatureItem('✅ Automatic version comparison'),
                      _buildFeatureItem('✅ Force update handling'),
                      _buildFeatureItem('✅ Custom dialog support'),
                      _buildFeatureItem('✅ Auto setup for first-time users'),
                      _buildFeatureItem('✅ Built-in management screen'),
                      _buildFeatureItem('✅ Platform-specific configuration'),
                      _buildFeatureItem('✅ Default dialog with blur background'),
                      _buildFeatureItem('✅ Dialog color customization'),
                      _buildFeatureItem('✅ Later button auto-hide for force updates'),
                      _buildFeatureItem('✅ Store URL auto-generation'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Usage Examples Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Usage Examples',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 16),
                      _buildCodeExample(
                        'Basic Usage',
                        '''AppUpdateManager(
  context: context,
  appName: "MyApp",
).checkForUpdate();''',
                      ),
                      const SizedBox(height: 12),
                      _buildCodeExample(
                        'With Custom Dialog',
                        '''AppUpdateManager(
  context: context,
  appName: "MyApp",
  customDialog: MyCustomDialog(),
).checkForUpdate();''',
                      ),
                      const SizedBox(height: 12),
                      _buildCodeExample(
                        'With Auto Setup',
                        '''AppUpdateManager(
  context: context,
  autoSetup: true, // ⚠️ Set to false after first run
).checkForUpdate();''',
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          const SizedBox(width: 8),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }

  Widget _buildCodeExample(String title, String code) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: Text(
            code,
            style: const TextStyle(
              fontFamily: 'monospace',
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }
}

// Example custom dialog implementation
class CustomUpdateDialogImpl implements CustomUpdateDialog {
  @override
  Widget build(BuildContext context, {
    required bool isForceUpdate,
    required String appName,
    required VoidCallback onUpdate,
    required VoidCallback? onLater,
  }) {
    return Dialog(
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.blue.shade50, Colors.purple.shade50],
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.rocket_launch,
                size: 48,
                color: Colors.blue.shade700,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              '🚀 New Version Available!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.blue.shade700,
              ),
            ),
            const SizedBox(height: 8),
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[700],
                ),
                children: [
                  const TextSpan(text: 'A new version of '),
                  TextSpan(
                    text: appName,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade700,
                    ),
                  ),
                  const TextSpan(text: ' is available!'),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                if (!isForceUpdate && onLater != null) ...[
                  Expanded(
                    child: OutlinedButton(
                      onPressed: onLater,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text('Maybe Later'),
                    ),
                  ),
                  const SizedBox(width: 12),
                ],
                Expanded(
                  child: ElevatedButton(
                    onPressed: onUpdate,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade700,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text('Update Now'),
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