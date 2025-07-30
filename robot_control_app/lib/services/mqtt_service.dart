import 'package:flutter/foundation.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:robot_control_app/models/settings_model.dart';
import 'package:robot_control_app/services/config_service.dart';

enum MqttConnectionState { connected, disconnected, connecting }

class MqttService with ChangeNotifier {
  late MqttServerClient _client;
  late SettingsModel _settings;
  MqttConnectionState _connectionState = MqttConnectionState.disconnected;

  MqttConnectionState get connectionState => _connectionState;

  void _updateConnectionState(MqttConnectionState state) {
    _connectionState = state;
    print('MQTT State: $_connectionState');
    notifyListeners();
  }

  Future<void> _initialize() async {
    _settings = await ConfigService().loadSettings();
    _client = MqttServerClient(_settings.mqttIp, 'robot_controller_client');
    _client.port = _settings.mqttPort;
    _client.keepAlivePeriod = 20;
    _client.autoReconnect = true;

    // Set up listeners BEFORE connecting.
    _client.onConnected = () =>
        _updateConnectionState(MqttConnectionState.connected);
    _client.onDisconnected = () =>
        _updateConnectionState(MqttConnectionState.disconnected);
    _client.onAutoReconnect = () =>
        _updateConnectionState(MqttConnectionState.connecting);
    _client.onAutoReconnected = () =>
        _updateConnectionState(MqttConnectionState.connected);
  }

  Future<void> connect() async {
    await _initialize();

    final connMessage = MqttConnectMessage()
        .withClientIdentifier('robot_controller')
        .startClean();
    _client.connectionMessage = connMessage;

    try {
      _updateConnectionState(MqttConnectionState.connecting);
      await _client.connect();
    } catch (e) {
      print('MQTT connection failed: $e');
      _client.disconnect();
      _updateConnectionState(MqttConnectionState.disconnected);
    }
  }

  void publish(String topic, String message) {
    if (_connectionState == MqttConnectionState.connected) {
      final builder = MqttClientPayloadBuilder();
      builder.addString(message);
      _client.publishMessage(topic, MqttQos.atLeastOnce, builder.payload!);
    } else {
      print('Cannot publish, MQTT not connected.');
    }
  }

  void disconnect() {
    _client.disconnect();
  }
}
