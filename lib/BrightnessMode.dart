import 'package:flutter/material.dart';
import 'utils.dart';

class BrightnessMode extends StatelessWidget {
// 模式的名称

  const BrightnessMode(this.showText, this.showSeq, this.clicked, this.mode,
      {super.key});

  Color _getModelColor(int index) {
    if (mode == BrightnessModel.none) {
      return Colors.blueGrey.shade600;
    } else {
      return mode == showSeq[index]
          ? Colors.cyanAccent.shade700
          : Colors.blueGrey.shade600;
    }
  }

  final void Function(int index) clicked;

  final Map<BrightnessModel, String> showText;

  final List<BrightnessModel> showSeq;

  final BrightnessModel mode;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(25), // 设置整体圆角
      child: Container(
        width: showSeq.length * 80, // 设置宽度，确保内容不超出
        height: 50, // 设置高度
        color: Colors.transparent,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(showSeq.length, (index) {
            return GestureDetector(
              onTap: () {
                clicked(index);
              },
              child: Container(
                width: 80, // 设置宽度
                height: 50, // 设置高度
                alignment: Alignment.center, // 使文字居中
                color: _getModelColor(index),
                child: Text(
                  showText[showSeq[index]]!,
                  style: const TextStyle(color: Colors.white, fontSize: 18),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
