import 'dart:io';
import 'dart:convert';
import 'utils.dart';

class UdpSocketManager {
  late RawDatagramSocket socket;
  Map<String, DeviceInfo> _deviceList = {};
  late Function _brightnessCallback;
  late Function _deviceInfoCallback;
  UdpSocketManager();

  void initializeSocket() async {
    try {
      socket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, revPort);
      print('初始化 UDP 套接字成功');
      socket.broadcastEnabled = true;
      socket.multicastHops = 10;
    } catch (e) {
      print('初始化 UDP 套接字失败：$e');
    }

    lisent();
  }

  void lisent() async {
    socket.listen(
      (RawSocketEvent event) {
        print("save ${event.toString()}");
        if (event == RawSocketEvent.read) {
          Datagram? datagram = socket.receive();
          if (datagram != null) {
            Map<String, dynamic> msgJson =
                jsonDecode(utf8.decode(datagram.data));
            if (msgJson.isNotEmpty) {
              if (msgJson.containsKey(key_type)) {
                if (msgJson[key_type] == rev_type_deviceList) {
                  var _df = DeviceInfo();
                  _df.address = msgJson[value_deviceIp];
                  _df.name = msgJson[value_deviceName];
                  _deviceList[msgJson[value_deviceIp]] = _df;
                  _deviceInfoCallback(_deviceList);
                } else if (msgJson[key_type] == rev_type_lightInfo) {
                  UiState uistate =
                      UiState(msgJson[value_brightness], msgJson[value_model]);
                  _brightnessCallback(uistate);
                }
              }
            }
            // 处理接收到的消息
          }
        } else if (event == RawSocketEvent.write) {
          print("UDP 套接字写入事件");
        }
      },
      onError: (error) {
        print("udp 监听错误: $error");
      },
      onDone: () {
        print("udp 监听完成");
      },
    );
  }

  void sendMessage(String message, String address, int sendPort) {
    socket.send(utf8.encode(message), InternetAddress(address), sendPort);
  }

  void close() {
    print("关闭 udp 监听");
    socket.close();
  }

  void brightnessCallback(Function func) {
    _brightnessCallback = func;
  }

  void deviceInfoCallback(Function func) {
    _deviceInfoCallback = func;
  }

  void queryBrightness(String ip) {
    Map<String, String> message = {key_type: send_type_lightInfo};

    sendMessage(jsonEncode(message), ip, sendPort);
  }

  void queryDevicInfo() {
    Map<String, String> message = {key_type: send_type_deviceList};

    sendMessage(jsonEncode(message), broadcastIP, sendPort);
  }
}
