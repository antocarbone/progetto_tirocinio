import 'dart:io';

import 'package:dashboard_tirocinio/presentation/custom_components.dart';
import 'package:dashboard_tirocinio/screens/autenticazione/login_page.dart';
import 'package:dashboard_tirocinio/utility/api_helper.dart';
import 'package:dashboard_tirocinio/utility/utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class NodeStatusHistory extends StatefulWidget {
  final String nodeId;
  final String token;
  const NodeStatusHistory({super.key, required this.token, required this.nodeId});

  @override
  State<NodeStatusHistory> createState() => _NodeStatusHistoryState();
}

class _NodeStatusHistoryState extends State<NodeStatusHistory> {
  DateFormat dateTimeFormatter = DateFormat('dd-MM-yyyy kk:mm');
  DateTime? _startDateTime;
  DateTime? _endDateTime;
  final DateTime _defaultStart = DateTime.now().subtract(const Duration(days: 7));
  final DateTime _defaultEnd = DateTime.now().subtract(const Duration(minutes: 10));
  List<StatoNodo> history = [];
  bool isHistoryInit = false;

  Future<void> _selectDateTime(BuildContext context, bool isStartDate) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );

    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(DateTime.now()),
        initialEntryMode: TimePickerEntryMode.dialOnly
      );

      if (pickedTime != null) {
        final DateTime pickedDateTime = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          pickedTime.hour,
          pickedTime.minute,
        );

          if (isStartDate) {
            if(_endDateTime != null) {
              if (pickedDateTime.isBefore(_endDateTime!)) {
                setState(() {
                  _startDateTime = pickedDateTime;
                });
              } else {
                Utils.showSnackBar(context, 'Attenzione', 'La data di inizio deve essere precedente a quella di fine', true);
              }
            } else {
              setState(() {
                _startDateTime = pickedDateTime;
              });
            }
          } else {
            if (_startDateTime != null) {
              if (pickedDateTime.isAfter(_startDateTime!)) {
                List<StatoNodo> tmpHistory = await getNodeStatusHistory(widget.nodeId, _startDateTime!, pickedDateTime, widget.token);
                setState(() {
                  _endDateTime = pickedDateTime;
                  history = tmpHistory;
                });
              } else {
                Utils.showSnackBar(context, 'Attenzione',
                    'La data di fine deve essere successiva a quella di inizio',
                    true);
              }
            } else {
              List<StatoNodo> tmpHistory = await getNodeStatusHistory(widget.nodeId, _defaultStart, pickedDateTime, widget.token);
              setState(() {
                _endDateTime = pickedDateTime;
                history = tmpHistory;
              });
            }
          }
      }
    }
  }

  void initHistory(DateTime start, DateTime end) async {
    try {
      List<StatoNodo> tmpHistory = await getNodeStatusHistory(widget.nodeId, start, end, widget.token);
      setState(() {
        history = tmpHistory;
        isHistoryInit = true;
      });
    } on HttpException catch (e) {
      Utils.showSnackBar(context, 'ERRORE', e.message, true);
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
              builder: (context) => const LoginPage()),
              (Route<dynamic> route) => false);
    }
  }

  @override
  void initState() {
    super.initState();
    initHistory(_defaultStart, _defaultEnd);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Center(
        child: Text('Status History', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      content: SizedBox(
        width: kIsWeb ? 800 : double.maxFinite,
        height: kIsWeb ? 600 : 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextButton(
              onPressed: () => _selectDateTime(context, true),
              child: FittedBox(
                child: Text(
                  _startDateTime == null
                      ? 'Da: ${dateTimeFormatter.format(_defaultStart.toLocal())}'
                      : 'Da: ${dateTimeFormatter.format(_startDateTime!.toLocal())}',
                ),
              ),
            ),
            TextButton(
              onPressed: () => _selectDateTime(context, false),
              child: FittedBox(
                child: Text(
                  _endDateTime == null
                      ? 'A: ${dateTimeFormatter.format(_defaultEnd.toLocal())}'
                      : 'A: ${dateTimeFormatter.format(_endDateTime!.toLocal())}',
                ),
              ),
            ),
            Expanded(
              child: !isHistoryInit ? const Center(child:  SizedBox(child: CircularProgressIndicator())) : history.isNotEmpty ? ListView.builder(
                itemCount: history.length,
                itemBuilder: (context, index) {
                  return MyGenericListElement(
                    leading: const Icon(Icons.device_hub),
                    title: history[index].status,
                    subtitle: 'Da ${dateTimeFormatter.format(history[index].start)}\n${history[index].end == null ? 'In corso' : 'A ${dateTimeFormatter.format(history[index].end!)}'}',
                  );
                },
              ) : const Text('Nessun informazione riguardante lo stato nel periodo selezionato', textAlign: TextAlign.center),
            ),
          ],
        ),
      ),
      actions: [
        Center(
          child: ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Chiudi'),
          ),
        ),
      ],
    );
  }
}
