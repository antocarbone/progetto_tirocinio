import 'package:flutter/material.dart';

class RowStatusIndicator extends StatelessWidget {
  final Widget indicator;
  final String info;
  const RowStatusIndicator({super.key, required this.indicator, required this.info});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Flexible(flex:1, child: SizedBox(height: 20, width: 20, child: FittedBox(child: indicator))),
        Flexible(flex: 4, child: FittedBox(fit: BoxFit.fitWidth, child: Text(info, style: const TextStyle(fontSize: 20))))
      ],
    );
  }
}

class MyTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;

  const MyTextField({super.key, required this.hint, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: hint,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}
