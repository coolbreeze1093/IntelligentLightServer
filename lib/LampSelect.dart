import 'package:flutter/material.dart';

class LampSelect extends StatelessWidget {
  final List<String> lampList;
  final void Function(int index) clicked;
  final String curLampName;

  LampSelect(this.lampList, this.curLampName, this.clicked, {super.key});
  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(19), // 设置整体圆角
      child: Container(
        width: 45, // 设置宽度，确保内容不超出
        height: lampList.length * 45,
        color: Colors.transparent,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(lampList.length, (index) {
            return GestureDetector(
              onTap: () {
                clicked(index);
              },
              child: Container(
                width: 45, // 设置宽度
                height: 45, // 设置高度
                alignment: Alignment.center, // 使文字居中
                color: curLampName == lampList[index]
                    ? Colors.cyanAccent.shade700
                    : Colors.blueGrey.shade600,
                child: Text(
                  lampList[index],
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
