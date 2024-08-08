import 'package:dashboard_tirocinio/presentation/custom_components.dart';
import 'package:dashboard_tirocinio/utility/utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class NodeStatusHistory extends StatefulWidget {
  const NodeStatusHistory({super.key});

  @override
  State<NodeStatusHistory> createState() => _NodeStatusHistoryState();
}

class _NodeStatusHistoryState extends State<NodeStatusHistory> {
  DateFormat dateTimeFormatter = DateFormat('yyyy/MM/dd kk:mm');
  DateTime? _startDateTime;
  DateTime? _endDateTime;

  Future<void> _selectDateTime(BuildContext context, bool isStartDate) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(DateTime.now()),
      );

      if (pickedTime != null) {
        final DateTime pickedDateTime = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          pickedTime.hour,
          pickedTime.minute,
        );

        setState(() {
          if (isStartDate) {
            if(_endDateTime != null) {
              if (pickedDateTime.isBefore(_endDateTime!)) {
                _startDateTime = pickedDateTime;
              } else {
                Utils.showSnackBar(context, 'Attenzione', 'La data di inizio deve essere precedente a quella di fine', true);
              }
            } else {
              _startDateTime = pickedDateTime;
            }
          } else {
            if(_startDateTime != null) {
              if (pickedDateTime.isAfter(_startDateTime!)) {
                _endDateTime = pickedDateTime;
              } else {
                Utils.showSnackBar(context, 'Attenzione', 'La data di fine deve essere successiva a quella di inizio', true);
              }
            } else {
              _endDateTime = pickedDateTime;
            }
          }
        });
      }
    }
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
                      ? 'Imposta la data di inizio'
                      : 'Inizio: ${dateTimeFormatter.format(_startDateTime!.toLocal())}',
                ),
              ),
            ),
            TextButton(
              onPressed: () => _selectDateTime(context, false),
              child: FittedBox(
                child: Text(
                  _endDateTime == null
                      ? 'Imposta la data di fine'
                      : 'Fine: ${dateTimeFormatter.format(_endDateTime!.toLocal())}',
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: 20,
                itemBuilder: (context, index) {
                  return MyGenericListElement(
                    leading: const Icon(Icons.device_hub),
                    title: (index % 2 == 0) ? 'Online' : 'Offline',
                    subtitle: DateTime.now().toString(),
                  );
                },
              ),
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
