import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

// WIDGET UTILE A MOSTRARE LO STATUS DEGLI STEP DELLA CONFIGURAZIONE DEL DISPOSITIVO
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


// TEXT FORM FIELD PERSONALIZZATO CON BORDI STONDATI E LABEL
class MyTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;

  const MyTextField({super.key, required this.hint, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Devi inserire un nome!';
          }
          return null;
        },
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


class RadiusChart extends StatefulWidget {
  const RadiusChart({super.key});

  @override
  State<RadiusChart> createState() => _RadiusChartState();
}

class _RadiusChartState extends State<RadiusChart> {
  final List<_ChartData> chartData = [_ChartData('', 20)];
  
  @override
  Widget build(BuildContext context) {
    return SfCircularChart(
      series: [
        RadialBarSeries<_ChartData, String>(
            maximumValue: 50,
            radius: '70%',
            innerRadius: '90%',
            dataSource: chartData,
            cornerStyle: CornerStyle.bothCurve,
            xValueMapper: (_ChartData data, _) => data.x,
            yValueMapper: (_ChartData data, _) => data.y,
            pointColorMapper: (_ChartData data, _) => Colors.orangeAccent.shade400,
            dataLabelMapper: (_ChartData data, _) => '',
            trackColor: Colors.orange.shade100,
            dataLabelSettings: const DataLabelSettings(isVisible: true))
      ],
    );
  }
}


class _ChartData {
  _ChartData(this.x, this.y);

  final String x;
  final num? y;
}