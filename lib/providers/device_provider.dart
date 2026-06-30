import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class DeviceProvider with ChangeNotifier {
  List<ScanResult> _scanResults = [];
  BluetoothDevice? _connectedDevice;
  bool _isScanning = false;
  bool _isConnected = false;
  String? _deviceName;
  String? _deviceAddress;

  // Health data from watch
  int _heartRate = 0;
  int _steps = 0;
  double _calories = 0;
  int _sleepHours = 0;

  List<ScanResult> get scanResults => _scanResults;
  BluetoothDevice? get connectedDevice => _connectedDevice;
  bool get isScanning => _isScanning;
  bool get isConnected => _isConnected;
  String? get deviceName => _deviceName;
  String? get deviceAddress => _deviceAddress;
  int get heartRate => _heartRate;
  int get steps => _steps;
  double get calories => _calories;
  int get sleepHours => _sleepHours;

  Future<void> startScan() async {
    if (_isScanning) return;

    _isScanning = true;
    _scanResults.clear();
    notifyListeners();

    print('🔵 Starting Bluetooth scan...');

    // Check if Bluetooth is on
    if (await FlutterBluePlus.isSupported == false) {
      print('❌ Bluetooth not supported on this device');
      _isScanning = false;
      notifyListeners();
      return;
    }

    // Listen to scan results
    FlutterBluePlus.scanResults.listen((results) {
      _scanResults = results;
      notifyListeners();
    });

    // Start scanning for 10 seconds
    await FlutterBluePlus.startScan(timeout: const Duration(seconds: 10));

    _isScanning = false;
    notifyListeners();
    print('✅ Scan complete. Found ${_scanResults.length} devices');
  }

  Future<void> stopScan() async {
    await FlutterBluePlus.stopScan();
    _isScanning = false;
    notifyListeners();
  }

  Future<void> connectToDevice(BluetoothDevice device) async {
    try {
      print('🔵 Connecting to ${device.platformName}...');

      await device.connect(timeout: const Duration(seconds: 10));
      _connectedDevice = device;
      _isConnected = true;
      _deviceName = device.platformName.isNotEmpty
          ? device.platformName
          : 'Unknown Device';
      _deviceAddress = device.remoteId.str;

      print('✅ Connected to $_deviceName');

      // Discover services
      List<BluetoothService> services = await device.discoverServices();
      print('🔵 Found ${services.length} services');

      // Start reading health data
      _startHealthDataReading(services);

      notifyListeners();
    } catch (e) {
      print('❌ Connection failed: $e');
      _isConnected = false;
      notifyListeners();
    }
  }

  void _startHealthDataReading(List<BluetoothService> services) {
    // Simulate health data from watch (in real app, read from GATT characteristics)
    // This is a demo - real implementation would read from actual watch services

    print('🔵 Starting health data reading...');

    // Simulate heart rate updates
    Future.doWhile(() async {
      if (!_isConnected) return false;

      await Future.delayed(const Duration(seconds: 3));

      // Simulate data changes
      _heartRate = 65 + (DateTime.now().second % 20);
      _steps = 8000 + (DateTime.now().minute * 10);
      _calories = 350 + (DateTime.now().minute * 2.5);
      _sleepHours = 7;

      notifyListeners();

      return _isConnected;
    });
  }

  Future<void> disconnect() async {
    if (_connectedDevice != null) {
      await _connectedDevice!.disconnect();
      _connectedDevice = null;
      _isConnected = false;
      _deviceName = null;
      _deviceAddress = null;
      _heartRate = 0;
      _steps = 0;
      _calories = 0;
      _sleepHours = 0;
      notifyListeners();
      print('✅ Disconnected from device');
    }
  }

  @override
  void dispose() {
    disconnect();
    super.dispose();
  }
}