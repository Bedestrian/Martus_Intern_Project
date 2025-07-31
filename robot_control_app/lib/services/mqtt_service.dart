import 'dart:async';
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
  Timer? _reconnectTimer;

  MqttConnectionState get connectionState => _connectionState;

  void _updateConnectionState(MqttConnectionState state) {
    if (_connectionState == state) return;

    _connectionState = state;
    print('MQTT State updated to: $_connectionState');
    notifyListeners();

    if (_connectionState == MqttConnectionState.connected) {
      _reconnectTimer?.cancel();
      _reconnectTimer = null;
      print('MQTT Reconnect timer stopped.');
    } else if (_reconnectTimer == null) {
      print('MQTT starting reconnect timer...');
      _reconnectTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
        print('Reconnect timer fired. Attempting to connect...');
        connect();
      });
    }
  }

  Future<void> _initialize() async {
    _settings = await ConfigService().loadSettings();
    _client = MqttServerClient(_settings.mqttIp, 'robot_controller_client');
    _client.port = _settings.mqttPort;
    _client.keepAlivePeriod = 20;
    _client.autoReconnect = false;
    _client.onConnected = () =>
        _updateConnectionState(MqttConnectionState.connected);
    _client.onDisconnected = () =>
        _updateConnectionState(MqttConnectionState.disconnected);
  }

  Future<void> connect() async {
    if (_connectionState == MqttConnectionState.connecting ||
        _connectionState == MqttConnectionState.connected) {
      return;
    }

    try {
      await _initialize();
      _updateConnectionState(MqttConnectionState.connecting);

      final connMessage = MqttConnectMessage()
          .withClientIdentifier('robot_controller')
          .startClean();
      _client.connectionMessage = connMessage;

      await _client.connect();
    } catch (e) {
      print('MQTT connection attempt failed: $e');
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
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
    _client.disconnect();
  }
}
