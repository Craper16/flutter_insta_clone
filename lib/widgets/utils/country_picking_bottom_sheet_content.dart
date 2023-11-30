import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_insta/classes/app_colors.dart';
import 'package:flutter_insta/classes/country_code.dart';
import 'package:flutter_insta/constants/country_codes.dart';
import 'package:flutter_insta/widgets/utils/bottom_modal_sheet_handle.dart';
import 'package:google_fonts/google_fonts.dart';

class CountryPickingBottomSheetContent extends StatelessWidget {
  const CountryPickingBottomSheetContent({
    super.key,
    required this.onTapCountry,
    required this.pickedCountry,
  });

  final void Function(CountryCode code) onTapCountry;
  final CountryCode pickedCountry;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(
          Radius.circular(
            10,
          ),
        ),
        color: appColors.primary.withOpacity(0.3),
      ),
      height: 400,
      child: Column(
        children: [
          const SizedBox(
            height: 8,
          ),
          const BottomModalSheetHandle(),
          const SizedBox(
            height: 8,
          ),
          Text(
            'Country Code',
            style: GoogleFonts.poppins(
              color: appColors.secondary,
              fontSize: 18,
            ),
          ),
          const SizedBox(
            height: 8,
          ),
          Container(
            decoration: BoxDecoration(
              border: Border.fromBorderSide(
                BorderSide(
                  width: 0.2,
                  color: appColors.secondary,
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: countryCodes.length,
              itemBuilder: (ctx, index) => ListTile(
                selected: pickedCountry.id == countryCodes[index].id,
                selectedColor: CupertinoColors.activeBlue,
                onTap: () => onTapCountry(countryCodes[index]),
                leading: Text(
                  countryCodes[index].code,
                  style: GoogleFonts.poppins(
                    color: pickedCountry == countryCodes[index]
                        ? CupertinoColors.activeBlue
                        : appColors.secondary,
                    fontSize: 16,
                  ),
                ),
                key: ValueKey(countryCodes[index].id),
                title: Text(
                  countryCodes[index].countryName,
                  style: GoogleFonts.poppins(
                    color: pickedCountry == countryCodes[index]
                        ? CupertinoColors.activeBlue
                        : appColors.secondary,
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
