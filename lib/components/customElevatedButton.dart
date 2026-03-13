import 'package:flutter/material.dart';

class CustomElevatedButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const CustomElevatedButton({
    super.key,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      width: double.infinity,
      child: ElevatedButton(
          style: ElevatedButton.styleFrom(
              backgroundColor:  Colors.brown.shade400,
              foregroundColor: Colors.white,
              textStyle: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              )),
          onPressed: onPressed,
          child: Text(label,
              style: Theme.of(context)
                  .textTheme
                  .bodyLarge!
                  .copyWith(color: Colors.white))),
    );
  }
}
