import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:robot_control_app/models/settings_model.dart';
import 'package:robot_control_app/services/config_service.dart';

class MqttService {
  late MqttServerClient client;
  late SettingsModel settings;

  Future<void> init() async {
    settings = await ConfigService().loadSettings();
    client = MqttServerClient(settings.mqttIp, 'robot_controller_client');
    client.port = settings.mqttPort;
    client.keepAlivePeriod = 20;
    client.autoReconnect = true;
    //client.onConnected = () => print('MQTT Connected');
    //client.onDisconnected = () => print('MQTT Disconnected');
  }

  Future<void> connect() async {
    await init();
    final connMessage = MqttConnectMessage()
        .withClientIdentifier('robot_controller')
        .startClean();

    client.connectionMessage = connMessage;

    try {
      await client.connect();
    } catch (e) {
      //print('MQTT connection failed: $e');
      client.disconnect();
      retryConnect();
      return;
    }

    final state = client.connectionStatus?.state;
    if (state == MqttConnectionState.connected) {
      print("MQTT Connected");
    } else {
      print('MQTT Connection unseccessful');
      retryConnect();
    }
  }

  void retryConnect() {
    Future.delayed(const Duration(seconds: 5), () {
      final state = client.connectionStatus?.state;
      if (state != MqttConnectionState.connected) {
        print('Retrying MQTT connection (state: $state)...');
        connect();
      } else {
        print('MQTT is already connected.');
      }
    });
  }

  void publish(String topic, String message) {
    final state = client.connectionStatus?.state;
    if (state == MqttConnectionState.connected) {
      final builder = MqttClientPayloadBuilder();
      builder.addString(message);

      client.publishMessage(topic, MqttQos.atLeastOnce, builder.payload!);

      //print('published to $topic: $message');
    }
  }

  void disconnect() {
    client.disconnect();
  }
}
