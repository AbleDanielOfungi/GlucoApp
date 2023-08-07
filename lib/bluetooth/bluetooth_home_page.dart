import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: BluetoothHomePage(),
    );
  }
}

class BluetoothHomePage extends StatefulWidget {
  @override
  _BluetoothHomePageState createState() => _BluetoothHomePageState();
}

class _BluetoothHomePageState extends State<BluetoothHomePage> {
  FlutterBlue flutterBlue = FlutterBlue.instance;
  BluetoothDevice? selectedDevice;
  bool isScanning = false;
  StreamSubscription? scanSubscription;
  StreamSubscription? deviceConnectionSubscription;

  // Start scanning for nearby Bluetooth devices
  void _startScan() {
    setState(() {
      isScanning = true;
    });
    scanSubscription = flutterBlue.scan(timeout: Duration(seconds: 4)).listen((scanResult) {
      setState(() {
        selectedDevice = scanResult.device;
      });
    }, onDone: () {
      setState(() {
        isScanning = false;
      });
    });
  }

  // Stop scanning for Bluetooth devices
  void _stopScan() {
    scanSubscription?.cancel();
    setState(() {
      isScanning = false;
    });
  }

  // Function to handle the selection of a specific device from the list
  void _selectDevice(BluetoothDevice device) {
    setState(() {
      selectedDevice = device;
    });
  }

  // Function to handle the device connection state changes
  void _handleConnectionState(BluetoothDeviceState state) {
    if (state == BluetoothDeviceState.connected) {
      setState(() {
        // Update the UI when the device is connected
      });
    } else if (state == BluetoothDeviceState.disconnected) {
      setState(() {
        // Update the UI when the device is disconnected
      });
    }
  }

  // Connect to the selected CGM device using its unique identifier
  void _connectToDevice() async {
    if (selectedDevice == null) {
      // Show an alert dialog if no device is selected.
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('No Device Selected'),
          content: Text('Please select a Bluetooth device to connect.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('OK'),
            ),
          ],
        ),
      );
      return;
    }

    try {
      // Get the current Bluetooth state
      BluetoothState state = await flutterBlue.state.first;

      if (state == BluetoothState.on) {
        List<BluetoothDevice> connectedDevices = await flutterBlue.connectedDevices;
        bool isConnected = connectedDevices.any((device) => device.id.id == selectedDevice!.id.id);
        if (!isConnected) {
          // Connect to the selected device
          await selectedDevice!.connect();
          // Listen for changes in the device's connection state
          deviceConnectionSubscription = selectedDevice!.state.listen(_handleConnectionState);
        }

        // Connection successful. You can set up GATT services here.
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Device connected successfully.'),
          ),
        );
      } else {
        // Bluetooth is off, show a snackbar with an error message.
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Bluetooth is off. Please turn on Bluetooth and try again.'),
          ),
        );
      }
    } catch (e) {
      print('Error connecting to device: $e');
      // Handle connection errors and show a snackbar with an error message.
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error connecting to device. Please try again.'),
        ),
      );
    }
  }

  // Get the list of connected devices
  Future<List<BluetoothDevice>> _getConnectedDevices() async {
    List<BluetoothDevice> connectedDevices = await flutterBlue.connectedDevices;
    return connectedDevices;
  }

  @override
  void initState() {
    super.initState();
    _startScan();
  }

  @override
  void dispose() {
    _stopScan();
    deviceConnectionSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bluetooth Integration'),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<ScanResult>>(
              stream: flutterBlue.scanResults,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.active) {
                  final List<ScanResult>? results = snapshot.data;
                  if (results != null && results.isNotEmpty) {
                    return ListView.builder(
                      itemCount: results.length,
                      itemBuilder: (context, index) {
                        BluetoothDevice device = results[index].device;
                        String deviceName = device.name.isNotEmpty
                            ? device.name
                            : 'Unknown Device ';
                        String deviceAddress = device.id.id;
                        return ListTile(
                          title: Text(deviceName),
                          subtitle: Text(deviceAddress),
                          onTap: () => _selectDevice(device), // Set selected device when tapped
                        );
                      },
                    );
                  } else {
                    return Center(
                      child: Text('No devices found.'),
                    );
                  }
                } else {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }
              },
            ),
          ),
          Builder(
            builder: (BuildContext context) {
              if (selectedDevice != null) {
                String deviceName = selectedDevice!.name.isNotEmpty
                    ? selectedDevice!.name
                    : 'Unknown Device ';
                String deviceAddress = selectedDevice!.id.id;
                return Column(
                  children: [
                    SizedBox(height: 20),
                    Text(
                      'Selected Device:',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 10),
                    ListTile(
                      title: Text(deviceName),
                      subtitle: Text(deviceAddress),
                    ),
                    SizedBox(height: 20),
                    Text(
                      'Connected Devices:',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 10),
                    FutureBuilder<List<BluetoothDevice>>(
                      future: _getConnectedDevices(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return CircularProgressIndicator();
                        } else if (snapshot.hasError) {
                          return Text('Error retrieving connected devices.');
                        } else {
                          List<BluetoothDevice> connectedDevices = snapshot.data ?? [];
                          if (connectedDevices.isEmpty) {
                            return Text('No connected devices.');
                          } else {
                            return Column(
                              children: connectedDevices.map((device) {
                                String connectedDeviceName =
                                device.name.isNotEmpty ? device.name : 'Unknown Device (${device.id.id})';
                                return ListTile(
                                  title: Text(connectedDeviceName),
                                  subtitle: Text(device.id.id),
                                );
                              }).toList(),
                            );
                          }
                        }
                      },
                    ),
                  ],
                );
              } else {
                return Container(); // Empty container if no device is selected
              }
            },
          ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: isScanning ? null : _startScan,
            child: Icon(Icons.refresh),
          ),
          SizedBox(height: 12),
          FloatingActionButton(
            onPressed: isScanning ? null : _stopScan,
            child: Icon(Icons.stop),
          ),
          SizedBox(height: 12),
          FloatingActionButton(
            onPressed: selectedDevice == null ? null : _connectToDevice, // Connect to selected device
            child: Icon(Icons.bluetooth),
          ),
          SizedBox(height: 12),
          FloatingActionButton(
            onPressed: () {
              selectedDevice?.disconnect();
            },
            child: Icon(Icons.bluetooth_disabled),
          ),
        ],
      ),
    );
  }
}
