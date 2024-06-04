import 'package:flutter/material.dart';

class MyButtons extends StatelessWidget {
  final String text;
  final void Function()? onPressed;
  const MyButtons({
    super.key,
    required this.text,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(11),
            color: Colors.deepPurple,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 35, vertical: 11),
            child: Text(
              text,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }
}
