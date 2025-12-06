import 'package:flutter/material.dart';
import 'package:flutter/material.dart';

enum TimelineOption { publicFederated, publicLocal, home, trends }

class TimelineSettings extends StatefulWidget {
  const TimelineSettings({super.key});

  @override
  State<TimelineSettings> createState() => _TimelineSettingsState();
}

class _TimelineSettingsState extends State<TimelineSettings> {
  TimelineOption? _selectedTimeline = TimelineOption.home;

  final Map<TimelineOption, String> _timelineDescriptions = {
    TimelineOption.publicFederated:
        "Public Federated: Semua post publik dari seluruh server (instance) yang terhubung ke jaringan.",
    TimelineOption.publicLocal:
        "Public Local: Post publik hanya dari server/instance-mu sendiri.",
    TimelineOption.home:
        "Home: Timeline pribadi, menampilkan post dari akun yang kamu follow.",
    TimelineOption.trends:
        "Trends: Post populer yang banyak interaksi, global atau lokal tergantung server.",
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Timeline Settings"),
      ),
      body: ListView(
        children: TimelineOption.values.map((option) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // RadioListTile<TimelineOption>(
              //   title: Text(option.name.replaceAll(RegExp(r'([A-Z])'), ' $').trim()),
              //   value: option,
              //   groupValue: _selectedTimeline,
              //   onChanged: (value) {
              //     setState(() {
              //       _selectedTimeline = value;
              //     });
              //   },
              // ),
              // if (_selectedTimeline == option)
              //   Padding(
              //     padding: const EdgeInsets.symmetric(horizontal: 16.0),
              //     child: Text(
              //       _timelineDescriptions[option] ?? "",
              //       style: const TextStyle(color: Colors.grey),
              //     ),
              //   ),
            ],
          );
        }).toList(),
      ),
    );
  }
}
