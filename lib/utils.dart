import 'package:shared_preferences/shared_preferences.dart';

double mapValue(
    double value, double inMin, double inMax, double outMin, double outMax) {
  return (value - inMin) * (outMax - outMin) / (inMax - inMin) + outMin;
}

enum BrightnessModel { read, colorful, sleep, soft } //0,1,2,3

void setCheckBoxState(
    Map<BrightnessModel, bool> stateMap, BrightnessModel model, bool? state) {
  if (stateMap[model] == true) {
    if (state == false) {
      return;
    }
  }
  switch (model) {
    case BrightnessModel.sleep:
      stateMap[BrightnessModel.sleep] = true;
      stateMap[BrightnessModel.soft] = false;
      stateMap[BrightnessModel.read] = false;
      stateMap[BrightnessModel.colorful] = false;
      break;
    case BrightnessModel.soft:
      stateMap[BrightnessModel.sleep] = false;
      stateMap[BrightnessModel.soft] = true;
      stateMap[BrightnessModel.read] = false;
      stateMap[BrightnessModel.colorful] = false;
      break;
    case BrightnessModel.read:
      stateMap[BrightnessModel.sleep] = false;
      stateMap[BrightnessModel.soft] = false;
      stateMap[BrightnessModel.read] = true;
      stateMap[BrightnessModel.colorful] = false;
      break;
    case BrightnessModel.colorful:
      stateMap[BrightnessModel.sleep] = false;
      stateMap[BrightnessModel.soft] = false;
      stateMap[BrightnessModel.read] = false;
      stateMap[BrightnessModel.colorful] = true;
      break;
    default:
  }
}

class UiState {
  BrightnessModel _model;
  double _brightness;

  UiState(this._brightness, this._model);
  
  BrightnessModel get model => _model; // 获取模式
  double get brightness => _brightness; // 获取亮度

  void setBrightModel(BrightnessModel model) {
    _model = model; // 设置亮度模式
  }

  void setBrightness(double brightness) {
    _brightness = brightness; // 设置亮度
  }
}

// 保存数据
Future<void> saveData(String key, String value) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString(key, value);
}

// 读取数据
Future<String?> getData(String key) async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString(key);
}

class DeviceInfo {
  String name = "";
  String address = "";
}

const String key_type = "type";
const String rev_type_deviceList = "deviceList";
const String rev_type_lightInfo = "lightInfo";
const String send_type_lightInfo = "lightInfo";
const String send_type_querylightInfo = "querylightInfo";
const String send_type_deviceList = "deviceList";

const String value_localip = "localip";
const String value_brightness = "brightness";
const String value_model = "model";
const String value_deviceIp = 'deviceIp';
const String value_deviceName = 'deviceName';

const int revPort = 56698;
const int sendPort = 56696;

const String broadcastIP = '255.255.255.255';

const String config_Key_CurrentUser = "CurrentUser";
