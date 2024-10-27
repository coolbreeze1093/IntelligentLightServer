// ignore_for_file: unused_field

import 'package:flutter/material.dart';
import 'utils.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'dart:convert';
import 'UdpSocketManager.dart';
import 'dart:async';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.dark(
          primary: Colors.blueGrey.shade800,
          secondary: Colors.cyanAccent,
          surface: Colors.grey.shade800,
          error: Colors.redAccent,
          onPrimary: Colors.white,
          onSecondary: Colors.black,
          onSurface: Colors.white,
          onError: Colors.black,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: '又是美好的一天'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final UiState _uiState = UiState(0.0, BrightnessModel.close);
  String _localIpAddress = '';
  String _localMacAddress = '';

  int _timeCount = 0;

  Map<String, String>? _remoteDeviceList;

  final _udpSocketManager = UdpSocketManager();

  Timer? _debounceTimer;

  // 模式的名称
  final Map<BrightnessModel, String> _showText = {
    BrightnessModel.close: '关闭',
    BrightnessModel.breathe: '呼吸',
    BrightnessModel.constant: '常量',
    BrightnessModel.flash: '闪烁'
  };

  final List<BrightnessModel> _showSeq = [
    BrightnessModel.constant,
    BrightnessModel.breathe,
    BrightnessModel.flash,
    BrightnessModel.close
  ];
  @override
  void initState() {
    super.initState();
    _initializeStatus(); // 在启动时查询状态
    _getNetworkInfo();
    _udpSocketManager.initializeSocket();
  }

  @override
  void dispose() {}

  Future<void> _getNetworkInfo() async {
    final info = NetworkInfo();

    // 获取 IP 地址
    String? wifiIP = await info.getWifiIP();

    // 获取 MAC 地址
    String? wifiBSSID = await info.getWifiBSSID();

    setState(() {
      _localIpAddress = wifiIP ?? '';
      _localMacAddress = wifiBSSID ?? '';
    });
  }

  void _showDeviceInfo(String ipAddress, String macAddress) {
    // 显示设备列表和网络信息
    showDialog(
      context: context,
      builder: (BuildContext context) {
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
                  itemCount: 5, // 示例设备数量
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text('设备 ${index + 1}'),
                    );
                  },
                ),
                const SizedBox(height: 10),
                const Text('网络信息:'),
                // 示例网络信息
                Text('IP 地址: $ipAddress'),
                Text('MAC 地址: $macAddress'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("确认",
                  style: TextStyle(color: Colors.cyanAccent.shade400)),
            ),
          ],
        );
      },
    );
  }

  void _incrementCounter(double value) {
    setState(() {
      _uiState.setBrightness(value);
    });

    // 如果已有计时器在运行，则取消它
    if (_debounceTimer?.isActive ?? false) {
      _timeCount++;
      _debounceTimer?.cancel();
    }

    if (_timeCount >= 5) {
      _timeCount = 0;
      _sendCtrlMessage("255.255.255.255", sendPort);
      return;
    }

    // 设置一个新的定时器，仅在延迟完成后发送消息
    _debounceTimer = Timer(const Duration(milliseconds: 10), () {
      _sendCtrlMessage("255.255.255.255", sendPort);
    });
  }

  void _sendCtrlMessage(String ip, int port) {
    Map<String, dynamic> sendData = {
      key_type: send_type_lightInfo,
      value_brightness: mapValue(_uiState.brightness, 0, 100, 0, 1024).round(),
    };
    _udpSocketManager.sendMessage(jsonEncode(sendData), ip, port);
  }

  // 状态初始化方法
  void _initializeStatus() async {
    // 通过 UDP 查询初始状态
    String initialStatus = await _queryStatus(); // 这里假设你有一个查询状态的方法
    setState(() {
      _uiState.setBrightness(initialStatus == 'ON' ? 1.0 : 0.0);
    });
  }

  // 查询状态的方法（示例）
  Future<String> _queryStatus() async {
    // 这里的代码实现根据需要发送 UDP 消息并获取设备状态
    // 这里返回假设的状态，实际应该根据你的设备返回
    return 'ON'; // 你可以根据实际需求调整
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 35, 52, 52),
        title: Text(widget.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.build), // 使用扳手图标
            onPressed: () {
              _showDeviceInfo(_localIpAddress, _localMacAddress);
            }, // 点击后调用的方法
            tooltip: '设置', // 鼠标悬停时显示的提示
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Column(
              children: [
                IconButton(
                  icon:const Icon(Icons.wb_sunny), // 表示亮度增强
                  color: const Color.fromARGB(255, 162, 153, 77),
                  iconSize: 30, onPressed: () { _incrementCounter(100); },
                ),
                SizedBox(
                  height: 280,
                  child: RotatedBox(
                    quarterTurns: 3,
                    child: SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        trackHeight: 65, // 设置轨道高度
                        trackShape: const RoundedRectSliderTrackShape(),
                        activeTrackColor: Colors.cyanAccent.shade400,
                        inactiveTrackColor: Colors.blueGrey.shade700,
                        thumbShape: const RoundSliderThumbShape(
                            enabledThumbRadius: 25), // 设置滑块大小
                        overlayShape: const RoundSliderOverlayShape(
                            overlayRadius: 30), // 设置滑块外圈大小
                      ),
                      child: Slider(
                        value: _uiState.brightness,
                        onChanged: (double value) {
                          _incrementCounter(value);
                        },
                        onChangeEnd: (double value) {},
                        min: 0,
                        max: 100,
                        divisions: 100,
                        label: _uiState.brightness.round().toString(),
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.nightlight_round), // 表示亮度减弱
                  color: Colors.blueGrey,
                  iconSize: 30, 
                  onPressed: () { _incrementCounter(0); },
                ),
              ],
            ),
            const SizedBox(height: 100),
            ClipRRect(
              borderRadius: BorderRadius.circular(25), // 设置整体圆角
              child: Container(
                width: 320, // 设置宽度，确保内容不超出
                height: 50, // 设置高度
                color: Colors.transparent,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(_showSeq.length, (index) {
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _uiState.setBrightModel(_showSeq[index]);
                        });
                      },
                      child: Container(
                        width: 80, // 设置宽度
                        height: 50, // 设置高度
                        alignment: Alignment.center, // 使文字居中
                        color: _uiState.model == _showSeq[index]
                            ? Colors.cyanAccent.shade700
                            : Colors.blueGrey.shade600,
                        child: Text(
                          _showText[_showSeq[index]]!,
                          style: const TextStyle(
                              color: Colors.white, fontSize: 18),
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
