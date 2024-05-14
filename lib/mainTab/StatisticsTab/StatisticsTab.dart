import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../main.dart';
import '../../provider/TerpiezCounterProvider.dart';
import '../../provider/UserIdProvider.dart';

class StatisticsTab extends StatelessWidget {
  const StatisticsTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final terpiezProvider = Provider.of<TerpiezCounterProvider>(context);
    final terpiezCaught = terpiezProvider.terpiezCaught;
    final activeDays = terpiezProvider.activeDays;

    return FutureBuilder<String>(
      future: Provider.of<UserIdProvider>(context, listen: false).getUserId(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          print("Error loading user ID: ${snapshot.error}");
          return buildStatistics(context, "Error loading ID", terpiezCaught, activeDays);
        }

        final userId = snapshot.data ?? "Unknown ID";
        return buildStatistics(context, userId, terpiezCaught, activeDays);
      },
    );
  }

  Widget buildStatistics(BuildContext context, String userId, int terpiezCaught, int activeDays) {
    bool isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;
    double titleFontSize = isPortrait ? 48 : 36;
    double subTitleFontSize = isPortrait ? 24 : 18;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                'Statistics',
                style: TextStyle(fontSize: titleFontSize),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 8.0),
            child: Text(
              'Terpiez found:       $terpiezCaught',
              style: TextStyle(fontSize: subTitleFontSize),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 8.0),
            child: Text(
              'Day active:             $activeDays',
              style: TextStyle(fontSize: subTitleFontSize),
            ),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Text(
                'User: $userId',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.black54,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}