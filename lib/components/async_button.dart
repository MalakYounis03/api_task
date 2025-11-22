import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class AsyncButton extends StatelessWidget {
  AsyncButton({super.key, required this.text, required this.onPressed});

  final String text;
  final Future<void> Function()? onPressed;

  final isLoading = ValueNotifier(false);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: isLoading.value
          ? null
          : () async {
              isLoading.value = true;
              await onPressed?.call();
              isLoading.value = false;
            },
      child: ValueListenableBuilder(
        valueListenable: isLoading,
        builder: (context, value, _) {
          if (value) {
            return CupertinoActivityIndicator(color: Colors.white);
          }
          return Text(text);
        },
      ),
    );
  }
}
