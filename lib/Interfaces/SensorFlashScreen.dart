import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:torch_light/torch_light.dart';

class SensorFlashScreen extends StatefulWidget {
  const SensorFlashScreen({super.key});

  @override
  State<SensorFlashScreen> createState() => _SensorFlashScreen();
}

class _SensorFlashScreen extends State<SensorFlashScreen> {
  StreamSubscription? _accelerometerSubscription;
  bool isFlashOn = false;
  double movimiento = 0;
  @override
  void initState() {
    super.initState();
    _escucharSensor();
  }

  void _escucharSensor() {
    _accelerometerSubscription = accelerometerEvents.listen((
      AccelerometerEvent event,
    ) {
      double x = event.x;
      double y = event.y;
      double z = event.z;
      movimiento = sqrt(x * x + y * y + z * z);
      print("Movimiento ${movimiento}");
      if (movimiento > 20 && !isFlashOn) {
        _encenderFlash();
      } else if (movimiento <= 15 && isFlashOn) {
        _apagarFlash();
      }
      setState(() {});
    });
  }

  Future<void> _encenderFlash() async {
    try {
      await TorchLight.enableTorch();
      isFlashOn = true;
    } catch (e) {
      print("Error al encender el flash: $e");
    }
  }

  Future<void> _apagarFlash() async {
    try {
      await TorchLight.disableTorch();
      isFlashOn = true;
    } catch (e) {
      print("Error al apagar el flash: $e");
    }
  }

  @override
  void dispose() {
    _accelerometerSubscription?.cancel();
    _apagarFlash();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("sensor y flash")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isFlashOn ? Icons.flash_on : Icons.flash_off,
              size: 100,
              color: isFlashOn ? Colors.yellow : Colors.grey,
            ),
            const SizedBox(height: 20),
            Text(
              isFlashOn ? "Flash Encendido" : "Flash Apagado",
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
