import 'package:flutter/material.dart';
import 'package:my_flutter_proj_dq/views/pages/home_page.dart';
import 'package:my_flutter_proj_dq/views/pages/welcome_page.dart';
import 'package:my_flutter_proj_dq/views/widget_tree.dart';
import 'package:my_flutter_proj_dq/views/widgets/hero_widget.dart';

TextEditingController controllerEmail = TextEditingController();
TextEditingController controllerPassword = TextEditingController();
String email='123';
String password='123';
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  void dispose() {
    controllerPassword.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) {
                  return WelcomePage();
                },
              ),
            );
          },
          icon: Icon(Icons.arrow_back_ios_new),
        ),
        title: Text('Login'),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                HeroWidget(title: 'login'),
                SizedBox(height: 20),
                  TextField(
                    controller: controllerEmail,
                    decoration: InputDecoration(
                      hintText: 'Enter your email',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    onEditingComplete: () {
                      setState(() {});
                    },
                  ),
                
                SizedBox(height: 10),
                  TextField(
                    controller: controllerPassword,
                    decoration: InputDecoration(
                      hintText: 'Enter your password',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    onEditingComplete: () {
                      setState(() {});
                    },
                  ),
                  SizedBox(height: 20),
                    ElevatedButton(onPressed: () {
                      LoginonPressed();
                    }, 
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size(double.infinity, 40.0),
                    ),
                    child: Text('login'),
                    ),
                  
                
              ],
            ),
          ),
        ),
      ),
    );
  }
  void LoginonPressed() {
    if (email == controllerEmail.text && password == controllerPassword.text) {
    Navigator.push(
                    context, MaterialPageRoute(
                      builder: (
                        context) {
                    return WidgetTree();
                  },
                  ),
                  );

  }
}
}