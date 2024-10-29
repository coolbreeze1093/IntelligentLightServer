// ignore: file_names
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:ledctrl/GetNetworkInfo.dart';
import 'package:ledctrl/UdpSocketManager.dart';
import 'package:ledctrl/utils.dart';

class DeviceInfoDialog extends StatefulWidget {
  NetworkInfoMan networkInfo;
  UdpSocketManager udpSocketManager;

  DeviceInfoDialog(
      {super.key, required this.networkInfo, required this.udpSocketManager});

  @override
  // ignore: library_private_types_in_public_api
  _DeviceInfoDialog createState() => _DeviceInfoDialog();
}

class _DeviceInfoDialog extends State<DeviceInfoDialog> {
  Map<String, DeviceInfo> _deviceMap = {};
  String _localIP = '';
  String _localMac = '';

  @override
  void initState() {
    super.initState();
    widget.networkInfo.getNetworkInfo(localAddress);
    widget.udpSocketManager.queryDevicInfo();
    widget.udpSocketManager.deviceInfoCallback(deviceInfo);
  }

  void deviceInfo(Map<String, DeviceInfo> dm) {
    print("收到了设备列表");
    setState(() {
      _deviceMap = dm;
    });
  }

  void localAddress(String ip, String mac) {
    setState(() {
      _localIP = ip;
      _localMac = mac;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('设备列表和网络信息'),
      content: SizedBox(
        width: 300,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('设备列表:'),
            // 这里可以根据需要填充设备列表
            ListView.builder(
              shrinkWrap: true,
              itemCount: _deviceMap.length, // 示例设备数量
              itemBuilder: (context, index) {
                var entry = _deviceMap.entries.toList()[index];
                return ListTile(
                  title: Text(entry.value.name),
                  subtitle: Text(entry.value.address),
                );
              },
            ),
            const SizedBox(height: 10),
            const Text('网络信息:'),
            // 示例网络信息
            Text('IP 地址: $_localIP'),
            Text('MAC 地址: $_localMac'),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child:
              Text("确认", style: TextStyle(color: Colors.cyanAccent.shade400)),
        ),
      ],
    );
  }
}
