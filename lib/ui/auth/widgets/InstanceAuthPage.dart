import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:go_router/go_router.dart';
import 'package:mobileapp/routing/routes.dart';
import 'package:mobileapp/ui/auth/widgets/RulesRenderer.dart';
import 'package:mobileapp/ui/utils/InstanceLink.dart';
import 'TermsRenderer.dart';

class InstanceAuthPage extends StatelessWidget {
  final Map<String, dynamic> instanceData;
  const InstanceAuthPage({super.key, required this.instanceData});

  @override
  Widget build(BuildContext context) {
    final title = instanceData['title'] ?? instanceData['uri'] ?? 'Unknown';
    final description = instanceData['short_description'] ?? '';
    final uri = instanceData['uri'] ?? '';
    final thumbnail = instanceData['thumbnail'];
    final registrations = instanceData['registrations'] == true;
    final invitesEnabled = instanceData['invites_enabled'] == true;

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (thumbnail != null)
                  CircleAvatar(
                    radius: 40,
                    backgroundImage: NetworkImage(thumbnail),
                    backgroundColor: Colors.grey[200],
                  ),
                const SizedBox(height: 16),
                Text(title, style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 8),
                if (description.isNotEmpty)
                  Html(
                    data: description,
                    style: {
                      "body": Style(
                        fontSize: FontSize(15),
                        color: Colors.grey[800],
                        textAlign: TextAlign.center,
                      ),
                      "b": Style(fontWeight: FontWeight.bold),
                      "i": Style(fontStyle: FontStyle.italic),
                      "p": Style(margin: Margins.only(bottom: 8)),
                    },
                  ),
                if (uri.isNotEmpty) InstanceLink(uri: uri),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: registrations
                        ? Colors.green.withOpacity(0.1)
                        : Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        registrations ? Icons.lock_open : Icons.lock,
                        color: registrations ? Colors.green : Colors.orange,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          registrations
                              ? (invitesEnabled
                                    ? "Registration is invite only"
                                    : "Registration is open")
                              : "Registration closed — only login",
                          style: TextStyle(fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                ),

                RulesRenderer(rules: instanceData['rules']),
                TermsRenderer(
                  htmlTerms: instanceData['terms'],
                  textFallback: instanceData['terms_text'],
                ),

                const SizedBox(height: 15),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () {
                        context.go(Routes.register);
                      },
                      icon: const Icon(Icons.login),
                      label: const Text("Sign In"),
                    ),
                    const SizedBox(height: 12),
                    if (registrations)
                      OutlinedButton.icon(
                        onPressed: () {
                          context.go(Routes.register);
                        },
                        icon: const Icon(Icons.person_add),
                        label: const Text("Sign Up"),
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
}
