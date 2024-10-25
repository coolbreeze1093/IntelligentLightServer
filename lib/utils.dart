import 'dart:ffi';

double mapValue(
    double value, double inMin, double inMax, double outMin, double outMax) {
  return (value - inMin) * (outMax - outMin) / (inMax - inMin) + outMin;
}

enum BrightnessModel { constant, flash, breathe, close }

void setCheckBoxState(
    Map<BrightnessModel, bool> stateMap, BrightnessModel model, bool? state) {
  if (stateMap[model] == true) {
    if (state == false) {
      return;
    }
  }
  switch (model) {
    case BrightnessModel.breathe:
      stateMap[BrightnessModel.breathe] = true;
      stateMap[BrightnessModel.close] = false;
      stateMap[BrightnessModel.constant] = false;
      stateMap[BrightnessModel.flash] = false;
      break;
    case BrightnessModel.close:
      stateMap[BrightnessModel.breathe] = false;
      stateMap[BrightnessModel.close] = true;
      stateMap[BrightnessModel.constant] = false;
      stateMap[BrightnessModel.flash] = false;
      break;
    case BrightnessModel.constant:
      stateMap[BrightnessModel.breathe] = false;
      stateMap[BrightnessModel.close] = false;
      stateMap[BrightnessModel.constant] = true;
      stateMap[BrightnessModel.flash] = false;
      break;
    case BrightnessModel.flash:
      stateMap[BrightnessModel.breathe] = false;
      stateMap[BrightnessModel.close] = false;
      stateMap[BrightnessModel.constant] = false;
      stateMap[BrightnessModel.flash] = true;
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

const String key_type = "type";
const String rev_type_deviceList = "deviceList";
const String rev_type_lightInfo = "lightInfo";
const String send_type_lightInfo = "lightInfo";
const String send_type_deviceList = "deviceList";

const String value_brightness = "brightness";
const String value_model = "model";
const String value_deviceIp = 'deviceIp';
const String value_deviceName = 'deviceName';
