import 'package:flutter/material.dart';
import 'package:my_flutter_proj_dq/data/constants.dart';
import 'package:my_flutter_proj_dq/data/notifiers.dart';
import 'package:my_flutter_proj_dq/views/pages/welcome_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
//import 'package:my_flutter_proj_dq/views/widget_tree.dart';
//import 'package:my_flutter_proj_dq/widgets/NavBarWidget.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
void main() async{
  WidgetsFlutterBinding.ensureInitialized();
await Firebase.initializeApp(
  options: DefaultFirebaseOptions.currentPlatform,
);
  runApp(const MyApp());
}

String? title;

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    initThemeMode();
    super.initState();
  }

  void initThemeMode() async
  {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final bool? repeat = prefs.getBool(Kconstants.isDarkKey);
    pageThemeNotifier.value = repeat ?? false;
  }

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
