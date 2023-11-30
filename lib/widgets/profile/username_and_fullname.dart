import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class UsernameAndFullName extends StatelessWidget {
  const UsernameAndFullName({
    super.key,
    this.fullName,
    this.username,
  });

  final String? username;
  final String? fullName;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              username ?? '',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            Text(
              fullName ?? '',
              style: GoogleFonts.poppins(
                fontSize: 14,
              ),
            )
          ],
        ),
      ),
    );
  }
}
