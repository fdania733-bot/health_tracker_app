import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart' as fbp;

// Renamed to AppBluetoothService to avoid collision with flutter_blue_plus's BluetoothService
class AppBluetoothService {
  final StreamController<List<fbp.BluetoothDevice>> _scanResultsController =
  StreamController<List<fbp.BluetoothDevice>>.broadcast();
  final StreamController<bool> _isScanningController =
  StreamController<bool>.broadcast();
  final StreamController<fbp.BluetoothDevice?> _connectedDeviceController =
  StreamController<fbp.BluetoothDevice?>.broadcast();

  Stream<List<fbp.BluetoothDevice>> get scanResults => _scanResultsController.stream;
  Stream<bool> get isScanning => _isScanningController.stream;
  Stream<fbp.BluetoothDevice?> get connectedDevice => _connectedDeviceController.stream;

  List<fbp.BluetoothDevice> _discoveredDevices = [];
  fbp.BluetoothDevice? _connectedDevice;
  bool _isScanning = false;

  fbp.BluetoothDevice? get connectedDeviceSync => _connectedDevice;
  bool get isScanningSync => _isScanning;

  Future<bool> checkBluetoothAvailability() async {
    if (await fbp.FlutterBluePlus.isSupported == false) {
      return false;
    }
    return true;
  }

  Future<bool> isBluetoothOn() async {
    return await fbp.FlutterBluePlus.adapterState.first == fbp.BluetoothAdapterState.on;
  }

  Future<void> requestBluetoothOn() async {
    await fbp.FlutterBluePlus.turnOn();
  }

  Future<void> startScan({Duration timeout = const Duration(seconds: 10)}) async {
    if (_isScanning) return;

    _isScanning = true;
    _isScanningController.add(true);
    _discoveredDevices.clear();

    fbp.FlutterBluePlus.scanResults.listen((results) {
      _discoveredDevices = results
          .where((r) => r.device.platformName.isNotEmpty)
          .map((r) => r.device)
          .toList();
      _scanResultsController.add(_discoveredDevices);
    });

    await fbp.FlutterBluePlus.startScan(timeout: timeout);

    fbp.FlutterBluePlus.isScanning.listen((scanning) {
      if (!scanning) {
        _isScanning = false;
        _isScanningController.add(false);
      }
    });
  }

  Future<void> stopScan() async {
    await fbp.FlutterBluePlus.stopScan();
    _isScanning = false;
    _isScanningController.add(false);
  }

  Future<bool> connect(fbp.BluetoothDevice device) async {
    try {
      await device.connect(timeout: const Duration(seconds: 10));
      _connectedDevice = device;
      _connectedDeviceController.add(device);

      // Listen for disconnection
      device.connectionState.listen((state) {
        if (state == fbp.BluetoothConnectionState.disconnected) {
          _connectedDevice = null;
          _connectedDeviceController.add(null);
        }
      });

      return true;
    } catch (e) {
      debugPrint('Connection error: $e');
      return false;
    }
  }

  Future<void> disconnect() async {
    if (_connectedDevice != null) {
      await _connectedDevice!.disconnect();
      _connectedDevice = null;
      _connectedDeviceController.add(null);
    }
  }

  Future<int?> getBatteryLevel(fbp.BluetoothDevice device) async {
    try {
      // Use the flutter_blue_plus BluetoothService type explicitly
      List<fbp.BluetoothService> services = await device.discoverServices();
      for (var service in services) {
        for (var characteristic in service.characteristics) {
          // Battery service UUID: 0000180f-0000-1000-8000-00805f9b34fb
          if (characteristic.uuid.toString().toLowerCase().contains('180f')) {
            List<int> value = await characteristic.read();
            if (value.isNotEmpty) {
              return value[0];
            }
          }
        }
      }
    } catch (e) {
      debugPrint('Battery read error: $e');
    }
    return null;
  }

  Future<String?> getDeviceName(fbp.BluetoothDevice device) async {
    return device.platformName.isNotEmpty ? device.platformName : null;
  }

  Future<DateTime?> getLastSyncTime() async {
    return DateTime.now();
  }

  void dispose() {
    _scanResultsController.close();
    _isScanningController.close();
    _connectedDeviceController.close();
  }
}