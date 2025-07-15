import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

class MqttService {
  final MqttServerClient client;

  MqttService(String serverIp, {int port = 1883})
    : client = MqttServerClient(serverIp, 'robot_controller_client') {
    client.port = port;
    client.keepAlivePeriod = 20;
    client.autoReconnect = true;
    client.onConnected = () => print('MQTT Connected');
    client.onDisconnected = () => print('MQTT Disconnected');
  }

  Future<void> connect() async {
    final connMessage = MqttConnectMessage()
        .withClientIdentifier('robot_controller')
        .startClean();

    client.connectionMessage = connMessage;

    try {
      await client.connect();
    } catch (e) {
      print('MQTT connection failed: $e');
      client.disconnect();
    }
  }

  void publish(String topic, String message) {
    final builder = MqttClientPayloadBuilder();
    builder.addString(message);

    client.publishMessage(topic, MqttQos.atLeastOnce, builder.payload!);

    print('published to $topic: $message');
  }

  void disconnect() {
    client.disconnect();
  }
}
