import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

class EmojiText extends StatefulWidget {
  final String content;
  final List emojis;
  const EmojiText({super.key, required this.content, required this.emojis});

  @override
  State<EmojiText> createState() => _EmojiTextState();
}

class _EmojiTextState extends State<EmojiText> {
  late String htmlContent;
  Map<String, Style> htmlStyle = {
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

  @override
  void initState() {
    super.initState();
    htmlContent = widget.content;
    _loadEmojis();
  }

  Future<void> _loadEmojis() async {
    final Map<String, String> emojiMap = {
      for (final e in widget.emojis) e['shortcode']: e['url'],
    };

    final buffer = StringBuffer();
    int lastIndex = 0;
    final regex = RegExp(r':([a-zA-Z0-9_]+):');

    for (final match in regex.allMatches(widget.content)) {
      buffer.write(widget.content.substring(lastIndex, match.start));
      final shortcode = match.group(1)!;
      if (emojiMap.containsKey(shortcode)) {
        buffer.write(
          '<img src="${emojiMap[shortcode]}" '
          'style="width:20px;height:20px;vertical-align:middle;"/>',
        );
      } else {
        buffer.write(match.group(0));
      }
      lastIndex = match.end;
    }

    buffer.write(widget.content.substring(lastIndex));

    // simulasi loading sebentar
    await Future.delayed(Duration(milliseconds: 50));

    setState(() {
      htmlContent = buffer.toString();
    });
  }

  @override
  void didUpdateWidget(covariant EmojiText oldWidget) {
    super.didUpdateWidget(oldWidget);
    // kalau content atau emojis berubah, reload emoji
    if (oldWidget.content != widget.content ||
        oldWidget.emojis != widget.emojis) {
      htmlContent = widget.content;
      _loadEmojis();
    }
  }

  void _action(
    String? url,
    Map<String, String> attributes,
    dynamic element,
  ) async {
    final text = element?.text.trim() ?? url ?? '';

    if (text.isEmpty) return;
    // Cek hashtag
    if (text.startsWith('#')) {
      final tag = text.substring(1); // hapus #
      context.push("/tags/$tag"); // navigasi ke halaman tag
      return;
    }

    String host, acct;

    if (text.startsWith('@')) {
      final username = text.substring(1); // hapus @
      final href = attributes['href'].toString();
      final uri = Uri.parse(href);
      host = uri.host; // "flipboard.com"
      print('Host: $host');

      final parts = username.split('@');

      acct = parts[0];

      final userLookup = "@$acct@$host";
      print(userLookup);
      // context.push(Routes.profile, extra: userLookup);

      return;
    }

    final uri = Uri.parse(url!.startsWith('http') ? url : 'https://$url');
    launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    return htmlContent.contains('<img')
        ? Html(
            data: htmlContent,
            onLinkTap: (url, attributes, element) async {
              _action(url, attributes, element);
            },
            style: htmlStyle,
          )
        : Stack(
            children: [
              Html(
                data: htmlContent,
                onLinkTap: (url, attributes, element) async {
                  _action(url, attributes, element);
                },
                style: htmlStyle,
              ), // teks muncul dulu
            ],
          );
  }
}
