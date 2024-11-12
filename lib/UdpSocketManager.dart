import 'dart:io';
import 'dart:convert';
import 'utils.dart';

typedef DeviceInfoCallbackFunc = void Function(Map<String, DeviceInfo>);
typedef BrightnessCallbackFunc = void Function(Map<String, int>);

class UdpSocketManager {
  late RawDatagramSocket socket;
  Map<String, DeviceInfo> _deviceList = {};
  BrightnessCallbackFunc? _brightnessCallback;
  DeviceInfoCallbackFunc? _deviceInfoCallback;
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
      logger.d("收到消息：$msgJson");
      if (msgJson.isNotEmpty) {
        if (msgJson.containsKey(key_type)) {
          if (msgJson[key_type] == type_scanDeviceList) {
            var df = DeviceInfo();
            df.address = msgJson[value_deviceIp];
            df.name = msgJson[value_deviceName];
            df.deviceList = List<String>.from(msgJson[value_ledLightList]);
            _deviceList[msgJson[value_deviceIp]] = df;
            if (_deviceInfoCallback != null) {
              logger.d("_deviceInfoCallback is null");
              _deviceInfoCallback!(_deviceList);
            } else {
              logger.d("_deviceInfoCallback is null");
            }
          } else if (msgJson[key_type] == type_queryLampBrightness) {
            Map<String, dynamic> brightness = msgJson[value_ledLightList];
            if (_brightnessCallback != null) {
              _brightnessCallback!(Map<String, int>.from(brightness));
            } else {
              logger.d("_brightnessCallback is null");
            }
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
      logger.d("发送消息：$message");
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

  void brightnessCallback(BrightnessCallbackFunc func) {
    _brightnessCallback = func;
  }

  void deviceInfoCallback(DeviceInfoCallbackFunc func) {
    _deviceInfoCallback = func;
  }

  void queryLampBrightness(String remoteip, String localip) {
    Map<String, String> message = {
      key_type: type_queryLampBrightness,
      value_localip: localip
    };

    sendMessage(jsonEncode(message), remoteip, sendPort);
  }

  void scanDevicList(String localip) {
    Map<String, String> message = {
      key_type: type_scanDeviceList,
      value_localip: localip
    };

    sendMessage(jsonEncode(message), broadcastIP, sendPort);
  }

  void setLampBrightness(String localip, Map<String, int> brightnessMap) {
    Map<String, dynamic> sendData = {
      key_type: type_setLampBrightness,
      value_brightness: brightnessMap,
    };
    sendMessage(jsonEncode(sendData), localip, sendPort);
  }
}
