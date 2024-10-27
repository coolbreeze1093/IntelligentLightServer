import 'dart:io';
import 'dart:convert';
import 'utils.dart';

class UdpSocketManager {
  late RawDatagramSocket _socket;
  UdpSocketManager();

  Future<void> initializeSocket() async {
    try {
      
       _socket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, revPort);
       _socket.broadcastEnabled = true;
       _socket.listen((RawSocketEvent event) {
         if (event == RawSocketEvent.read) {
           Datagram? datagram = _socket.receive();
           if (datagram!= null) {
             String message = String.fromCharCodes(datagram.data);
             // 处理接收到的消息
           }
         }
       });
     } catch (e) {
       print('初始化 UDP 套接字失败：$e');
     }
  }

  void sendMessage(String message,String address,int sendPort) {
    _socket.send(utf8.encode(message), InternetAddress(address), sendPort);
  }

  void close() {
    _socket.close();
  }
}
