import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';

class ErrorIndicator extends StatelessWidget {
  const ErrorIndicator({
    super.key,
    this.errorMessage,
  });

  final String? errorMessage;

  @override
  Widget build(BuildContext context) {
    return Text(
      errorMessage ?? 'An error has occured',
      style: GoogleFonts.poppins(),
    );
  }
}
