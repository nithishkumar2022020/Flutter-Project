import 'package:flutter/material.dart';
import 'package:my_flutter_proj_dq/data/notifiers.dart';
import 'package:my_flutter_proj_dq/views/pages/home_page.dart';
import 'package:my_flutter_proj_dq/views/pages/profile_page.dart';

import 'package:my_flutter_proj_dq/views/NavBarWidget.dart';
import 'package:my_flutter_proj_dq/views/pages/settings_page.dart';
//import 'package:my_flutter_proj_dq/views/pages/settings_page.dart';

List<Widget> pages = [HomePage(), ProfilePage(), settingsPage()];

class WidgetTree extends StatelessWidget {
  const WidgetTree({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('flutter'),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) {
                    return settingsPage();
                  },
                ),
              );
            },
            icon: Icon(Icons.settings),
          ),

          IconButton(
            onPressed: () {
              pageThemeNotifier.value = !pageThemeNotifier.value;
            },
            icon: ValueListenableBuilder(
              valueListenable: pageThemeNotifier,
              builder: (context, darkMode, child) {
                return Icon(darkMode ? Icons.dark_mode : Icons.light_mode);
              },
            ),
          ),
        ],
      ),
      body: ValueListenableBuilder(
        valueListenable: selectedPageNotifier,
        builder: (context, selectedPage, child) {
          return pages.elementAt(selectedPage);
        },
      ),
      bottomNavigationBar: navbarwidgett(),
    );
  }
}
