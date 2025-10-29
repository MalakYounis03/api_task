import 'package:flutter/material.dart';

class CustomIcon extends StatelessWidget {
  const CustomIcon({super.key, required this.icon, required this.onTap});
  final IconData icon;
  final void Function()? onTap;
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 50,

        height: 50,
        decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle),
        child: Center(child: Icon(icon, color: Colors.green, size: 25)),
      ),
    );
  }
}
