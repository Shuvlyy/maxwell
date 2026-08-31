import 'package:flutter/cupertino.dart';

void showBaseDialog(BuildContext context, String title, String message)
{
  showCupertinoDialog(
    context: context,
    builder: (context) => CupertinoAlertDialog(
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 20
        ),
      ),
      content: Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Text(
          message,
          style: const TextStyle(
            fontSize: 16
          ),
        ),
      ),
      actions: [
        CupertinoDialogAction(
          isDefaultAction: true,
          child: const Text('Close'),
          onPressed: () => Navigator.pop(context),
        ),
      ],
    ),
  );
}

void showErrorDialog(BuildContext context, String message)
{
  showBaseDialog(context, 'Error', message);
}
