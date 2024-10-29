// ignore_for_file: unused_field

import 'package:flutter/material.dart';
import 'utils.dart';
import 'dart:convert';
import 'UdpSocketManager.dart';
import 'dart:async';
import 'DeviceInfoDialog.dart';
import 'GetNetworkInfo.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '灯控',
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
  UiState _uiState = UiState(0.0, BrightnessModel.soft);

  NetworkInfoMan getNetworkInfo = NetworkInfoMan();

  int _timeCount = 0;

  Map<String, String>? _remoteDeviceList;

  UdpSocketManager udpSocketManager = UdpSocketManager();

  Timer? _debounceTimer;

  late DeviceInfoDialog deviceInfoDialog;

  late String? _curUser;

  // 模式的名称
  final Map<BrightnessModel, String> _showText = {
    BrightnessModel.soft: '柔光',
    BrightnessModel.sleep: '睡眠',
    BrightnessModel.read: '阅读',
    BrightnessModel.colorful: '炫彩'
  };

  final List<BrightnessModel> _showSeq = [
    BrightnessModel.read,
    BrightnessModel.sleep,
    BrightnessModel.colorful,
    BrightnessModel.soft
  ];
  @override
  void initState() {
    super.initState();
    _uiState.setBrightness(0);
    udpSocketManager.initializeSocket();
    udpSocketManager.brightnessCallback(setUiState);
    getCurrentUser();
    deviceInfoDialog = DeviceInfoDialog(
        networkInfo: getNetworkInfo, udpSocketManager: udpSocketManager);
  }

  void getCurrentUser() async {
    String? ip = await getData(config_Key_CurrentUser);
    if (ip != null) {
      _curUser = ip;
      getNetworkInfo.getNetworkInfo((String ip, String mac) {
        udpSocketManager.queryBrightness(_curUser!, ip);
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
    udpSocketManager.close();
  }

  void setUiState(UiState us) {
    setState(() {
      _uiState = us;
    });
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
      _sendCtrlMessage(_curUser!, sendPort);
      return;
    }

    // 设置一个新的定时器，仅在延迟完成后发送消息
    _debounceTimer = Timer(const Duration(milliseconds: 10), () {
      _sendCtrlMessage(_curUser!, sendPort);
    });
  }

  void _sendCtrlMessage(String ip, int port) {
    Map<String, dynamic> sendData = {
      key_type: send_type_lightInfo,
      value_brightness: mapValue(_uiState.brightness, 0, 100, 0, 1024).round(),
    };
    udpSocketManager.sendMessage(jsonEncode(sendData), ip, port);
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
            onPressed: () async {
              String? selectUser = await showDialog<String?>(
                context: context,
                builder: (BuildContext context) {
                  return deviceInfoDialog;
                },
              );
              if (selectUser != null || selectUser != "empty") {
                _curUser = selectUser;
                saveData(config_Key_CurrentUser, selectUser!);
              }
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
                  icon: const Icon(Icons.wb_sunny), // 表示亮度增强
                  color: const Color.fromARGB(255, 162, 153, 77),
                  iconSize: 30,
                  onPressed: () {
                    _incrementCounter(100);
                  },
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
                  onPressed: () {
                    _incrementCounter(0);
                  },
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
                        switch (_uiState.model) {
                          case BrightnessModel.read:
                            _incrementCounter(3);
                            break;
                          case BrightnessModel.colorful:
                            _incrementCounter(80);
                            break;
                          case BrightnessModel.sleep:
                            _incrementCounter(0);
                            break;
                          case BrightnessModel.soft:
                            _incrementCounter(30);
                            break;
                        }
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
