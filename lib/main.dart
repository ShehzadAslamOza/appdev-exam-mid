import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

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
        title: Text('Space Missions'),
        backgroundColor: Colors.teal[900],
        titleTextStyle: TextStyle(color: Colors.white, fontSize: 20),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: launchList.length,
              itemBuilder: (c, i) {
                final launch = launchList[i];
                return Container(
                  margin: EdgeInsets.all(8),
                  child: Column(
                    children: [
                      ListTile(
                        title: Text('${launch.missionName}'),
                        subtitle: Text('${launch.description}'),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
