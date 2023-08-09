import 'package:flutter/material.dart';

class DynamicDialog extends StatefulWidget {
  final String? title;
  final String? body;
  const DynamicDialog({super.key, this.title, this.body});
  @override
  DynamicDialogState createState() => DynamicDialogState();
}

class DynamicDialogState extends State<DynamicDialog> {
  @override
  Widget build(BuildContext context) {
    // You can change the UI as per
    // your requirement or choice
    return AlertDialog(
      title: Text(widget.title ?? ''),
      actions: <Widget>[
        OutlinedButton.icon(
            label: const Text('Close'),
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(Icons.close))
      ],
      content: Text(widget.body ?? ''),
    );
  }
}
