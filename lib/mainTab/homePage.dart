import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../Notification/Noti.dart';
import '../service/PreferencesService.dart';
import '../sideTab/PreferencesScreen.dart';
import 'FinderTab/FinderTab.dart';
import 'ListTab/ListTab.dart';
import 'StatisticsTab/StatisticsTab.dart';

class MyHomePage extends StatefulWidget {
  final String title;
  final int selectedTab;

  const MyHomePage({
    super.key,
    required this.title,
    this.selectedTab = 0, required PreferencesService preferencesService,
  });

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    Noti.initialize();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        centerTitle: true,

        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.trending_up_outlined), text: 'Statistics'),
            Tab(icon: Icon(Icons.search), text: 'Finder'),
            Tab(icon: Icon(Icons.list), text: 'List'),
          ],
        ),
      ),
      drawer: Drawer(
          child: Container(
            color: Colors.white,
            child: ListView(
              padding: EdgeInsets.zero,
              children: <Widget>[
                const DrawerHeader(
                  decoration: BoxDecoration(
                    color: Colors.red,
                  ),
                  child: Text('Options', style: TextStyle(color: Colors.black, fontSize: 36)),
                ),
                ListTile(
                  leading: Icon(Icons.settings),
                  title: Text('Preferences'),
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => PreferencesScreen(),
                    ));
                  },
                ),
              ],
            ),
          )
      ),
      body: SafeArea(
        bottom: true,
        child :TabBarView(
          controller: _tabController,
          children:  [
            const StatisticsTab(),
            FinderTab(),
            const ListTab(),
          ],
        ),
      ),
    );
  }
}
