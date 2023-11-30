import 'package:flutter/material.dart';
import 'package:flutter_insta/classes/app_colors.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomTextFormField extends StatefulWidget {
  const CustomTextFormField({
    super.key,
    this.label,
    this.onSaved,
    this.validations,
    this.hintText,
    this.isSecureTextEntry = false,
    this.textInputType,
    this.controller,
    this.cursorColor,
    this.fillColor,
    this.textColor,
    this.hintTextColor,
    this.borderColor,
    this.focusedBorderColor,
  });

  final Color? borderColor;
  final Color? focusedBorderColor;
  final Color? hintTextColor;
  final Color? textColor;
  final Color? fillColor;
  final Color? cursorColor;
  final String? label;
  final void Function(String?)? onSaved;
  final String? Function(String?)? validations;
  final String? hintText;
  final bool isSecureTextEntry;
  final TextInputType? textInputType;
  final TextEditingController? controller;

  @override
  State<CustomTextFormField> createState() => _CustomTextFormFieldState();
}

class _CustomTextFormFieldState extends State<CustomTextFormField> {
  bool _hideTextEntry = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (widget.label != null)
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: Text(
              widget.label!,
              style: GoogleFonts.poppins(
                color: appColors.secondary,
                fontSize: 18,
              ),
            ),
          ),
        if (widget.label != null)
          const SizedBox(
            height: 5,
          ),
        TextFormField(
          controller: widget.controller,
          style: GoogleFonts.poppins(
            color: widget.textColor ?? appColors.primary,
          ),
          cursorColor: widget.cursorColor ?? appColors.primary,
          keyboardType: widget.textInputType,
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(
              vertical: 10,
              horizontal: 15,
            ),
            filled: true,
            fillColor: widget.fillColor ?? appColors.secondary,
            border: OutlineInputBorder(
              borderSide: BorderSide(
                color: widget.borderColor ?? appColors.primary,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: widget.focusedBorderColor ?? appColors.primary,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.error,
              ),
            ),
            hintText: widget.hintText,
            hintStyle: GoogleFonts.poppins(
              color: widget.hintTextColor ?? appColors.primary,
            ),
            suffixIconColor: appColors.primary,
            suffixIcon: widget.isSecureTextEntry
                ? GestureDetector(
                    onTap: () => setState(() {
                      _hideTextEntry = !_hideTextEntry;
                    }),
                    child: Icon(
                      _hideTextEntry ? Icons.visibility : Icons.visibility_off,
                      size: 32,
                    ),
                  )
                : null,
          ),
          obscureText: widget.isSecureTextEntry ? _hideTextEntry : false,
          onSaved: widget.onSaved,
          validator: widget.validations,
        ),
      ],
    );
  }
}
