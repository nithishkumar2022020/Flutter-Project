import 'package:flutter/material.dart';

class settingsPage extends StatefulWidget {
  const settingsPage({super.key});

  @override
  State<settingsPage> createState() => _settingsPageState();
}

class _settingsPageState extends State<settingsPage> {
  TextEditingController controller = TextEditingController();
  bool? isChecked = false; // Declare isChecked as nullable (bool?)
  bool isSwitched = false;
  double sliderValue = 0.0;
  String? dropdownValue;

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar:AppBar(title: Text('settings'),
    ) ,
    body: SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(
                  context).showSnackBar(
                    SnackBar(
                      duration: Duration(seconds: 5),
                      behavior: SnackBarBehavior.floating,
                      content: Text(
                        'snackbar'),
                ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                foregroundColor: Colors.white,
              ),
              child: Text("Open snackBar"),
            ),
            Divider(
              thickness: 2,
            ),
            // Container(
            //   height: 50.0,
            //   child: VerticalDivider(),
            // ),
            ElevatedButton(
              onPressed: () {
                showDialog(context: context, builder: (context) {
                  return AlertDialog(
                    title: Text('dialog'),
                    content: Text('dialog content'),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text('close'),
                      ),
                    ],
                  );
                },
                );
                return ;
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                foregroundColor: Colors.white,
              ),
              child: Text("Open Dialog"),
            ),
            DropdownButton<String>(
              value: dropdownValue='e1', // Ensure this value matches one of the items in the list
              items: [
                DropdownMenuItem(
                  value: 'e1',
                  child: Text("option 1"),
                ),
                DropdownMenuItem(
                  value: 'e2',
                  child: Text("option 2"),
                ),
                DropdownMenuItem(
                  value: 'e4',
                  child: Text("option 3"),
                ),
              ],
              onChanged: (String? value) {
                // Handle the selected value
                setState(() {
                  dropdownValue = value;
                });
              },
            ),
            
            Text(controller.text),
            Checkbox(
              tristate: true,
              value: isChecked ?? false, // Handle null case for Checkbox
              onChanged: (bool? value) {
                setState(() {
                  isChecked = value;
                });
              },
            ),
            CheckboxListTile.adaptive(
              tristate: true, // Enable tristate functionality
              title: Text("Press here"),
              value: isChecked, // Use nullable isChecked
              onChanged: (bool? value) {
                setState(() {
                  isChecked = value;
                });
              },
            ),
            Switch.adaptive(
              value: isSwitched,
              onChanged: (value) {
                setState(() {
                  isSwitched = value;
                });
              },
            ),
            SwitchListTile.adaptive(
              value: isSwitched,
              onChanged: (value) {
                setState(() {
                  isSwitched = value;
                });
              },
            ),
            Slider.adaptive(
              max: 100,
              min: 0,
              divisions: 10,
              value: sliderValue,
              onChanged: (value) {
                setState(() {
                  sliderValue = value;
                });
                print(sliderValue);
              },
            ),
            Text(sliderValue.toString()), // Display slider value
            InkWell(
              splashColor: Colors.red,
              onTap: () {
                print('Image tapped');
              },
              child: Container(
                height: 200,
                color: Colors.white12,
              ),
            ),
            
            FilledButton(
              onPressed: () {},
              child: Text("This is the button"),
            ),
            TextButton(
              onPressed: () {},
              child: Text("This is the button"),
            ),
            OutlinedButton(
              onPressed: () {},
              child: Text("This is the button"),
            ),
            CloseButton(
              onPressed: () {
                setState(() {
                  print("Closing");
                });
              },
            ),
            BackButton(),
          ],
        ),
      ),
    ),
    );

  }
}