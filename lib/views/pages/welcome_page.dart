import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:my_flutter_proj_dq/main.dart';
import 'package:my_flutter_proj_dq/views/pages/login_page.dart';
import 'package:my_flutter_proj_dq/views/widget_tree.dart';
//import 'package:my_flutter_proj_dq/views/widgets/hero_widget.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Lottie.asset('assets/lotties/Animation - 1743147138262 (1).json',height: 400.0),
                FittedBox(
                  child: Text(
                    'Web Knot',
                    style: TextStyle(
                      fontSize: 50.0,
                      fontWeight: FontWeight.w100,
                      letterSpacing: 10.0,
                    ),
                  ),
                ),
                FilledButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) {
                          return LoginPage(title: "Register");
                        },
                      ),
            
                    );
                  },
                  style: FilledButton.styleFrom(
                    minimumSize: Size(double.infinity, 40.0),
                  ),
                  child: Text('Get Started'),
                ),
                OutlinedButton(onPressed: () {
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) {
                    return LoginPage(title:'Login'
                    );
                  },
                  ),
                  );
                },
                style: FilledButton.styleFrom(
                    minimumSize: Size(double.infinity, 40.0),
               
                ),child: Text('Login'),
                ),
                ],
            ),
          ),
        ),
      ),
    );
  }
}
