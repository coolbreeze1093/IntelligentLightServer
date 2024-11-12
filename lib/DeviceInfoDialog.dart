import 'package:flutter/material.dart';
import 'package:ledctrl/GetNetworkInfo.dart';
import 'package:ledctrl/UdpSocketManager.dart';
import 'package:ledctrl/utils.dart';

// ignore: must_be_immutable
class DeviceInfoDialog extends StatefulWidget {
  final NetworkInfoMan networkInfo;
  final UdpSocketManager udpSocketManager;

  const DeviceInfoDialog({
    super.key,
    required this.networkInfo,
    required this.udpSocketManager,
  });

  @override
  _DeviceInfoDialog createState() => _DeviceInfoDialog();
}

class _DeviceInfoDialog extends State<DeviceInfoDialog> {
  Map<String, DeviceInfo> _deviceMap = {};
  String _localIP = '';
  String _localMac = '';
  DeviceInfo? _curUser;
  int? _selectedIndex;

  @override
  void initState() {
    super.initState();
    widget.udpSocketManager.deviceInfoCallback(deviceInfo);
    widget.networkInfo.getNetworkInfo(localAddress);
  }

  void deviceInfo(Map<String, DeviceInfo> dm) {
    logger.d("收到了设备列表");

    setState(() {
      _deviceMap = dm;
    });
  }

  void localAddress(String ip, String mac) {
    widget.udpSocketManager.scanDevicList(ip);
    setState(() {
      _localIP = ip;
      _localMac = mac;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white.withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      title: const Text(
        '设备列表和网络信息',
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
      content: SizedBox(
        width: 300,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child:
                  Text('设备列表:', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            SizedBox(
              height: 150,
              child: ListView.builder(
                itemCount: _deviceMap.length,
                itemBuilder: (context, index) {
                  var entry = _deviceMap.entries.toList()[index];
                  bool isSelected = _selectedIndex == index;
                  return ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _curUser = entry.value;
                        _selectedIndex = index;
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          isSelected ? Colors.blueAccent : Colors.grey[300],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: isSelected ? 6 : 2,
                    ),
                    child: Container(
                      alignment: Alignment.center,
                      padding: const EdgeInsets.all(10.0), // 按钮内边距
                      child: Text(
                        entry.value.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.cyanAccent,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const Divider(thickness: 1.5, color: Colors.grey), // 分隔线
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child:
                  Text('网络信息:', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            Text('IP 地址: $_localIP', style: const TextStyle(fontSize: 14)),
            Text('MAC 地址: $_localMac', style: const TextStyle(fontSize: 14)),
            const SizedBox(height: 20),
            Text('当前设备: ${_curUser?.name ?? "无"}',
                style: const TextStyle(fontSize: 14)),
          ],
        ),
      ),
      actions: <Widget>[
        Padding(
          padding: const EdgeInsets.only(bottom: 10.0), // 底部间距
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                onPressed: () {
                  DeviceInfo info = DeviceInfo();
                  info.address = "empty";
                  if (_selectedIndex == null || _curUser == null) {
                    Navigator.of(context).pop(info);
                  } else {
                    Navigator.of(context).pop(_curUser!);
                  }
                },
                child: const Text("确认",
                    style: TextStyle(color: Colors.cyanAccent)),
              ),
              TextButton(
                onPressed: () {
                  DeviceInfo info = DeviceInfo();
                  info.address = "empty";
                  Navigator.of(context).pop(info);
                },
                child: const Text("取消",
                    style: TextStyle(color: Colors.cyanAccent)),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
