import 'package:dashboard_tirocinio/presentation/custom_components.dart';
import 'package:dashboard_tirocinio/screens/autenticazione/login_page.dart';
import 'package:dashboard_tirocinio/screens/impostazioni/areas_manage_page.dart';
import 'package:dashboard_tirocinio/screens/impostazioni/users_manage_page.dart';
import 'package:dashboard_tirocinio/utility/utils.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final Utils utils = Utils();
  bool _isExpanded = false;
  late SharedPreferences _prefs;
  String? _token;
  String? _userType;


  void initPreferences() async {
    SharedPreferences tmp;
    String? tmpToken = '';
    String? tmpType = '';
    try {
      tmp = await SharedPreferences.getInstance();

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
        title: const Text('Impostazioni'),
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
                          child: FittedBox(child: IconButton(onPressed: () {}, icon: const Icon(Icons.settings))),
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
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                  maxWidth: 500
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (_userType == 'admin') ... [Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: ElevatedButton(
                              onPressed: () {
                                Navigator.of(context).push(MaterialPageRoute(builder: (context) => const UsersManagePage()));
                              },
                              child: const Text('Gestione utenti', style: TextStyle(fontSize: 35))
                          ),
                        ),
                      ],
                    ),
                  )],
                  Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: ElevatedButton(
                              onPressed: () {
                                Navigator.of(context).push(MaterialPageRoute(builder: (context) => const AreasManagePage()));
                              },
                              child: const Text('Gestione aree', style: TextStyle(fontSize: 35))
                          ),
                        ),
                      ],
                    ),
                  ),
            if (_userType == 'admin') ... [Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: ElevatedButton(
                            onPressed: () {},
                            child: const Text('Cambia password', style: TextStyle(fontSize: 35))
                        ),
                      ),
                    ],
                  )],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
