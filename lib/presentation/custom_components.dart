import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
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


class RadiusChart extends StatelessWidget {
  RadiusChart({super.key});
  final List<ChartData> chartData = [ChartData('', 20)];

  @override
  Widget build(BuildContext context) {
    return SfCircularChart(
      series: [
        RadialBarSeries<ChartData, String>(
            maximumValue: 50,
            radius: '70%',
            innerRadius: '90%',
            dataSource: chartData,
            cornerStyle: CornerStyle.bothCurve,
            xValueMapper: (ChartData data, _) => data.x,
            yValueMapper: (ChartData data, _) => data.y,
            pointColorMapper: (ChartData data, _) => Colors.orangeAccent.shade400,
            dataLabelMapper: (ChartData data, _) => '',
            trackColor: Colors.orange.shade100,
            dataLabelSettings: const DataLabelSettings(isVisible: true))
      ],
    );
  }
}

class ChartData {
  ChartData(this.x, this.y);

  final String x;
  final num? y;
}


class MySensorInfo extends StatelessWidget {
  final double sensorValue;
  final String sensorName;
  const MySensorInfo({super.key, required this.sensorValue, required this.sensorName});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 10,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: FittedBox(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  RadiusChart(),
                  Text(
                    '$sensorValue',
                    style: const TextStyle(
                      fontSize: 50,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Text(
                sensorName,
                style: const TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}


class MyBinarySensorInfo extends StatelessWidget {
  final bool sensorValue;
  final String sensorName;
  const MyBinarySensorInfo({super.key, required this.sensorValue, required this.sensorName});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 10,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: FittedBox(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(flex: 5, child: Icon(sensorValue ? Icons.person : Icons.person_outline_rounded, size: 500)),
              Flexible(
                flex: 2,
                child: Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Text(
                    sensorName,
                    style: const TextStyle(
                      fontSize: 50,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MyNodeSummary extends StatefulWidget {
  final String nodeName;

  const MyNodeSummary({
    super.key,
    required this.nodeName,
  });

  @override
  State<MyNodeSummary> createState() => _MyNodeSummaryState();
}

class _MyNodeSummaryState extends State<MyNodeSummary> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(
        minWidth: 500,
      ),
      child: Card(
        elevation: 8,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  widget.nodeName,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: kIsWeb ? 650 : 580,
                ),
                child: SizedBox(
                  height: 200,
                  child: kIsWeb
                      ? Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back),
                        onPressed: () {
                          _scrollList(AxisDirection.left);
                        },
                      ),
                      Expanded(
                        child: _buildListView(),
                      ),
                      IconButton(
                        icon: const Icon(Icons.arrow_forward),
                        onPressed: () {
                          _scrollList(AxisDirection.right);
                        },
                      ),
                    ],
                  )
                      : _buildListView(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildListView() {
    return ListView.builder(
      controller: kIsWeb ? _scrollController : null,
      scrollDirection: Axis.horizontal,
      shrinkWrap: true,
      itemCount: 6,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: MySensorInfo(
            sensorValue: 20.5,
            sensorName: 'Temperatura ${index + 1}',
          ),
        );
      },
    );
  }

  void _scrollList(AxisDirection direction) {
    final offset = direction == AxisDirection.left
        ? -_scrollController.position.viewportDimension
        : _scrollController.position.viewportDimension;
    _scrollController.animateTo(
      _scrollController.offset + offset,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }
}