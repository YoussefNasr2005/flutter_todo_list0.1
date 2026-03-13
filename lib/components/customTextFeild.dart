import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final String titleBeforeTextFeild;
  final String hint;
  String? Function(String?)? validator;
  TextEditingController myController = TextEditingController();

  CustomTextField({
    super.key,
    required this.titleBeforeTextFeild,
    required this.hint,
    required this.validator,
    required this.myController,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          titleBeforeTextFeild,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        const SizedBox(height: 5),
        TextFormField(
          validator: validator,
          controller: myController,
          decoration: InputDecoration(
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(35),
                borderSide: const BorderSide(
                    color: Color.fromARGB(255, 173, 6, 6), width: 2)),
            hint: Text(hint),
            filled: true,
            fillColor: const Color.fromARGB(
              255,
              231,
              222,
              222,
            ),
            border: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(35)),
            ),
          ),
        ),
      ],
    );
  }
}
