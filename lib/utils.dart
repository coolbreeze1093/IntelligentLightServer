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
