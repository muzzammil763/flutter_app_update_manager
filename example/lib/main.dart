import 'package:flutter/material.dart';
import 'package:flutter_app_update_manager/flutter_app_update_manager.dart';

void main() {
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
  DialogStyle currentDialogStyle = DialogStyle.defaultStyle;
  String appName = "XTREM";

  @override
  void initState() {
    super.initState();
    // Show update dialog on app start for demo purposes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showUpdateDialog();
    });
  }

  void _showUpdateDialog() {
    AppUpdateManager(
      context: context,
      appName: appName,
      dialogStyle: currentDialogStyle,
      customDialog: currentDialogStyle == DialogStyle.custom ? CustomUpdateDialogImpl() : null,
    ).checkForUpdate();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Dialog Style Selection',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    SizedBox(height: 16),
                    DropdownButtonFormField<DialogStyle>(
                      value: currentDialogStyle,
                      decoration: InputDecoration(
                        labelText: 'Select Dialog Style',
                        border: OutlineInputBorder(),
                      ),
                      items: DialogStyle.values.map((style) {
                        return DropdownMenuItem(
                          value: style,
                          child: Text(style.name),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            currentDialogStyle = value;
                          });
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'App Name',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    SizedBox(height: 16),
                    TextField(
                      decoration: InputDecoration(
                        labelText: 'App Name',
                        border: OutlineInputBorder(),
                        hintText: 'Enter app name (e.g., XTREM)',
                      ),
                      onChanged: (value) {
                        setState(() {
                          appName = value.isNotEmpty ? value : "XTREM";
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _showUpdateDialog,
              icon: Icon(Icons.system_update),
              label: Text('Test Update Dialog'),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 16),
              ),
            ),
            SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Features',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    SizedBox(height: 16),
                    _buildFeatureItem('✅ Multiple dialog styles available'),
                    _buildFeatureItem('✅ Custom dialog support'),
                    _buildFeatureItem('✅ App name customization'),
                    _buildFeatureItem('✅ Force update handling'),
                    _buildFeatureItem('✅ Later button auto-hide for force updates'),
                    _buildFeatureItem('✅ Firebase Firestore integration'),
                    _buildFeatureItem('✅ Auto setup for first-time users'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          SizedBox(width: 8),
          Expanded(child: Text(text)),
        ],
      ),
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
        padding: EdgeInsets.all(24),
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
              padding: EdgeInsets.all(16),
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
            SizedBox(height: 16),
            Text(
              '🚀 New Version Available!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.blue.shade700,
              ),
            ),
            SizedBox(height: 8),
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[700],
                ),
                children: [
                  TextSpan(text: 'A new version of '),
                  TextSpan(
                    text: appName,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade700,
                    ),
                  ),
                  TextSpan(text: ' is available!'),
                ],
              ),
            ),
            SizedBox(height: 24),
            Row(
              children: [
                if (!isForceUpdate && onLater != null) ...[
                  Expanded(
                    child: OutlinedButton(
                      child: Text('Maybe Later'),
                      onPressed: onLater,
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  SizedBox(width: 12),
                ],
                Expanded(
                  child: ElevatedButton(
                    child: Text('Update Now'),
                    onPressed: onUpdate,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade700,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 12),
                    ),
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