import 'package:flutter/material.dart';
import 'package:flutter_easy_permission_manager/flutter_easy_permission_manager.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text("Flutter Easy Permissions Example")),
        body: Center(
          child: ElevatedButton(
            onPressed: () async {
              final result = await EasyPermissions.request([
                Permission.camera,
                Permission.microphone,
              ]);

              if (result.allGranted) {
                debugPrint("✅ All permissions granted!");
              } else {
                debugPrint("❌ Still missing: ${result.denied}");
              }
            },
            child: const Text("Request Permissions"),
          ),
        ),
      ),
    );
  }
}
