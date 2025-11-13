import 'package:flutter/material.dart';

class RulesRenderer extends StatelessWidget {
  final List<dynamic>? rules;

  const RulesRenderer({Key? key, this.rules}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Kalau rules kosong / null, jangan tampilkan apapun
    if (rules == null || rules!.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Rules",
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: List.generate(rules!.length, (index) {
                final rule = rules![index];
                final text = rule['text'] ?? '';
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "• ",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[700],
                        ),
                      ),
                      Expanded(
                        child: Text(
                          text,
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.grey[800],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}
