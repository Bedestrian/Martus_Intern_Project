# Robot Control and Demo App

A Android app built in flutter to control and demonstrate robot functionality


## Description

This Android app is designed to control a robot through MQTT and get video streams from a server like mediamtx. The application provides a comprehensive interface for robot operation, including manual control via a physical gamepad, sending predefined or custom commands, and viewing multiple real-time video feeds. It features a configuration screen to manage MQTT broker settings, custom commands, and camera stream URLs, ensuring flexibility for different robot and network setups. The state of the application is managed using the Provider package, which handles services for MQTT connection, command processing, and gamepad input.

## Getting Started

### Dependencies

#### Software

* A Flutter-compatible IDE (e.g., Android Studio, VS Code).
* Flutter SDK installed ('^3.8.1' or compatible)
* An Android device or emulator.
* Docker and Docker Compose.

#### Services
This project uses a `docker-compose.yml` to run the necessary backend services.
* **MQTT Broker**: `emqx/nanomq:latest` is used as the MQTT broker, listening on port 1883.
* **Media Server**: `bluenviron/mediamtx:latest` is used for providing video streams. It exposes ports for RTSP (8554) and RTMP (1935).

#### Flutter Packages
* `mqtt_client: ^10.10.0`
* `flutter_vlc_player: ^7.4.3`
* `gamepads: ^0.1.7`
* `provider: ^6.1.5`
* `path_provider: ^2.1.2`
* `cupertino_icons: ^1.0.8`

### Installing

1.  Clone the repository to your local machine:
    ```bash
    git clone <your-repository-url>
    ```
2.  Navigate to the project directory:
    ```bash
    cd robot_control_app
    ```
3.  Install the required Flutter packages:
    ```bash
    flutter pub get
    ```

### Executing program

1.  **Start Backend Services:**
    Navigate to the project's root directory and run the following command to start the MQTT broker and media server:
    ```bash
    docker-compose up -d
    ```
2.  **Connect Your Device:**
    Connect your Android device (with developer mode and USB debugging enabled) or start an Android emulator.

3.  **Run the Application:**
    Open the project in your IDE and run it, or execute the following command in your terminal:
    ```bash
    flutter run
    ```
4.  **Configure the App:**
    * Once the app is running, you will see the `HomePage`. Tap the **'Open Config'** button.
    * On the `ConfigPage`, set the following:
        * **MQTT Server IP**: The IP address of the machine running Docker. If using an Android emulator, this is typically `10.0.2.2` to connect to services on the host machine.
        * **MQTT Port**: `1883`
        * **Camera URLs**: The stream URLs for your cameras (e.g., `rtsp://<your-docker-host-ip>:8554/<stream-name>`).
    * Save the settings.

5.  **Control the Robot:**
    * Navigate back to the `HomePage`.
    * Select a robot to go to the `CommandPage` where you can view camera feeds and send commands.

## Help

* **"NO GAMEPAD" indicator is Red**: Ensure a compatible gamepad is properly connected to your Android device. The app checks for a connection every two seconds.
* **Video streams show "Stream Offline"**: Double-check the camera URLs in the **Config Page**. The app supports `rtsp://` and `http://` protocols. Ensure your media server is running and accessible from the app's network.
* **Commands are not being sent**: Verify the MQTT broker IP address and port are correct in the settings. Check the `MqttService` for connection status logs in your IDE's console. The app will attempt to reconnect every 10 seconds if the connection is lost.
* **App is stuck in portrait mode**: The application is designed to run in landscape mode only, as enforced in `main.dart`.
