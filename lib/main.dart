// ignore_for_file: unused_field

import 'package:flutter/material.dart';
import 'utils.dart';
import 'UdpSocketManager.dart';
import 'dart:async';
import 'DeviceInfoDialog.dart';
import 'GetNetworkInfo.dart';
import 'BrightnessMode.dart';

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
  //UiState _uiState = UiState(0.0, BrightnessModel.soft);

  NetworkInfoMan getNetworkInfo = NetworkInfoMan();

  int _timeCount = 0;

  Map<String, String>? _remoteDeviceList;

  UdpSocketManager udpSocketManager = UdpSocketManager();

  Timer? _debounceTimer;

  late DeviceInfoDialog deviceInfoDialog;

  DeviceInfo _curUser = DeviceInfo();

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
    _curUser.address = "127.0.0.1";
    _curUser.name = "empty";
    _curUser.deviceList = [];

    udpSocketManager.initializeSocket();
    udpSocketManager.brightnessCallback(setUiState);
    getCurrentUser();
    deviceInfoDialog = DeviceInfoDialog(
        networkInfo: getNetworkInfo, udpSocketManager: udpSocketManager);
  }

  bool _curUserIsValid() {
    if (_curUser.lampInfo.isEmpty) {
      return false;
    } else if (!_curUser.lampInfo.keys.contains(_curUser.selectedLamp)) {
      return false;
    } else {
      return true;
    }
  }

  void getCurrentUser() async {
    String? ip = await getData(config_Key_CurrentUser);
    if (ip != null) {
      _curUser.address = ip;
    }
    List<dynamic>? deviceList = await getListData(config_Key_CurrentLightInfo);
    if (deviceList != null) {
      _curUser.deviceList = List<String>.from(deviceList);
    }
    if (_curUser.deviceList.isNotEmpty) {
      for (String value in _curUser.deviceList) {
        _curUser.lampInfo[value] = UiState(0, BrightnessModel.none);
      }
      _curUser.selectedLamp = _curUser.deviceList.first;
    }

    getNetworkInfo.getNetworkInfo((String ip, String mac) {
      udpSocketManager.queryLampBrightness(_curUser.address, ip);
    });
  }

  @override
  void dispose() {
    super.dispose();
    _debounceTimer?.cancel();
    udpSocketManager.close();
  }

  void setUiState(Map<String, int> us) {
    setState(() {
      us.forEach((String key, int value) {
        _curUser.lampInfo[key]
            ?.setBrightness(mapValue(value.ceilToDouble(), 0, 1024, 0, 100));
      });
    });
  }

  void _incrementCounter(double value) {
    setState(() {
      if (_curUserIsValid()) {
        _curUser.lampInfo[_curUser.selectedLamp]
            ?.setBrightModel(BrightnessModel.none);
        _curUser.lampInfo[_curUser.selectedLamp]?.setBrightness(value);
      }
    });

    // 如果已有计时器在运行，则取消它
    if (_debounceTimer?.isActive ?? false) {
      _timeCount++;
      _debounceTimer?.cancel();
    }

    if (_timeCount >= 10) {
      _timeCount = 0;
      udpSocketManager.setLampBrightness(
          _curUser.address, _curUser.getBrightnessMap());
      return;
    }

    // 设置一个新的定时器，仅在延迟完成后发送消息
    _debounceTimer = Timer(const Duration(milliseconds: 50), () {
      udpSocketManager.setLampBrightness(
          _curUser.address, _curUser.getBrightnessMap());
    });
  }

  void _modelOnTap(int index) {
    setState(() {
      if (_curUser.lampInfo.isNotEmpty) {
        _curUser.lampInfo[_curUser.selectedLamp]
            ?.setBrightModel(_showSeq[index]);
      }
    });
    if (_curUser.lampInfo.isNotEmpty) {
      switch (_curUser.lampInfo[_curUser.selectedLamp]?.model) {
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
        case null:
        // TODO: Handle this case.
        case BrightnessModel.none:
        // TODO: Handle this case.
      }
    }
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
              DeviceInfo? selectUser = await showDialog<DeviceInfo?>(
                context: context,
                builder: (BuildContext context) {
                  return deviceInfoDialog;
                },
              );
              if (selectUser != null && selectUser.address != "empty") {
                setState(() {
                  _curUser = selectUser;
                  for (var element in _curUser.deviceList) {
                    _curUser.lampInfo[element] =
                        UiState(0, BrightnessModel.none);
                  }
                  _curUser.selectedLamp = _curUser.deviceList.first;
                });
                saveData(config_Key_CurrentUser, _curUser.address);
                saveListData(config_Key_CurrentLightInfo, _curUser.deviceList);
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
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(width: 60),
                Expanded(
                    child: SizedBox(
                  child: Column(
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
                        height: MediaQuery.of(context).size.height * 0.4,
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
                              value: _curUserIsValid()
                                  ? _curUser.lampInfo[_curUser.selectedLamp]!
                                      .brightness
                                  : 0,
                              onChanged: (double value) {
                                _incrementCounter(value);
                              },
                              onChangeEnd: (double value) {},
                              min: 0,
                              max: 100,
                              divisions: 100,
                              label: _curUserIsValid()
                                  ? _curUser.lampInfo[_curUser.selectedLamp]!
                                      .brightness
                                      .round()
                                      .toString()
                                  : "0",
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
                )),
                SizedBox(
                  width: 50,
                  height: MediaQuery.of(context).size.height * 0.4,
                  child: RotatedBox(
                    quarterTurns: 3,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(25), // 设置整体圆角
                      child: Container(
                        width: 50, // 设置宽度，确保内容不超出
                        color: Colors.transparent,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(_curUser.deviceList.length,
                              (index) {
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  _curUser.selectedLamp =
                                      _curUser.deviceList[index];
                                });
                              },
                              child: RotatedBox(
                                quarterTurns: 1,
                                child: Container(
                                  width: 40, // 设置宽度
                                  height: 50, // 设置高度
                                  alignment: Alignment.center, // 使文字居中
                                  color: _curUser.selectedLamp ==
                                          _curUser.deviceList[index]
                                      ? Colors.cyanAccent.shade700
                                      : Colors.blueGrey.shade600,
                                  child: Text(
                                    _curUser.deviceList[index],
                                    style: const TextStyle(
                                        color: Colors.white, fontSize: 18),
                                  ),
                                ),
                              ),
                            );
                          }),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 100),
            BrightnessMode(
                _showText,
                _showSeq,
                _modelOnTap,
                _curUserIsValid()
                    ? _curUser.lampInfo[_curUser.selectedLamp]!.model
                    : BrightnessModel.none),
          ],
        ),
      ),
    );
  }
}
