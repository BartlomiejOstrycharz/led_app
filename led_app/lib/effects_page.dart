// effects_page.dart
import 'package:flutter/material.dart';
import 'http_service.dart';

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
        title: Text('LED Effects',
                style: TextStyle(color: Colors.white),),
        backgroundColor: Colors.blue, // Set the app bar background color to blue
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
            _buildEffectButton('Solid'),
            SizedBox(height: 16),
            _buildEffectButton('Wave'),
            // Add similar buttons for other effects
            // ...
          ],
        ),
      ),
    );
  }

  Widget _buildEffectButton(String effect) {
    bool isSelected = selectedEffect == effect;

    return ElevatedButton(
      onPressed: () {
        _setEffect(effect);
      },
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.symmetric(vertical: 20, horizontal: 40),
        textStyle: TextStyle(fontSize: 20),
        primary: isSelected ? Colors.blue.withOpacity(0.7) : Colors.blue,
        onPrimary: Colors.white,
      ),
      child: Text(effect),
    );
  }

  void _setEffect(String effect) async {
    try {
      await HttpService.setEffect(effect);
      setState(() {
        selectedEffect = effect;
      });
      print('Effect set successfully: $effect');
    } catch (error) {
      print('Failed to set effect: $error');
    }
  }
}
