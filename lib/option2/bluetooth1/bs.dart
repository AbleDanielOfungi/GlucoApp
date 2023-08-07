import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';

class BluetoothScreen extends StatefulWidget {
  @override
  _BluetoothScreenState createState() => _BluetoothScreenState();
}

class _BluetoothScreenState extends State<BluetoothScreen> {
  FlutterBlue flutterBlue = FlutterBlue.instance;
  List<BluetoothDevice> devices = [];

  @override
  void initState() {
    super.initState();
    _startScan();
  }

  void _startScan() {
    flutterBlue.scanResults.listen((results) {
      setState(() {
        devices = results.map((result) => result.device).toList();
      });
    });
    flutterBlue.startScan();
  }

  void _connectToDevice(BluetoothDevice device) async {
    await device.connect();
    // You can now use the connected `device` to communicate with the CGM.
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Bluetooth Devices')),
      body: ListView.builder(
        itemCount: devices.length,
        itemBuilder: (context, index) {
          final device = devices[index];
          return ListTile(
            title: Text(device.name),
            subtitle: Text(device.id.toString()),
            onTap: () => _connectToDevice(device),
          );
        },
      ),
    );
  }
}
