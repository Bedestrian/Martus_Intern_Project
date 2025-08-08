import 'dart:async';
import 'dart:io'; // Required for Platform class
import 'package:flutter/foundation.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import '../models/robot_model.dart';

enum MqttConnectionState { connected, disconnected, connecting }

class MqttService with ChangeNotifier {
  MqttServerClient? _client;
  MqttConnectionState _connectionState = MqttConnectionState.disconnected;
  Timer? _reconnectTimer;
  final RobotModel robot;

  bool _isDisposed = false;

  MqttConnectionState get connectionState => _connectionState;

  MqttService({required this.robot});

  @override
  void dispose() {
    if (_isDisposed) return;
    _isDisposed = true;
    print('MqttService is being disposed.');

    _reconnectTimer?.cancel();
    _reconnectTimer = null;

    _client?.disconnect();

    super.dispose();
  }

  void _updateConnectionState(MqttConnectionState state) {
    if (_isDisposed || _connectionState == state) return;

    _connectionState = state;
    print('MQTT State updated to: $_connectionState');
    notifyListeners();

    if (_connectionState == MqttConnectionState.connected) {
      _reconnectTimer?.cancel();
      _reconnectTimer = null;
      // print('MQTT Reconnect timer stopped.');
    } else if (_reconnectTimer == null &&
        _connectionState == MqttConnectionState.disconnected) {
      print('MQTT starting reconnect timer...');
      _reconnectTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
        //print('Reconnect timer fired. Attempting to connect...');
        connect();
      });
    }
  }

  Future<void> initialize() async {
    if (_client != null || _isDisposed) return;

    final clientId =
        'robot_controller_client_${robot.name}_${DateTime.now().millisecondsSinceEpoch}';

    _client = MqttServerClient(robot.mqttIp, clientId);
    _client!.port = robot.mqttPort;

    _client!.setProtocolV311();
    _client!.logging(on: true);

    _client!.keepAlivePeriod = 20;
    _client!.autoReconnect = false;

    _client!.onConnected = () =>
        _updateConnectionState(MqttConnectionState.connected);

    _client!.onDisconnected = () =>
        _updateConnectionState(MqttConnectionState.disconnected);

    _client!.onUnsubscribed = (String? topic) =>
        print('Unsubscribed from $topic');

    _client!.onSubscribed = (String topic) => print('Subscribed to $topic');
    _client!.onSubscribeFail = (String topic) =>
        print('Failed to subscribe to $topic');

    final connMessage = MqttConnectMessage()
        .withClientIdentifier(clientId)
        .startClean();
    _client!.connectionMessage = connMessage;
  }

  Future<void> connect() async {
    if (_client == null || _isDisposed) {
      print('MQTT client is not initialized or service is disposed.');
      return;
    }

    if (connectionState == MqttConnectionState.connecting ||
        connectionState == MqttConnectionState.connected) {
      print('Connection attempt ignored, already connecting or connected.');
      return;
    }

    try {
      _updateConnectionState(MqttConnectionState.connecting);
      print(
        'Connecting to MQTT broker at ${robot.mqttIp}:${robot.mqttPort}...',
      );
      await _client!.connect();
    } on NoConnectionException catch (e) {
      _client?.disconnect();
      //print('MQTT client exception - no connection: $e');
      _updateConnectionState(MqttConnectionState.disconnected);
    } on SocketException catch (e) {
      _client?.disconnect();
      //print('Socket exception: $e');
      _updateConnectionState(MqttConnectionState.disconnected);
    } catch (e) {
      _client?.disconnect();
      //print('An unexpected error occurred: $e');
      _updateConnectionState(MqttConnectionState.disconnected);
    }
  }

  void publish(String topic, String message) {
    if (_connectionState == MqttConnectionState.connected && !_isDisposed) {
      final builder = MqttClientPayloadBuilder();
      builder.addString(message);
      _client!.publishMessage(topic, MqttQos.atLeastOnce, builder.payload!);
    } else {
      print('Cannot publish, MQTT not connected or service is disposed.');
    }
  }
}
