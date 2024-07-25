import 'package:flutter/material.dart';

class Utils {

  void showSnackBar(BuildContext context, String title, String subtitle, bool error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(backgroundColor: Colors.transparent,
        elevation: 0,
        content:  Container(
          decoration: BoxDecoration(
            color: error ? Colors.red.withOpacity(0.8) : Colors.green.withOpacity(0.8),
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