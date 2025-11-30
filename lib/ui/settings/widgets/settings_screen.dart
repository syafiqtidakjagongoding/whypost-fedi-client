import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobileapp/routing/routes.dart';
import 'package:mobileapp/ui/settings/widgets/about.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        centerTitle: true,
        backgroundColor: Color.fromRGBO(255, 117, 31, 1),
        titleTextStyle: const TextStyle(
          fontSize: 23,
          fontWeight: FontWeight.bold,
        ),
      ),
      body: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.cloud),
            title: const Text("Node Info"),
            onTap: () {
              context.push(Routes.nodeInfo);
            },
          ),
          const Divider(height: 0),

          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text("About App"),
            onTap: () {
              // Arahkan ke halaman AboutApp
              context.push(Routes.aboutApp);
            },
          ),
          const Divider(height: 0),
        ],
      ),
    );
  }
}
