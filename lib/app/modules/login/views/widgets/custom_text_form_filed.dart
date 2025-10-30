import 'package:api_task/app/modules/login/views/widgets/custom_text.dart';
import 'package:flutter/material.dart';

class CustomTextFormFiled extends StatelessWidget {
  const CustomTextFormFiled({
    super.key,
    required this.text,
    required this.controller,
    required this.hintText,
    required this.icon,
    this.validator,
  });
  final String text;
  final String hintText;
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final IconData icon;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CustomText(text: text, alignment: Alignment.topLeft, fontSize: 14),
        SizedBox(height: 5),
        TextFormField(
          controller: controller,
          validator: (value) {
            if (value?.isEmpty ?? true) {
              return 'This Filed Is Required !!';
            }
            return null;
          },
          decoration: InputDecoration(
            fillColor: Colors.grey[200],
            filled: true,
            prefixIcon: Icon(icon, color: Colors.green),
            hintText: hintText,
            hintStyle: TextStyle(fontSize: 14),

            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(23),
              borderSide: BorderSide(color: Colors.green),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(23),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }
}
