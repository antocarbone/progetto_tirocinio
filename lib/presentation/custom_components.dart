import 'package:flutter/material.dart';

class RowStatusIndicator extends StatelessWidget {
  final Widget indicator;
  final String info;
  const RowStatusIndicator({super.key, required this.indicator, required this.info});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Flexible(flex:1, child: indicator),
        Flexible(flex: 4, child: Text(info))
      ],
    );
  }
}