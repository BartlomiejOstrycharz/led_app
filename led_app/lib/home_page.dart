import 'package:flutter/material.dart';
import 'http_service.dart';
import 'package:flutter_circle_color_picker/flutter_circle_color_picker.dart';
import 'effects_page.dart';

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
    HttpService.fetchLedState().then((bool ledState) {
      setState(() {
        isLedOn = ledState;
      });
    });
  }

  Future<void> setColor() async {
    if (isLedOn) {
      final red = currentColor.red.toString();
      final green = currentColor.green.toString();
      final blue = currentColor.blue.toString();

      try {
        await HttpService.setColor(red, green, blue);
        // Update the last selected color
        setState(() {
          lastSelectedColor = currentColor;
        });
        print('Color set successfully');
      } catch (error) {
        print('Failed to set color: $error');
      }
    } else {
      print('LEDs are turned off. Cannot set color.');
    }
  }

  Future<void> toggleLed() async {
    try {
      await HttpService.toggleLed(isLedOn);
      setState(() {
        isLedOn = !isLedOn;
      });

      if (isLedOn) {
        // If turning on, use the last selected color
        final red = lastSelectedColor.red.toString();
        final green = lastSelectedColor.green.toString();
        final blue = lastSelectedColor.blue.toString();

        await HttpService.setColor(red, green, blue);
      }

      print('LED state toggled successfully');
    } catch (error) {
      print('Failed to toggle LED state: $error');
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
        actions: [
          ElevatedButton(
            onPressed: toggleLed,
            style: ElevatedButton.styleFrom(
              primary: isLedOn ? Colors.red : Colors.green,
              onPrimary: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(50),
              ),
            ),
            child: Row(
              children: [
                Icon(isLedOn ? Icons.power_settings_new : Icons.power_off),
                SizedBox(width: 8),
                Text(isLedOn ? 'Turn Off' : 'Turn On'),
              ],
            ),
          ),
          SizedBox(width: 16),
        ],
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
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => EffectsPage()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 20, horizontal: 40),
                  textStyle: TextStyle(fontSize: 20),
                  primary: Colors.indigo,
                  onPrimary: Colors.white,
                ),
                child: Text('Effects'),
              ),
              SizedBox(height: 80),
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
