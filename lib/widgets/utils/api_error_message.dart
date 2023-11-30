import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ApiErrorMessage extends StatelessWidget {
  const ApiErrorMessage({
    super.key,
    this.errorMessage,
  });

  final String? errorMessage;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: errorMessage != null
          ? Align(
              alignment: Alignment.bottomCenter,
              child: Text(
                errorMessage!,
                style: GoogleFonts.poppins(
                  color: Theme.of(context).colorScheme.error,
                  fontSize: 18,
                ),
              ),
            )
          : null,
    );
  }
}
