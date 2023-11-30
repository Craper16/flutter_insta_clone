import 'package:flutter/material.dart';
import 'package:flutter_insta/classes/app_colors.dart';
import 'package:google_fonts/google_fonts.dart';

class VerificationInputFormField extends StatefulWidget {
  const VerificationInputFormField({
    super.key,
    required this.textFocusNode,
    required this.onSaved,
    this.nextFocusNode,
    this.previousFocusNode,
    this.validation,
  });

  final FocusNode textFocusNode;
  final FocusNode? previousFocusNode;
  final FocusNode? nextFocusNode;
  final void Function(String?)? onSaved;
  final String? Function(String?)? validation;

  @override
  State<VerificationInputFormField> createState() =>
      _VerificationInputFormFieldState();
}

class _VerificationInputFormFieldState
    extends State<VerificationInputFormField> {
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: SizedBox(
        height: 50,
        child: TextFormField(
          autofocus: true,
          maxLength: 1,
          focusNode: widget.textFocusNode,
          keyboardType: TextInputType.number,
          onTap: null,
          validator: widget.validation,
          decoration: InputDecoration(
            counterText: '',
            border: UnderlineInputBorder(
              borderSide: BorderSide(
                color: appColors.secondary,
              ),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(
                color: appColors.secondary,
              ),
            ),
            errorBorder: UnderlineInputBorder(
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.error,
              ),
            ),
          ),
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(
            color: appColors.secondary,
            fontSize: 28,
            fontWeight: FontWeight.w500,
          ),
          cursorWidth: 0,
          cursorColor: appColors.secondary,
          onChanged: (value) {
            if (value.isEmpty) {
              return FocusScope.of(context).requestFocus(
                widget.previousFocusNode,
              );
            }
            return FocusScope.of(context).requestFocus(
              widget.nextFocusNode,
            );
          },
          onSaved: widget.onSaved,
        ),
      ),
    );
  }
}
