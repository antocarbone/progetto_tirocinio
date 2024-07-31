import 'package:dashboard_tirocinio/presentation/custom_components.dart';
import 'package:dashboard_tirocinio/screens/autenticazione/login_page.dart';
import 'package:dashboard_tirocinio/screens/impostazioni/settings_page.dart';
import 'package:dashboard_tirocinio/utility/utils.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:encrypt_shared_preferences/provider.dart';

class Notifica {
  Notifica(this.trigger, this.valore, this.isActive);

  final String trigger;
  final double valore;
  bool isActive;
}

class SensorDetailPage extends StatefulWidget {
  const SensorDetailPage({super.key});

  @override
  State<SensorDetailPage> createState() => _SensorDetailPageState();
}

class _SensorDetailPageState extends State<SensorDetailPage> {
  Utils utils = Utils();
  DateFormat dateTimeFormatter = DateFormat('yyyy/MM/dd kk:mm');
  DateTime? _startDateTime;
  DateTime? _endDateTime;
  bool _isExpanded = false;
  final TextEditingController _valueController = TextEditingController();
  List<Notifica> notifiche = [];
  late EncryptedSharedPreferences _prefs;
  String? _token;
  String? _userType;

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
                utils.showSnackBar(context, 'Attenzione', 'La data di inizio deve essere precedente a quella di fine', true);
              }
            } else {
              _startDateTime = pickedDateTime;
            }
          } else {
            if(_startDateTime != null) {
              if (pickedDateTime.isAfter(_startDateTime!)) {
                _endDateTime = pickedDateTime;
              } else {
                utils.showSnackBar(context, 'Attenzione', 'La data di fine deve essere successiva a quella di inizio', true);
              }
            } else {
              _endDateTime = pickedDateTime;
            }
          }
        });
      }
    }
  }

  void initPreferences() async {
    EncryptedSharedPreferences tmp;
    String? tmpToken = '';
    String? tmpType = '';
    try {
      await EncryptedSharedPreferences.initialize('Utils.encryptingKey');
      tmp = EncryptedSharedPreferences.getInstance();

    } on Exception catch (e) {
      utils.showSnackBar(context, 'OPS', 'Qualcosa è andato storto, effettua nuovamente il login\n$e', true);
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
        backgroundColor: Colors.orangeAccent.shade200,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                bottomRight: Radius.circular(20),
                bottomLeft: Radius.circular(20))),
        title: const Text('Home'),
        actions: [
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Expanded(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 100),
                  width: _isExpanded ? 80 : 0,
                  child: ListView(
                      scrollDirection: Axis.horizontal,
                      shrinkWrap: true,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 10, bottom: 10, right: 5),
                          child: FittedBox(child: IconButton(onPressed: () {
                            Navigator.of(context).push(MaterialPageRoute(builder: (context) => const SettingsPage()));
                          }, icon: const Icon(Icons.settings))),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: FittedBox(child: IconButton(
                              onPressed: () async {
                                await _prefs.clear();
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
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: SingleChildScrollView(
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
                            RadiusChart(chartData: [ChartData('', 20)]),
                            const Text(
                              '20°C',
                              style: TextStyle(
                                  fontSize: 50, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                      title: 'nome sensore',
                    ),
                    Card(
                      elevation: 10,
                      child: Padding(
                        padding: const EdgeInsets.all(25),
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(bottom: 20),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  TextButton(
                                    onPressed: () => _selectDateTime(context, true),
                                    child: Text(
                                      _startDateTime == null
                                          ? 'Imposta la data di inizio'
                                          : 'Inizio: ${dateTimeFormatter.format(_startDateTime!.toLocal())}',
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () => _selectDateTime(context, false),
                                    child: Text(
                                      _endDateTime == null
                                          ? 'Imposta la data di fine'
                                          : 'Fine: ${dateTimeFormatter.format(_endDateTime!.toLocal())}',
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const AspectRatio(
                              aspectRatio: 16 / 9,
                              child: SensorLineChart(pointList: [
                                FlSpot(200, 10),
                                FlSpot(400, 20),
                                FlSpot(600, 30),
                                FlSpot(800, 40)
                              ]),
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
                            title:
                            'Avvisami quando la lettura è ${notifiche[index].trigger} ${notifiche[index].valore}',
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  onPressed: () {
                                    setState(() {
                                      notifiche.removeAt(index);
                                    });
                                  },
                                  icon: const Icon(Icons.delete_rounded),
                                ),
                                Switch(
                                  value: notifiche[index].isActive,
                                  onChanged: (value) {
                                    setState(() {
                                      notifiche[index].isActive = value;
                                    });
                                  },
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                    Center(
                      child: ElevatedButton(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) {
                              return NotifyDialog(
                                valueController: _valueController,
                                addNotifica: (String trigger, double valore) {
                                  setState(() {
                                    notifiche.add(Notifica(trigger, valore, true));
                                  });
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
  final TextEditingController valueController;
  final void Function(String trigger, double valore) addNotifica;
  const NotifyDialog(
      {super.key, required this.valueController, required this.addNotifica});

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
          child: Text('Imposta il tipo di notifica',
              style: TextStyle(fontWeight: FontWeight.bold))),
      content: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 800),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    Row(
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
                    const SizedBox(height: 20),
                    Row(
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
                widget.addNotifica(selectedValue!,
                    double.parse(widget.valueController.text));
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

