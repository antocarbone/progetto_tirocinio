import 'dart:io';

import 'package:dashboard_tirocinio/presentation/custom_components.dart';
import 'package:dashboard_tirocinio/screens/autenticazione/login_page.dart';
import 'package:dashboard_tirocinio/screens/impostazioni/settings_page.dart';
import 'package:dashboard_tirocinio/utility/api_helper.dart';
import 'package:dashboard_tirocinio/utility/utils.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:encrypt_shared_preferences/provider.dart';

class SensorDetailPage extends StatefulWidget {
  final Sensor sensor;
  const SensorDetailPage({super.key, required this.sensor});

  @override
  State<SensorDetailPage> createState() => _SensorDetailPageState();
}

class _SensorDetailPageState extends State<SensorDetailPage> {
  DateFormat dateTimeFormatter = DateFormat('yyyy/MM/dd kk:mm');
  DateTime? _startDateTime;
  DateTime? _endDateTime;
  final DateTime _defaultStart =
  DateTime.now().subtract(const Duration(days: 7));
  final DateTime _defaultEnd =
  DateTime.now().subtract(const Duration(minutes: 10));
  List<FlSpot> history = [];

  bool _isExpanded = false;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _valueController = TextEditingController();
  List<NotificaSensore> notifiche = [];
  late EncryptedSharedPreferences _prefs;
  String? _token;
  String? _userType;

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
        initialEntryMode: TimePickerEntryMode.dialOnly,
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

        if (isStartDate) {
          if (_endDateTime != null) {
            if (pickedDateTime.isBefore(_endDateTime!)) {
              setState(() {
                _startDateTime = pickedDateTime;
              });
            } else {
              Utils.showSnackBar(
                  context,
                  'Attenzione',
                  'La data di inizio deve essere precedente a quella di fine',
                  true);
            }
          } else {
            setState(() {
              _startDateTime = pickedDateTime;
            });
          }
        } else {
          if (_startDateTime != null) {
            if (pickedDateTime.isAfter(_startDateTime!)) {
              List<FlSpot> tmpHistory =
                  await getSensorReadings(widget.sensor.id,
                  _startDateTime!, pickedDateTime, _token!);
              setState(() {
                _endDateTime = pickedDateTime;
                history = tmpHistory;
              });
            } else {
              Utils.showSnackBar(
                  context,
                  'Attenzione',
                  'La data di fine deve essere successiva a quella di inizio',
                  true);
            }
          } else {
            List<FlSpot> tmpHistory =
            await getSensorReadings(widget.sensor.id,
                _startDateTime!, pickedDateTime, _token!);
            setState(() {
              _endDateTime = pickedDateTime;
              history = tmpHistory;
            });
          }
        }
      }
    }
  }

  void initPreferences() async {
    EncryptedSharedPreferences tmp;
    String? tmpToken = '';
    String? tmpType = '';
    try {
      await EncryptedSharedPreferences.initialize(Utils.encryptingKey);
      tmp = EncryptedSharedPreferences.getInstance();

    } on Exception catch (e) {
      Utils.showSnackBar(context, 'OPS', 'Qualcosa è andato storto, effettua nuovamente il login\n$e', true);
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
              builder: (context) => const LoginPage()),
              (Route<dynamic> route) => false);
      return;
    }

    setState(() {
      _prefs = tmp;
    });

    tmpToken = _prefs.getString('token');
    tmpType = _prefs.getString('tipo');

    setState(() {
      _token = tmpToken!;
      _userType = tmpType!;
    });

    await initHistory(_defaultEnd, _defaultEnd);
  }

  Future<void> initHistory(DateTime start, DateTime end) async {
    try {
      List<FlSpot> tmpHistory = await getSensorReadings(widget.sensor.id, start, end, _token!);
      setState(() {
        history = tmpHistory;
      });
    } on HttpException catch (e) {
      Utils.showSnackBar(context, 'ERRORE', e.message, true);
      Navigator.of(context).pop();
    }
    await initNotifiche();
  }

  Future<void> initNotifiche() async {
    try {
      List<NotificaSensore> tmpNotifiche = await getAllUserNotify(widget.sensor.id.toString(), _token!);
      setState(() {
        notifiche = tmpNotifiche;
      });
    } on HttpException catch (e) {
      Utils.showSnackBar(context, 'ERRORE', e.message, true);
      Navigator.of(context).pop();
    }
  }

  @override
  void initState() {
    super.initState();
    initPreferences();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Dettaglio'),
        actions: [
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Expanded(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 100),
                  width: _isExpanded ? _userType == 'admin' ? 80 : 40 : 0,
                  child: ListView(
                      scrollDirection: Axis.horizontal,
                      shrinkWrap: true,
                      children: [
                        if (_userType == 'admin') ... [Padding(
                            padding: const EdgeInsets.only(top: 10, bottom: 10, right: 5),
                            child: FittedBox(child: IconButton(
                                onPressed: () {
                                  Navigator.of(context).push(MaterialPageRoute(builder: (context) => const SettingsPage()));
                                },
                                icon: const Icon(Icons.settings))
                            )
                        )],
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: FittedBox(child: IconButton(
                              onPressed: () async {
                                await _prefs.remove('token');
                                await _prefs.remove('tipo');
                                Navigator.of(context).pushAndRemoveUntil(
                                    MaterialPageRoute(
                                        builder: (context) => const LoginPage()),
                                        (Route<dynamic> route) => false);
                              },
                              icon: const Icon(Icons.exit_to_app_rounded))),
                        )
                      ]
                  ),
                ),
              )
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(5),
            child: MyUserButton(onPressed: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            }),
          )
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: 800,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    MyGenericListElement(
                      leading: FittedBox(
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            RadiusChart(chartData: [ChartData('', widget.sensor.lettura)]),
                            widget.sensor.lettura != null ? Text(
                              '${widget.sensor.lettura}',
                              style: const TextStyle(
                                fontSize: 50,
                                fontWeight: FontWeight.bold,
                              ),
                            ) :
                            const Text(
                                'Non\nDisponibile',
                                style: TextStyle(
                                  fontSize: 25,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center
                            ),
                          ],
                        ),
                      ),
                      title: widget.sensor.nome,
                      subtitle: widget.sensor.lettura == null ? 'Non Disponibile' : '${widget.sensor.lettura} ${widget.sensor.unitaMisura}',
                    ),
                    Card(
                      elevation: 10,
                      child: Padding(
                        padding: const EdgeInsets.all(25),
                        child: Column(
                          children: [
                            if (history.isNotEmpty) ... [AspectRatio(
                              aspectRatio: 16 / 9,
                              child: SensorLineChart(
                                pointList: history,
                                start: _startDateTime == null ? _defaultStart : _startDateTime!,
                                  end: _endDateTime == null ? _defaultEnd : _endDateTime!
                              ),
                            )] else ... [
                              const Center(child: Text('Non sono presenti letture nel periodo specificato', textAlign: TextAlign.center))
                            ],
                            Padding(
                              padding: const EdgeInsets.only(top: 20),
                              child: FittedBox(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    TextButton(
                                      onPressed: () => _selectDateTime(context, true),
                                      child: Text(
                                        _startDateTime == null
                                            ? 'Da ${dateTimeFormatter.format(_defaultStart.toLocal())}'
                                            : 'Da ${dateTimeFormatter.format(_startDateTime!.toLocal())}',
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: () => _selectDateTime(context, false),
                                      child: Text(
                                        _endDateTime == null
                                            ? 'A ${dateTimeFormatter.format(_defaultEnd.toLocal())}'
                                            : 'A ${dateTimeFormatter.format(_endDateTime!.toLocal())}',
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    if(notifiche.isNotEmpty) ... [const Padding(
                      padding: EdgeInsets.symmetric(vertical: 10),
                      child: Center(
                          child: Text('Le tue notifiche',
                              style: TextStyle(
                                  fontSize: 25, fontWeight: FontWeight.bold))),
                    )],
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5),
                      child: ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: notifiche.length,
                        itemBuilder: (context, index) {
                          return MyGenericListElement(
                            leading: const Icon(Icons.notifications),
                            title: notifiche[index].nome,
                            subtitle: 'Avvisami quando ${notifiche[index].trigger} ${notifiche[index].benchmark}',
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  onPressed: () {
                                    showDialog(
                                        context: context,
                                        builder: (context) {
                                          return ConfirmDelete(onConfirm: () async {
                                            try {
                                              String res = await deleteNotify(notifiche[index].id, _token!);
                                              Utils.showSnackBar(context, 'NOTIFICA ELIMINATA', res, false);
                                              Navigator.of(context).pop();
                                              initNotifiche();
                                            } on HttpException catch (e) {
                                              await _prefs.clear();
                                              Utils.showSnackBar(context, 'ERRORE', e.message, true);
                                              Navigator.of(context).pushAndRemoveUntil(
                                                  MaterialPageRoute(
                                                      builder: (context) => const LoginPage()),
                                                      (Route<dynamic> route) => false);
                                            } on Exception catch (e) {
                                              Utils.showSnackBar(context, 'ERRORE', e.toString(), true);
                                              Navigator.of(context).pop();
                                            }
                                          });
                                        }
                                    );
                                  },
                                  icon: const Icon(Icons.delete_rounded),
                                ),
                                Switch(
                                  value: notifiche[index].status,
                                  onChanged: (value) async {
                                    try {
                                      String res = await updateNotify(notifiche[index].id, _token!);
                                      Utils.showSnackBar(context, 'STATO NOTIFICA AGGIORNATO', res, false);
                                      initNotifiche();
                                    } on HttpException catch (e) {
                                      await _prefs.clear();
                                      Utils.showSnackBar(context, 'ERRORE', e.message, true);
                                      Navigator.of(context).pushAndRemoveUntil(
                                          MaterialPageRoute(
                                              builder: (context) => const LoginPage()),
                                              (Route<dynamic> route) => false);
                                    } on Exception catch (e) {
                                      Utils.showSnackBar(context, 'ERRORE', e.toString(), true);
                                    }
                                  },
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 20),
                      child: Center(
                        child: ElevatedButton(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) {
                                return NotifyDialog(
                                  nameController: _nameController,
                                  valueController: _valueController,
                                  addNotifica: (String nome, String trigger, double valore) async {
                                    try {
                                      String res = await addNotify(widget.sensor.id.toString(), nome, trigger, valore, _token!);
                                      Utils.showSnackBar(super.context, 'NOTIFICA AGGIUNTA', res, false);
                                      initNotifiche();
                                    } on HttpException catch (e) {
                                      await _prefs.clear();
                                      Utils.showSnackBar(super.context, 'ERRORE', e.message, true);
                                      Navigator.of(context).pushAndRemoveUntil(
                                          MaterialPageRoute(
                                              builder: (context) => const LoginPage()),
                                              (Route<dynamic> route) => false);
                                    } on Exception catch (e) {
                                      Utils.showSnackBar(super.context, 'ERRORE', e.toString(), true);
                                    }
                                  },
                                );
                              },
                            );
                          },
                          child: const Text('Aggiungi una notifica'),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
  @override
  void dispose() {
    _nameController.dispose();
    _valueController.dispose();
    super.dispose();
  }
}

class NotifyDialog extends StatefulWidget {
  final TextEditingController nameController;
  final TextEditingController valueController;
  final void Function(String nome, String trigger, double valore) addNotifica;
  const NotifyDialog({super.key, required this.valueController, required this.addNotifica, required this.nameController});
  @override
  State<NotifyDialog> createState() => _NotifyDialogState();
}

class _NotifyDialogState extends State<NotifyDialog> {
  final _formKey = GlobalKey<FormState>();
  final List<String> items = ['>', '=', '<'];
  String? selectedValue;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Center(
          child: FittedBox(
            child: Text('Imposta il tipo di notifica',
                style: TextStyle(fontWeight: FontWeight.bold)),
          )),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 800),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    MyTextField(
                      validator: (valore) {
                        if (valore == null || valore.isEmpty) {
                          return 'Inserisci un nome!';
                        }
                        return null;
                      },
                      hint: 'Nome',
                      controller: widget.nameController,
                      onlyNumbers: false,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Flexible(
                              flex: 1,
                              child: Text('Invia quando:')),
                          Flexible(
                            flex: 1,
                            child: DropdownButtonFormField<String>(
                              validator: (selected) {
                                if (selected == null) {
                                  return 'Seleziona un trigger!';
                                }
                                return null;
                              },
                              value: selectedValue,
                              onChanged: (selected) {
                                setState(() {
                                  selectedValue = selected;
                                });
                              },
                              items: items.map(
                                    (item) {
                                  return DropdownMenuItem(
                                    value: item,
                                    child: Text(item),
                                  );
                                },
                              ).toList(),
                              hint: const Text('Trigger'),
                              icon: const Icon(Icons.arrow_drop_down),
                              iconSize: 24,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Flexible(
                              flex: 1,
                              child: Text('Del valore:')),
                          Flexible(
                            flex: 2,
                            child: MyTextField(
                              validator: (valore) {
                                if (valore == null || valore.isEmpty) {
                                  return 'Inserisci un valore!';
                                }
                                if (double.tryParse(valore) == null) {
                                  return 'Inserisci un valore numerico!';
                                }
                                return null;
                              },
                              hint: 'Valore',
                              controller: widget.valueController,
                              onlyNumbers: true,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        Center(
          child: ElevatedButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                widget.addNotifica(widget.nameController.text, selectedValue!, double.parse(widget.valueController.text));
                Navigator.of(context).pop();
              }
            },
            child: const Text('Aggiungi'),
          ),
        ),
      ],
    );
  }
}

class ConfirmDelete extends StatelessWidget {
  final VoidCallback onConfirm;
  const ConfirmDelete({super.key, required this.onConfirm});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Center(
          child: Text('Conferma', style: TextStyle(fontWeight: FontWeight.bold))
      ),
      actions: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Cancella')
            ),
            ElevatedButton(
                onPressed: onConfirm,
                child: const Text('Conferma')
            ),
          ],
        )
      ],
    );
  }
}