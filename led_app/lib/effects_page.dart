import 'package:flutter/material.dart';

class EffectsPage extends StatefulWidget {
  @override
  _EffectsPageState createState() => _EffectsPageState();
}

class _EffectsPageState extends State<EffectsPage> {
  String selectedEffect = 'Solid';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('LED Effects'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Selected Effect: $selectedEffect',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  selectedEffect = 'Solid';
                });
              },
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 20, horizontal: 40),
                textStyle: TextStyle(fontSize: 20),
                primary: selectedEffect == 'Solid' ? Colors.grey : Colors.indigo,
                onPrimary: Colors.white,
              ),
              child: Text('Solid'),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  selectedEffect = 'Wave';
                });
              },
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 20, horizontal: 40),
                textStyle: TextStyle(fontSize: 20),
                primary: selectedEffect == 'Wave' ? Colors.grey : Colors.indigo,
                onPrimary: Colors.white,
              ),
              child: Text('Wave'),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  selectedEffect = 'Pulse';
                });
              },
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 20, horizontal: 40),
                textStyle: TextStyle(fontSize: 20),
                primary: selectedEffect == 'Pulse' ? Colors.grey : Colors.indigo,
                onPrimary: Colors.white,
              ),
              child: Text('Pulse'),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  selectedEffect = 'Blink';
                });
              },
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 20, horizontal: 40),
                textStyle: TextStyle(fontSize: 20),
                primary: selectedEffect == 'Blink' ? Colors.grey : Colors.indigo,
                onPrimary: Colors.white,
              ),
              child: Text('Blink'),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  selectedEffect = 'Fade';
                });
              },
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 20, horizontal: 40),
                textStyle: TextStyle(fontSize: 20),
                primary: selectedEffect == 'Fade' ? Colors.grey : Colors.indigo,
                onPrimary: Colors.white,
              ),
              child: Text('Fade'),
            ),
          ],
        ),
      ),
    );
  }
}
