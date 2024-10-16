import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math' as math;

void main() {
  runApp(const MainApp());
}

// Added Launch model
class Launch {
  String? missionName;
  String? missionId;
  List<String>? manufacturers;
  List<String>? payloadIds;
  String? wikipedia;
  String? website;
  String? twitter;
  String? description;

  Launch(
      {this.missionName,
      this.missionId,
      this.manufacturers,
      this.payloadIds,
      this.wikipedia,
      this.website,
      this.twitter,
      this.description});

  Launch.fromJson(Map<String, dynamic> json) {
    missionName = json['mission_name'];
    missionId = json['mission_id'];
    manufacturers = json['manufacturers'].cast<String>();
    payloadIds = json['payload_ids'].cast<String>();
    wikipedia = json['wikipedia'];
    website = json['website'];
    twitter = json['twitter'];
    description = json['description'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['mission_name'] = this.missionName;
    data['mission_id'] = this.missionId;
    data['manufacturers'] = this.manufacturers;
    data['payload_ids'] = this.payloadIds;
    data['wikipedia'] = this.wikipedia;
    data['website'] = this.website;
    data['twitter'] = this.twitter;
    data['description'] = this.description;
    return data;
  }
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(home: SpacesMissionPage());
  }
}

class SpacesMissionPage extends StatefulWidget {
  const SpacesMissionPage({super.key});

  @override
  State<SpacesMissionPage> createState() => _SpacesMissionPageState();
}

class _SpacesMissionPageState extends State<SpacesMissionPage> {
  List<Launch> launchList = [];
  bool expanded = false;
  bool isLoading = true;

  Future<void> fetchLaunches() async {
    try {
      final response =
          await http.get(Uri.parse("https://api.spacexdata.com/v3/missions"));

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes)) as List;
        setState(() {
          launchList = data.map((launch) => Launch.fromJson(launch)).toList();
          isLoading = false;
        });
      }
    } catch (e) {
      throw Exception("Failed to fetch launches");
    }
  }

  @override
  void initState() {
    super.initState();
    fetchLaunches();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Space Missions'),
        backgroundColor: Colors.teal[900],
        titleTextStyle: const TextStyle(color: Colors.white, fontSize: 20),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: launchList.length,
              itemBuilder: (c, i) {
                final launch = launchList[i];
                return MissionCard(
                  launch: launch,
                  key: Key('$i'),
                );
              },
            ),
    );
  }
}

class MissionCard extends StatefulWidget {
  final Launch launch;
  const MissionCard({super.key, required this.launch});

  @override
  State<MissionCard> createState() => _MissionCardState();
}

class _MissionCardState extends State<MissionCard> {
  bool expanded = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: const [
          BoxShadow(
            color: Colors.grey,
            offset: Offset(
              1.0,
              2.0,
            ),
            blurRadius: 2.0,
            spreadRadius: 0.0,
          ), //BoxShadow
          BoxShadow(
            color: Colors.white,
            offset: Offset(0.0, 0.0),
            blurRadius: 0.0,
            spreadRadius: 0.0,
          ), //BoxShadow
        ],
        borderRadius: BorderRadius.circular(10.0),
      ),
      margin: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      padding: const EdgeInsets.all(8),
      child: Column(
        children: [
          ListTile(
            title: Text('${widget.launch.missionName}',
                style: const TextStyle(fontWeight: FontWeight.w500)),
            subtitle: Text(
              '${widget.launch.description}',
              overflow: expanded ? TextOverflow.visible : TextOverflow.ellipsis,
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              MaterialButton(
                  onPressed: () {
                    setState(() {
                      expanded = !expanded;
                    });
                  },
                  child: expanded
                      ? ChipPill(
                          label: "Less 🔼",
                          color: Colors.grey.shade300,
                          textColor: Colors.blue,
                        )
                      : ChipPill(
                          label: "More 🔽",
                          color: Colors.grey.shade300,
                          textColor: Colors.blue)),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(children: [
              if (widget.launch.payloadIds != null)
                Wrap(
                  spacing: 5,
                  runSpacing: 5,
                  children: widget.launch.payloadIds!.map((payloadId) {
                    Color color =
                        Color((math.Random().nextDouble() * 0xFFFFFF).toInt())
                            .withOpacity(1.0);
                    return ChipPill(
                      label: payloadId,
                      color: color,
                      textColor: Colors.white,
                      key: UniqueKey(),
                    );
                  }).toList(),
                )
            ]),
          )
        ],
      ),
    );
  }
}

class ChipPill extends StatefulWidget {
  final label;
  final Color color;
  final Color textColor;
  const ChipPill(
      {super.key,
      required this.label,
      required this.color,
      required this.textColor});

  @override
  State<ChipPill> createState() => _ChipPillState();
}

class _ChipPillState extends State<ChipPill> {
  @override
  Widget build(BuildContext context) {
    return Chip(
      backgroundColor: widget.color,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(100),
        side: const BorderSide(color: Colors.white),
      ),
      label: Text(widget.label, style: TextStyle(color: widget.textColor)),
    );
  }
}
