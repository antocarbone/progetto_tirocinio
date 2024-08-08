import 'package:flutter/material.dart';

/*
  CLASSE DI UTILITÀ CONTENENTE METODI CHE POSSONO ESSERE CHIAMATI STATICAMENTE
  IMPORTANDO IL FILE utils.dart ED ACCEDENDO AI METODI E ATTRIBUTI DELLA CLASSE Utils
 */
class Utils {
  // VARIABILE STATICA CHE MEMORIZZA LA CHIAVE DI CRITTOGRAFIA UTILIZZATA DALLE ENCRYPTED SHARED PREFERENCES
  static String encryptingKey = 'ENCRYPTINGKEY16C';

  /*
    METODO CHE MOSTRA UNA SNACKBAR NEL CONTESTO PASSATO COME PARAMETRO.
    - context: contesto in cui mostrare la snackbar
    - title: titolo della snackbar
    - subtitle: sottotitolo della snackbar
    - error: booleano che indica se la snackbar rappresenta un errore (true) o un successo (false)
   */
  static void showSnackBar(
      BuildContext context, String title, String subtitle, bool error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        content: Container(
          decoration: BoxDecoration(
            color: error
                ? Colors.red.withOpacity(0.8)
                : Colors.green.withOpacity(0.8),
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: error ? Colors.red : Colors.green,
              child: Icon(
                error ? Icons.close : Icons.check,
                color: Colors.white,
              ),
            ),
            title: Text(
              title,
              style: const TextStyle(color: Colors.white),
            ),
            subtitle: Text(
              subtitle,
              style: const TextStyle(color: Colors.white),
            ),
            onTap: () {
              ScaffoldMessenger.of(context).clearSnackBars();
            },
          ),
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
