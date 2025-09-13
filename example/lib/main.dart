import 'package:flutter/material.dart';
import 'package:flutter_easy_permission_manager/flutter_easy_permission_manager.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(title: const Text("Flutter Easy Permissions Example")),
        body: const PermissionDemo(),
      ),
    );
  }
}

class PermissionDemo extends StatefulWidget {
  const PermissionDemo({super.key});

  @override
  State<PermissionDemo> createState() => _PermissionDemoState();
}

class _PermissionDemoState extends State<PermissionDemo> {
  String _status = "Idle";

  void _updateStatus(String msg) {
    setState(() => _status = msg);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ElevatedButton(
            onPressed: () async {
              final result = await EasyPermissions.request([
                Permission.camera,
                Permission.microphone,
              ]);

              if (result.allGranted) {
                _updateStatus("✅ All permissions granted!");
              } else {
                _updateStatus("❌ Still missing: ${result.denied}");
              }
            },
            child: const Text("Request Multiple Permissions"),
          ),
          ElevatedButton(
            onPressed: () async {
              final granted = await EasyPermissions.areAllGranted([
                Permission.camera,
                Permission.microphone,
              ]);
              _updateStatus(granted
                  ? "✅ All required permissions are granted."
                  : "❌ Some permissions are still missing.");
            },
            child: const Text("Check if All Granted"),
          ),
          ElevatedButton(
            onPressed: () async {
              final statuses = await EasyPermissions.getStatuses([
                Permission.camera,
                Permission.microphone,
              ]);
              _updateStatus("📋 Statuses: $statuses");
            },
            child: const Text("Get Statuses"),
          ),
          ElevatedButton(
            onPressed: () async {
              final status =
                  await EasyPermissions.requestSingle(Permission.camera);
              _updateStatus("🎯 Camera permission: $status");
            },
            child: const Text("Request Single Permission"),
          ),
          ElevatedButton(
            onPressed: () {
              EasyPermissions.setAutoInjectionEnabled(true);
              _updateStatus("⚡ Auto-injection enabled globally!");
            },
            child: const Text("Enable Auto-Injection"),
          ),
          const SizedBox(height: 20),
          Text("Current Status: $_status",
              style: const TextStyle(fontSize: 16)),
        ],
      ),
    );
  }
}
