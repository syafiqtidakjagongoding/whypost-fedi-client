import 'package:intl/intl.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:mobileapp/routing/routes.dart';
import 'package:mobileapp/ui/utils/ExpandableHTML.dart';
import 'package:url_launcher/url_launcher.dart';

class UserInfoTextCard extends StatelessWidget {
  final Map<String, dynamic> account;

   UserInfoTextCard({super.key, required this.account});

  void _action(
    String? url,
    Map<String, String> attributes,
    dynamic element,
  ) async {
    final text = element?.text.trim() ?? url ?? '';
    if (text.isEmpty) return;

    final uri = Uri.parse(url!.startsWith('http') ? url : 'https://$url');
    launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  final Map<String, Style> htmlStyle = {
    "body": Style(
      fontSize: FontSize(15),
      margin: Margins.zero,
      padding: HtmlPaddings.zero,
      lineHeight: LineHeight(1.5),
    ),
    "p": Style(margin: Margins.only(bottom: 8), color: Colors.black87),
    "b": Style(fontWeight: FontWeight.bold),
    "i": Style(fontStyle: FontStyle.italic),
    "span": Style(fontSize: FontSize(15), color: Colors.black87),
    "a": Style(
      color: Color.fromRGBO(255, 117, 31, 1),
      textDecoration: TextDecoration.none,
      fontWeight: FontWeight.w600,
    ),
  };

  Widget build(BuildContext context) {
    final displayName = account['display_name'] ?? account['username'];
    final username = account['acct'] ?? account['username'];
    final emojis = account['emojis'] as List<dynamic>? ?? [];
    final fields = account['fields'] as List<dynamic>? ?? [];
    final roles = account['roles'] as List<dynamic>? ?? [];
    final role = account['role'] as Map<String, dynamic>?;
    final language = account['language'] ?? "";
    DateTime? createdAt;
    if (account['created_at'] != null) {
      createdAt = DateTime.parse(account['created_at']).toLocal();
    }

    DateTime? lastStatusAt;
    if (account['last_status_at'] != null) {
      lastStatusAt = DateTime.parse(account['last_status_at']).toLocal();
    }

    final createdAtText = createdAt != null
        ? DateFormat('yyyy-MM-dd HH:mm').format(createdAt)
        : 'N/A';
    final lastStatusAtText = lastStatusAt != null
        ? DateFormat('yyyy-MM-dd HH:mm').format(lastStatusAt)
        : 'N/A';
    return Card(
      color: Color.fromARGB(230, 255, 255, 255),
      margin: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Display name + username + emojis
            Row(
              children: [
                Text(
                  displayName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 4),
                ...emojis.map((e) => Text(" :${e['shortcode']}: ")),
              ],
            ),
            const SizedBox(height: 4),
            Text("@$username"),
            const SizedBox(height: 8),

            // Note / bio
            if (account['note'] != null &&
                account['note'].toString().isNotEmpty)
              Html(data: account['note'], style: htmlStyle,onLinkTap: _action),

            // Custom fields
            if (fields.isNotEmpty)
              ...fields.map((f) => Text("${f['name']}: ${f['value']}")),

            const SizedBox(height: 8),

            Text("Language $language"),
            // Status flags
            Row(
              children: [
                if (account['bot'] == true) const Text("[BOT] "),
                if (account['locked'] == true) const Text("[LOCKED] "),
                if (account['suspended'] == true) const Text("[SUSPENDED] "),
              ],
            ),

            const SizedBox(height: 8),

            // Role
            if (role != null) Text("Role: ${role['name']}"),

            // Roles
            if (roles.isNotEmpty)
              Text("Roles: ${roles.map((r) => r['name']).join(', ')}"),

            const SizedBox(height: 8),

            // URL
            if (account['url'] != null) Text("Profile URL: ${account['url']}"),

            // Source info
            if (account['source'] != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Source:"),
                  if ((account['source']['fields'] as List<dynamic>?) != null)
                    ...((account['source']['fields'] as List<dynamic>?)?.map(
                          (f) => Text("  ${f['name']}: ${f['value']}"),
                        ) ??
                        []),
                  if (account['source']['language'] != null)
                    Text("  Language: ${account['source']['language']}"),
                  if (account['source']['privacy'] != null)
                    Text("  Privacy: ${account['source']['privacy']}"),
                  if (account['source']['sensitive'] != null)
                    Text(
                      "  Sensitive: ${account['source']['sensitive'] ? 'Yes' : 'No'}",
                    ),
                ],
              ),
            Text("Joined: $createdAtText"),
            Text("Last Status: $lastStatusAtText"),
          ],
        ),
      ),
    );
  }
}
