import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_circle_color_picker/flutter_circle_color_picker.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LED Control App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Color currentColor = Colors.white; // Default color
  Color lastSelectedColor = Colors.white; // Store the last selected color
  bool isLedOn = false;

  @override
  void initState() {
    super.initState();
    // Fetch the initial state of the LEDs when the app starts
    fetchLedState();
  }

  Future<void> fetchLedState() async {
    try {
      final response = await http.get(Uri.parse('http://192.168.4.1/ledState'));
      if (response.statusCode == 200 && response.body.isNotEmpty) {
        setState(() {
          isLedOn = response.body.toLowerCase() == 'true';
        });
      } else {
        print('Failed to fetch LED state - Response: ${response.body}');
      }
    } catch (error) {
      print('Error fetching LED state: $error');
    }
  }

  Future<void> setColor() async {
    if (isLedOn) {
      final red = currentColor.red.toString();
      final green = currentColor.green.toString();
      final blue = currentColor.blue.toString();

      final response = await http.post(
        Uri.parse('http://192.168.4.1/setColor'),
        body: {'red': red, 'green': green, 'blue': blue},
      );

      if (response.statusCode == 200) {
        // Update the last selected color
        setState(() {
          lastSelectedColor = currentColor;
        });
        print('Color set successfully');
      } else {
        print('Failed to set color');
      }
    } else {
      print('LEDs are turned off. Cannot set color.');
    }
  }

  Future<void> toggleLed() async {
    final response = await http.post(
      Uri.parse('http://192.168.4.1/toggleLed'),
      body: {'isLedOn': isLedOn.toString()},
    );

    if (response.statusCode == 200) {
      setState(() {
        isLedOn = !isLedOn;
      });

      if (isLedOn) {
        // If turning on, use the last selected color
        final red = lastSelectedColor.red.toString();
        final green = lastSelectedColor.green.toString();
        final blue = lastSelectedColor.blue.toString();

        await http.post(
          Uri.parse('http://192.168.4.1/setColor'),
          body: {'red': red, 'green': green, 'blue': blue},
        );
      }

      print('LED state toggled successfully');
    } else {
      print('Failed to toggle LED state');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.indigo,
        title: Row(
          children: [
            Icon(
              Icons.lightbulb,
              color: Colors.white, // Set icon color to white
            ),
            SizedBox(width: 8),
            Text(
              'LED Control App',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                letterSpacing: 1.5,
                color: Colors.white, // Set title font color to white
              ),
            ),
          ],
        ),
      ),
      body: Container(
        color: Colors.grey[200],
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Set LED Color:',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              CircleColorPicker(
                strokeWidth: 15,
                onChanged: changeColor,
              ),
              SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: setColor,
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 20, horizontal: 40),
                  textStyle: TextStyle(fontSize: 20),
                  primary: Colors.indigo,
                  onPrimary: Colors.white,
                ),
                icon: Icon(Icons.color_lens),
                label: Text('Set Color'),
              ),
              SizedBox(height: 80),
              ElevatedButton.icon(
                onPressed: toggleLed,
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 20, horizontal: 40),
                  textStyle: TextStyle(fontSize: 20),
                  primary: isLedOn ? Colors.red : Colors.green,
                  onPrimary: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50),
                  ),
                ),
                icon: Icon(isLedOn ? Icons.power_settings_new : Icons.power_off),
                label: Text(isLedOn ? 'Turn Off' : 'Turn On'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void changeColor(Color color) {
    setState(() {
      currentColor = color;
    });
  }
}
