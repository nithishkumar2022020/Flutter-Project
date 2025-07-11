import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:my_flutter_proj_dq/data/activity_class.dart';
//import 'package:my_flutter_proj_dq/views/pages/home_page.dart';
import 'package:my_flutter_proj_dq/views/widget_tree.dart';
//import 'package:my_flutter_proj_dq/views/widgets/hero_widget.dart';

import 'dart:convert' as convert;

import 'package:http/http.dart' as http;

class coursePage extends StatefulWidget {
  const coursePage({
    super.key,
    
  }
  );



  @override
  State<coursePage> createState() => _coursePageState();
}


class _coursePageState extends State<coursePage> {

  @override
  void initState() {
    getData();
        super.initState();
  }
  Future getData() async {
    
  
  var url =
      Uri.https('bored-api.appbrewery.com', '/random', {'q': '{http}'});

  var response = await http.get(url);
  if (response.statusCode == 200) {
   
    return Activity.fromJson(convert.jsonDecode(response.body) as Map<String, dynamic>);
  } else {
    
    throw Exception('Failed to load data');
  }
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
                  return WidgetTree();
                },
              ),
            );
          },
          icon: Icon(Icons.arrow_back_ios_new),
        ),
        title: Text(''),
      ),
      body: FutureBuilder(future: getData(), builder: (context, AsyncSnapshot snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        if (snapshot.hasData)
        {
          Activity activity = snapshot.data;
          return Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                Lottie.asset('assets/lotties/Blue Loading.json'),
                
                SizedBox(height: 120),
                  
                  SizedBox(height: 60),
                  Text(activity.activity,),
                  SizedBox(height: 10),
                    FilledButton(onPressed: () {
                      Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) {
                          return WidgetTree(
                            
                          );
                        },
                      ),
            
                    );
                    }, 
                    style: FilledButton.styleFrom(
                      minimumSize: Size(double.infinity, 40.0),
                    ),
                    child: Text('Lets Gooo!!!'),
                    ),
                  
                
              ],
            ),
          ),
        ),
      );
        } else{
          return Center(
            child: Text('No data available'),
          );
        }
      },
      )
    );
  }
}