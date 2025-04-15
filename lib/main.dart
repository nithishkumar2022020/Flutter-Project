import 'package:flutter/material.dart';
import 'package:my_flutter_proj_dq/data/notifiers.dart';
import 'package:my_flutter_proj_dq/views/pages/welcome_page.dart';
//import 'package:my_flutter_proj_dq/views/widget_tree.dart';
//import 'package:my_flutter_proj_dq/widgets/NavBarWidget.dart';

void main() {
  runApp(const MyApp());
}

String? title;

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: pageThemeNotifier,
      builder: (context, darkMode, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.tealAccent,
              brightness: darkMode ? Brightness.light : Brightness.dark,
            ),
          ),
          home: WelcomePage(),
        );
      },
    );
  }
}
