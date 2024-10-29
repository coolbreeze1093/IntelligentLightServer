import 'package:flutter_mdns_plugin/flutter_mdns_plugin.dart';

void registerService() {
  final mdns = FlutterMdnsPlugin(discoveryCallbacks: null);

  // 初始化 mDNS 插件
  mdns.startDiscovery('_yourServiceType._tcp', enableUpdating: true);

  // 注册服务
  final service = MdnsService(
    name: 'My Device',
    type: '_yourServiceType._tcp', // 替换为服务类型
    hostName: 'my-device.local',
    port: 12345, // 替换为设备服务的端口
  );

  mdns.registerService(service);
}

void unregisterService() {
  final mdns = FlutterMdnsPlugin();
  mdns.stopDiscovery();
  mdns.unregisterService();
}
