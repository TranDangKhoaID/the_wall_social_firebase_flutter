//display a dialog message
import 'package:flutter/material.dart';

void displayMessage(String message, BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Thông báo $message'),
      ),
    );
  }