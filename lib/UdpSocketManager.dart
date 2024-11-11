import 'dart:io';
import 'dart:convert';
import 'utils.dart';

class UdpSocketManager {
  late RawDatagramSocket socket;
  final Map<String, DeviceInfo> _deviceList = {};
  late Function? _brightnessCallback;
  late Function? _deviceInfoCallback;
  UdpSocketManager();

  void initializeSocket() async {
    try {
      socket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, revPort);
      logger.d('初始化 UDP 套接字成功');
      socket.broadcastEnabled = true;
      socket.multicastHops = 10;
      lisent();
    } catch (e) {
      logger.e('初始化 UDP 套接字失败：$e');
    }
  }

  void lisent() async {
    socket.listen(
      (RawSocketEvent event) {
        logger.d("save ${event.toString()}");

        if (event == RawSocketEvent.read) {
          _handleRevMsg();
        } else if (event == RawSocketEvent.write) {
          logger.d("UDP 套接字写入事件");
        }
      },
      onError: (error) {
        logger.e("udp 监听错误: $error");
      },
      onDone: () {
        logger.d("udp 监听完成");
      },
    );
  }

  void _handleRevMsg() {
    Datagram? datagram = socket.receive();
    if (datagram != null) {
      Map<String, dynamic> msgJson = jsonDecode(utf8.decode(datagram.data));
      if (msgJson.isNotEmpty) {
        if (msgJson.containsKey(key_type)) {
          if (msgJson[key_type] == rev_type_deviceList) {
            var df = DeviceInfo();
            df.address = msgJson[value_deviceIp];
            df.name = msgJson[value_deviceName];
            df.deviceList = msgJson[value_lightInfo];
            _deviceList[msgJson[value_deviceIp]] = df;
            _deviceInfoCallback!(_deviceList);
          } else if (msgJson[key_type] == rev_type_lightInfo) {
            Map<String, int> brightness = msgJson[value_lightInfo];

            _brightnessCallback!(brightness);
          }
        }
      }
      // 处理接收到的消息
    }
  }

  void sendMessage(String message, String address, int sendPort) {
    try {
      var bytes = utf8.encode(message);
      int sentBytes = socket.send(bytes, InternetAddress(address), sendPort);
      if (sentBytes == bytes.length) {
        logger.d("消息成功发送到网络层 $address");
      } else {
        logger.d("消息未能成功发送到网络层");
      }
    } catch (e) {
      logger.e("发送消息失败: $e");
    }
  }

  void close() {
    logger.d("关闭 udp 监听");

    socket.close();
  }

  void brightnessCallback(Function func) {
    _brightnessCallback = func;
  }

  void deviceInfoCallback(Function func) {
    _deviceInfoCallback = func;
  }

  void queryBrightness(String remoteip, String localip) {
    Map<String, String> message = {
      key_type: send_type_querylightInfo,
      value_localip: localip
    };

    sendMessage(jsonEncode(message), remoteip, sendPort);
  }

  void queryDevicInfo(String localip) {
    logger.d("queryDevicInfo");

    Map<String, String> message = {
      key_type: send_type_deviceList,
      value_localip: localip
    };

    sendMessage(jsonEncode(message), broadcastIP, sendPort);
  }
}
