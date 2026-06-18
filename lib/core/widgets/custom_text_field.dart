import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Field input standar dengan label di atasnya.
class CustomTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String label;
  final String? hint;
  final bool obscureText;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final IconData? prefixIcon;
  final Widget? suffix;
  final bool numberOnly;
  final int maxLines;
  final void Function(String)? onChanged;
  final bool enabled;

  const CustomTextField({
    super.key,
    this.controller,
    required this.label,
    this.hint,
    this.obscureText = false,
    this.keyboardType,
    this.validator,
    this.prefixIcon,
    this.suffix,
    this.numberOnly = false,
    this.maxLines = 1,
    this.onChanged,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          enabled: enabled,
          keyboardType:
              keyboardType ?? (numberOnly ? TextInputType.number : null),
          inputFormatters:
              numberOnly ? [FilteringTextInputFormatter.digitsOnly] : null,
          maxLines: obscureText ? 1 : maxLines,
          validator: validator,
          onChanged: onChanged,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
            suffixIcon: suffix,
          ),
        ),
      ],
    );
  }
}
