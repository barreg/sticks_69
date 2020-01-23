import 'package:flutter/material.dart';
import 'package:sticks_69/MapPage.dart';
import 'package:sticks_69/PicturesPage.dart';

class StartPage extends StatefulWidget {
  @override
  _StartPageState createState() => _StartPageState();
}

class _StartPageState extends State<StartPage>
    with SingleTickerProviderStateMixin {
  TabController _tabController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = new TabController(vsync: this, length: 2);
    _tabController.addListener(() => setState(() {
          _currentIndex = _tabController.index;
        }));
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        backgroundColor: Theme.of(context).primaryColor,
        selectedItemColor: Theme.of(context).focusColor,
        unselectedItemColor: Theme.of(context).backgroundColor,
        selectedFontSize: 25,
        unselectedFontSize: 20,
        onTap: (index) {
          _tabController.animateTo(index);
          setState(() {
            _currentIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(
              icon: Icon(Icons.map), title: Text("Sticks Map")),
          BottomNavigationBarItem(
              icon: Icon(Icons.image), title: Text("Kroon Pics"))
        ],
      ),
      body: TabBarView(
        physics: NeverScrollableScrollPhysics(),
        controller: _tabController,
        children: [
          new MapPage(),
          new PicturesPage(),
        ],
      ),
    );
  }
}
