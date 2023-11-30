import 'package:flutter/material.dart';
import 'package:flutter_insta/classes/app_colors.dart';
import 'package:google_fonts/google_fonts.dart';

class FormInput extends StatelessWidget {
  const FormInput({
    super.key,
    required this.label,
    this.onSaved,
    this.controller,
    this.onLabelPress,
    this.textInputType,
    this.validator,
  });

  final String label;
  final void Function()? onLabelPress;
  final void Function(String?)? onSaved;
  final TextEditingController? controller;
  final TextInputType? textInputType;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        GestureDetector(
          onTap: onLabelPress,
          child: SizedBox(
            width: 120,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
              ),
              child: Text(
                label,
                style: GoogleFonts.poppins(
                  color: appColors.secondary,
                ),
              ),
            ),
          ),
        ),
        Expanded(
          child: TextFormField(
            onSaved: onSaved,
            controller: controller,
            keyboardType: textInputType,
            validator: validator,
            style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                  color: appColors.secondary,
                ),
            cursorColor: appColors.secondary,
            decoration: InputDecoration(
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(
                  width: 0.2,
                  color: appColors.secondary,
                ),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(
                  width: 0.2,
                  color: appColors.secondary,
                ),
              ),
              border: UnderlineInputBorder(
                borderSide: BorderSide(
                  width: 0,
                  color: appColors.secondary,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
