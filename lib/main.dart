import 'package:flutter/material.dart';
import 'utils.dart';

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
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
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
  int _counter = 0;
  double _brightness = 0.5;

  BrightnessModel _brightnessModel = BrightnessModel.close;

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

  void _incrementCounter(double value) {
    setState(() {
      _counter = mapValue(value, 0, 1024, 0, 100).round();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Column(
              children: [
                const Icon(
                  Icons.wb_sunny, // 表示亮度增强
                  color: Colors.yellow,
                  size: 30,
                ),
                SizedBox(
                  height: 280,
                  child: RotatedBox(
                    quarterTurns: 3,
                    child: SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        trackHeight: 60, // 设置轨道高度
                        trackShape: const RoundedRectSliderTrackShape(),
                        activeTrackColor: Colors.cyanAccent.shade400,
                        inactiveTrackColor: Colors.blueGrey.shade700,
                        thumbShape: const RoundSliderThumbShape(
                            enabledThumbRadius: 25), // 设置滑块大小
                        overlayShape: const RoundSliderOverlayShape(
                            overlayRadius: 30), // 设置滑块外圈大小
                      ),
                      child: Slider(
                        value: _brightness,
                        onChanged: (double value) {
                          _incrementCounter(value);
                          setState(() {
                            _brightness = value;
                          });
                        },
                        onChangeEnd: (double value) {},
                        min: 0,
                        max: 1024,
                        divisions: 1024,
                        label: _counter.toString(),
                      ),
                    ),
                  ),
                ),
                const Icon(
                  Icons.nightlight_round, // 表示亮度减弱
                  color: Colors.blueGrey,
                  size: 30,
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
                          _brightnessModel = _showSeq[index];
                        });
                      },
                      child: Container(
                        width: 80, // 设置宽度
                        height: 50, // 设置高度
                        alignment: Alignment.center, // 使文字居中
                        color: _brightnessModel == _showSeq[index]
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
