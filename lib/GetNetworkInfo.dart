import 'package:network_info_plus/network_info_plus.dart';

class NetworkInfoMan {
  String _localIpAddress = "";
  String _localMacAddress = "";

  String get localIpAddress => _localIpAddress;
  String get localMacAddress => _localMacAddress;

  final info = NetworkInfo();

  void getNetworkInfo(Function func) async {
    // 获取 IP 地址
    String? wifiIP = await info.getWifiIP();

    // 获取 MAC 地址
    String? wifiBSSID = await info.getWifiBSSID();

    _localIpAddress = wifiIP ?? '';
    _localMacAddress = wifiBSSID ?? '';

    func(_localIpAddress, _localMacAddress);
  }
}
