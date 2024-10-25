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
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
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
  Map<BrightnessModel, bool> _checkboxState = {
    BrightnessModel.close: true,
    BrightnessModel.breathe: false,
    BrightnessModel.flash: false,
    BrightnessModel.constant: false,
  };
  BrightnessModel _brightnessModel = BrightnessModel.close;

  void _incrementCounter(double value) {
    setState(() {
      _counter = mapValue(value, 0, 1024, 0, 100).round();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Flexible(
                child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Flexible(
                  child: CheckboxListTile(
                    title: const Text("常量"),
                    value: _checkboxState[BrightnessModel.constant],
                    onChanged: (bool? state) {
                      setState(() {
                        if (state != null) {
                          _brightnessModel = BrightnessModel.constant;
                          setCheckBoxState(
                              _checkboxState, _brightnessModel, state);
                        }
                      });
                    },
                  ),
                ),
                Flexible(
                  child: CheckboxListTile(
                      title: const Text("呼吸"),
                      value: _checkboxState[BrightnessModel.breathe],
                      onChanged: (bool? state) {
                        setState(() {
                          if (state != null) {
                            _brightnessModel = BrightnessModel.breathe;
                            setCheckBoxState(
                                _checkboxState, _brightnessModel, state);
                          }
                        });
                      }),
                ),
                Flexible(
                  child: CheckboxListTile(
                      title: const Text("闪烁"),
                      value: _checkboxState[BrightnessModel.flash],
                      onChanged: (bool? state) {
                        setState(() {
                          if (state != null) {
                            _brightnessModel = BrightnessModel.flash;
                            setCheckBoxState(
                                _checkboxState, _brightnessModel, state);
                          }
                        });
                      }),
                ),
                Flexible(
                  child: CheckboxListTile(
                      title: const Text("关闭"),
                      value: _checkboxState[BrightnessModel.close],
                      onChanged: (bool? state) {
                        setState(() {
                          if (state != null) {
                            _brightnessModel = BrightnessModel.close;
                            setCheckBoxState(
                                _checkboxState, _brightnessModel, state);
                          }
                        });
                      }),
                ),
              ],
            )),
            const SizedBox(height: 20),
            SizedBox(
              height: 280,
              child: RotatedBox(
                  quarterTurns: 3,
                  child: SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      trackHeight: 60, // 设置轨道高度
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
                      min: 0,
                      max: 1024,
                      divisions: 1024,
                      label: _counter.toString(),
                    ),
                  )),
            ),
            const Text('Adjust Brightness'),
          ],
        ),
      ),
    );
  }
}
