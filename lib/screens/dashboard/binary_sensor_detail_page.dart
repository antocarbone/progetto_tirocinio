import 'dart:io';

import 'package:dashboard_tirocinio/presentation/custom_components.dart';
import 'package:dashboard_tirocinio/screens/autenticazione/login_page.dart';
import 'package:dashboard_tirocinio/screens/impostazioni/settings_page.dart';
import 'package:dashboard_tirocinio/utility/api_helper.dart';
import 'package:dashboard_tirocinio/utility/utils.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:encrypt_shared_preferences/provider.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';


class BinarySensorDetailPage extends StatefulWidget {
  final BinarySensor sensor;
  const BinarySensorDetailPage({super.key, required this.sensor});

  @override
  State<BinarySensorDetailPage> createState() => _BinarySensorDetailPageState();
}

class _BinarySensorDetailPageState extends State<BinarySensorDetailPage> {
  DateFormat dateTimeFormatter = DateFormat('yyyy/MM/dd kk:mm');
  DateTime? _startDateTime;
  DateTime? _endDateTime;
  final DateTime _defaultStart =
      DateTime.now().subtract(const Duration(days: 7));
  final DateTime _defaultEnd =
      DateTime.now().subtract(const Duration(minutes: 10));

  late BinarySensorReadingsHistory history;
  bool _isExpanded = false;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _valueController = TextEditingController();
  List<NotificaSensoreBinario> notifiche = [];
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
              BinarySensorReadingsHistory tmpHistory =
                  await getBinarySensorReadings(widget.sensor.id,
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
            BinarySensorReadingsHistory tmpHistory =
                await getBinarySensorReadings(
                    widget.sensor.id, _defaultStart, pickedDateTime, _token!);
            setState(() {
              _endDateTime = pickedDateTime;
              history = tmpHistory;
            });
          }
        }
      }
    }
  }

  Future<void> initPreferences() async {
    EncryptedSharedPreferences tmp;
    String? tmpToken = '';
    String? tmpType = '';
    try {
      await EncryptedSharedPreferences.initialize(Utils.encryptingKey);
      tmp = EncryptedSharedPreferences.getInstance();
    } on Exception catch (e) {
      Utils.showSnackBar(context, 'OPS',
          'Qualcosa è andato storto, effettua nuovamente il login\n$e', true);
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginPage()),
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

    await initHistory(_defaultStart, _defaultEnd);
  }

  Future<void> initHistory(DateTime start, DateTime end) async {
    try {
      BinarySensorReadingsHistory tmpHistory =
          await getBinarySensorReadings(widget.sensor.id, start, end, _token!);
      setState(() {
        history = tmpHistory;
      });
    } on HttpException catch (e) {
      Utils.showSnackBar(context, 'ERRORE', e.message, true);
      Navigator.of(context).pop();
    }
    //await initNotifiche();
  }

  /*
  Future<void> initNotifiche() async {
    try {
      List<NotificaSensoreBinario> tmpNotifiche = await getNotify();
      setState(() {
        notifiche = tmpNotifiche;
      });
    } on HttpException catch (e) {
      Utils.showSnackBar(context, 'ERRORE', e.message, true);
      Navigator.of(context).pop();
    }
  }
  */

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
                  width: _isExpanded
                      ? _userType == 'admin'
                          ? 80
                          : 40
                      : 0,
                  child: ListView(
                      scrollDirection: Axis.horizontal,
                      shrinkWrap: true,
                      children: [
                        if (_userType == 'admin') ...[
                          Padding(
                              padding: const EdgeInsets.only(
                                  top: 10, bottom: 10, right: 5),
                              child: FittedBox(
                                  child: IconButton(
                                      onPressed: () {
                                        Navigator.of(context).push(
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    const SettingsPage()));
                                      },
                                      icon: const Icon(Icons.settings))))
                        ],
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: FittedBox(
                              child: IconButton(
                                  onPressed: () async {
                                    await _prefs.clear();
                                    Navigator.of(context).pushAndRemoveUntil(
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                const LoginPage()),
                                        (Route<dynamic> route) => false);
                                  },
                                  icon: const Icon(Icons.exit_to_app_rounded))),
                        )
                      ]),
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
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: SingleChildScrollView(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: 800,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    MyGenericListElement(
                      leading:
                          Icon(MdiIcons.fromString(widget.sensor.codiceIcona)),
                      title: widget.sensor.nome,
                      subtitle:
                          '${widget.sensor.valore ? widget.sensor.stringaTrue : widget.sensor.stringaFalse} - ${dateTimeFormatter.format(widget.sensor.dataLettura)}',
                    ),
                    ConstrainedBox(
                      constraints: const BoxConstraints(
                        maxHeight: 600,
                      ),
                      child: Card(
                        elevation: 10,
                        child: Padding(
                          padding: const EdgeInsets.all(25),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(bottom: 20),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    TextButton(
                                      onPressed: () =>
                                          _selectDateTime(context, true),
                                      child: Text(
                                        _startDateTime == null
                                            ? 'Da: ${dateTimeFormatter.format(_defaultStart.toLocal())}'
                                            : 'Da: ${dateTimeFormatter.format(_startDateTime!.toLocal())}',
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: () =>
                                          _selectDateTime(context, false),
                                      child: Text(
                                        _endDateTime == null
                                            ? 'A: ${dateTimeFormatter.format(_defaultEnd.toLocal())}'
                                            : 'A: ${dateTimeFormatter.format(_endDateTime!.toLocal())}',
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (history.readings.isNotEmpty) ... [Expanded(
                                child: ListView.builder(
                                  shrinkWrap: true,
                                  itemCount: history.readings.length,
                                  itemBuilder: (context, index) {
                                    return MyGenericListElement(
                                      title: history.readings[index].value
                                          ? widget.sensor.stringaTrue
                                          : widget.sensor.stringaFalse,
                                      subtitle: dateTimeFormatter
                                          .format(history.readings[index].date),
                                      leading: Icon(MdiIcons.fromString(
                                          widget.sensor.codiceIcona)),
                                    );
                                  },
                                ),
                              )] else ... [
                                const Center(child: Text('Non sono presenti letture nel periodo specificato'))
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),
                    if (notifiche.isNotEmpty) ...[
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 10),
                        child: Center(
                            child: Text('Le tue notifiche',
                                style: TextStyle(
                                    fontSize: 25,
                                    fontWeight: FontWeight.bold))),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 5),
                        child: ListView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: notifiche.length,
                          itemBuilder: (context, index) {
                            return MyGenericListElement(
                              leading: const Icon(Icons.notifications),
                              title:
                                  'Avvisami quando la lettura è ${notifiche[index].benchmark}',
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
                                                String res = await deleteBinaryNotify(notifiche[index].id, _token!);
                                                Utils.showSnackBar(context, 'NOTIFICA ELIMINATA', res, false);
                                                Navigator.of(context).pop();
                                                //initNotifiche();
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
                                        //initNotifiche();
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
                      )
                    ],
                    Center(
                      child: ElevatedButton(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) {
                              return NotifyDialog(
                                nameController: _nameController,
                                valueController: _valueController,
                                stringaTrue: widget.sensor.stringaTrue,
                                stringaFalse: widget.sensor.stringaFalse,
                                addNotifica: (String nome, bool benchmark) async {
                                  try {
                                    String res = await addBinaryNotify(nome, benchmark, _token!);
                                    Utils.showSnackBar(super.context, 'NOTIFICA AGGIUNTA', res, false);
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
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class NotifyDialog extends StatefulWidget {
  final TextEditingController nameController;
  final TextEditingController valueController;
  final String stringaTrue;
  final String stringaFalse;
  final void Function(String nome, bool benchmark) addNotifica;
  const NotifyDialog({super.key, required this.valueController, required this.addNotifica, required this.nameController, required this.stringaTrue, required this.stringaFalse});

  @override
  State<NotifyDialog> createState() => _NotifyDialogState();
}

class _NotifyDialogState extends State<NotifyDialog> {
  final _formKey = GlobalKey<FormState>();
  final List<String> items = ['true', 'false'];
  String? selectedValue;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Center(
          child: Text('Imposta il tipo di notifica',
              style: TextStyle(fontWeight: FontWeight.bold))),
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
                      controller: widget.valueController,
                      onlyNumbers: false,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Flexible(flex: 1, child: Text('Invia quando:')),
                        Expanded(
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
                                  child: Text(item == 'true' ? widget.stringaTrue : widget.stringaFalse),
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
                Navigator.of(context).pop();
                widget.addNotifica(widget.nameController.text, selectedValue! == 'true');
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