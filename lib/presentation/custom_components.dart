import 'package:dashboard_tirocinio/screens/dashboard/node_status_history.dart';
import 'package:dashboard_tirocinio/screens/dashboard/sensor_detail_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:fl_chart/fl_chart.dart';

// WIDGET UTILE A MOSTRARE LO STATUS DEGLI STEP DELLA CONFIGURAZIONE DEL DISPOSITIVO
class RowStatusIndicator extends StatelessWidget {
  final Widget indicator;
  final String info;
  const RowStatusIndicator({super.key, required this.indicator, required this.info});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Flexible(flex:1, child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 5),
          child: SizedBox(height: 20, width: 20, child: FittedBox(child: indicator)),
        )),
        Flexible(flex: 4, child: FittedBox(fit: BoxFit.fitWidth, child: Text(info, style: const TextStyle(fontSize: 20))))
      ],
    );
  }
}

// WIDGET PERSONALIZZATO UTILE A MOSTRARE DELLE INFO
class MyGenericListElement extends StatelessWidget {
  final Widget leading;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  const MyGenericListElement({super.key, required this.leading, required this.title, this.subtitle, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 10,
      child: ListTile(
        leading: leading,
        title: Center(child: FittedBox(child: Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)))),
        subtitle: subtitle == null ? null : Center(child: Text(subtitle!, style: const TextStyle(fontSize: 15))),
        trailing: trailing,
      ),
    );
  }
}

// TEXT FORM FIELD PERSONALIZZATO CON BORDI STONDATI E LABEL
class MyTextField extends StatelessWidget {
  final String? Function(String?)? validator;
  final TextEditingController controller;
  final bool onlyNumbers;
  final String hint;

  const MyTextField({super.key, required this.hint, required this.controller, this.validator, required this.onlyNumbers});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        keyboardType: onlyNumbers ? TextInputType.number : null,
        validator: validator,
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

// DROPDOWN BUTTON STILIZZATO
class MyDropdownButton extends StatelessWidget {
  final String value;
  final void Function(String?) onChanged;
  final List<DropdownMenuItem<String>> items;
  const MyDropdownButton({super.key, required this.value, required this.onChanged, required this.items});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(10)),

      child: DropdownButtonFormField<String>(
        value: value,
        onChanged: onChanged,
        items: items,
        icon: const Icon(Icons.arrow_drop_down),
        iconSize: 42,
      ),
    );
  }
}


// WIDGET DEDICATO AL RADIUS CHART DELLA LIBRERIA SYNCFUSION-FLUTTER-CHARTS
// PER RAPPRESENTARE LA LETTURA DEI SENSORI
class RadiusChart extends StatelessWidget {
  final List<ChartData> chartData;
  const RadiusChart({super.key, required this.chartData});


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

// CLASSE RAPPRESENTANTE IL VALORE NEL GRAFICO
class ChartData {
  ChartData(this.x, this.y);

  final String x;
  final num? y;
}

// WIDGET CHE RAPPRESENTA UN SENSORE CON IL BAR CHART, IL VALORE LETTO E IL SUO NOME
class MySensorInfo extends StatelessWidget {
  final double sensorValue;
  final String sensorName;
  const MySensorInfo({super.key, required this.sensorValue, required this.sensorName});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute(builder: (context) => const SensorDetailPage()));
      },
      child: Card(
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
                    RadiusChart(chartData: [ChartData('', sensorValue)]),
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
      ),
    );
  }
}

// WIDGET CHE RAPPRESENTA UN SENSORE BINARIO CON IL SUO VALORE NOME E TIMESTAMP
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


// WIDGET CHE RAPPRESENTA UN NODO CON I SUOI SENSORI COME LISTA SCROLLABILE ORIZZONTALMENTE
// OGNI SENSORE è CLICCABILE E PORTA ALLA PROPRIA PAGINA DI DETTAGLIO
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
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Center(
                  child: TextButton(
                    onPressed: () {
                      showDialog(
                          context: context,
                          builder: (context) {
                            return const NodeStatusHistory();
                          }
                      );
                    },
                    child: const Text('stato: online', style: TextStyle(color: Colors.black)),
                  ),
                ),
              )
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

// ICON BUTTON CON ICONA DELL'UTENTE CHE PERMETTE DI ESPANDERE
// L'ANIMATED CONTAINER CHE MOSTRA I PULSANTI DI IMPOSTAZIONI E LOG-OUT
class MyUserButton extends StatelessWidget {
  final VoidCallback onPressed;
  const MyUserButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return IconButton(
        onPressed: onPressed,
        icon: const Icon(Icons.person));
  }
}


// LINE CHART DELLA LIBRERIA FL CHARTS UTILE A RAPPRESENTARE
// LO STORICO DELLE LETTURE DEI SENSORI
class SensorLineChart extends StatelessWidget {
  final List<FlSpot> pointList;
  const SensorLineChart({super.key, required this.pointList});

  @override
  Widget build(BuildContext context) {
    return LineChart(
        LineChartData(
          lineTouchData: LineTouchData(
            enabled: true,
            touchTooltipData: LineTouchTooltipData(
              getTooltipColor: (LineBarSpot touchedSpot) => const Color(0x5E935A39),
            ),
          ),
          gridData: FlGridData(
            show: true,
            drawHorizontalLine: true,
            verticalInterval: 100,
            horizontalInterval: 10,
            getDrawingVerticalLine: (value) {
              return const FlLine(
                color: Color(0xFF673F28),
                strokeWidth: 1,
              );
            },
            getDrawingHorizontalLine: (value) {
              return const FlLine(
                color: Color(0xFF673F28),
                strokeWidth: 1,
              );
            },
          ),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 25,
                getTitlesWidget: lineChartBottomTitleWidgets,
                interval: 1,
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: lineChartLeftTitleWidgets,
                reservedSize: 45,
                interval: 1,
              ),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
          ),
          borderData: FlBorderData(
            show: true,
            border: Border.all(color: const Color(0xFF673F28)),
          ),
          minX: 0,
          maxX: 1440,
          minY: 0,
          maxY: 50,
          lineBarsData: [
            LineChartBarData(
              spots: pointList,
              isCurved: true,
              color: const Color(0xFF673F28),
              barWidth: 5,
              isStrokeCapRound: true,
              dotData: const FlDotData(
                show: true,
              ),
              belowBarData: BarAreaData(
                show: true,
                color: const Color(0x32673F28),
              ),
            ),
          ],
        )
    );
  }

  Widget lineChartBottomTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 14,
      color: Color(0xFF673F28),
    );
    Widget text;
    switch (value.toInt()) {
      case 720:
        text = const Text('Last 24 Hours', style: style);
        break;
      default:
        text = const Text('', style: style);
        break;
    }

    return SideTitleWidget(
      axisSide: meta.axisSide,
      child: text,
    );
  }

  Widget lineChartLeftTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 12,
      color: Color(0xFF673F28),
    );
    String text;
    switch (value.toInt()) {
      case 0:
        text = '0%';
        break;
      case 50:
        text = '50%';
        break;
      case 100:
        text = '100%';
        break;
      default:
        return Container();
    }
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Text(text, style: style, textAlign: TextAlign.right),
    );
  }
}