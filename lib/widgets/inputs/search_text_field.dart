import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_insta/classes/app_colors.dart';
import 'package:google_fonts/google_fonts.dart';

class SearchTextField extends StatefulWidget {
  const SearchTextField({
    super.key,
    this.onChanged,
  });

  final void Function(String)? onChanged;

  @override
  State<SearchTextField> createState() => _SearchTextFieldState();
}

class _SearchTextFieldState extends State<SearchTextField> {
  final FocusNode _textFieldFocusNode = FocusNode();
  bool _isTextFieldExpanded = false;

  @override
  void initState() {
    super.initState();

    _textFieldFocusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    _textFieldFocusNode.removeListener(_onFocusChange);

    super.dispose();
  }

  void _onFocusChange() {
    setState(() {
      _isTextFieldExpanded = !_isTextFieldExpanded;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      child: FractionallySizedBox(
        widthFactor: 0.9,
        child: SizedBox(
          height: 40,
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  focusNode: _textFieldFocusNode,
                  onChanged: widget.onChanged,
                  cursorColor: appColors.secondary,
                  decoration: InputDecoration(
                    hintText: 'Search',
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 15,
                    ),
                    filled: true,
                    fillColor: appColors.secondary.withOpacity(
                      0.1,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(
                        width: 0,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(
                        width: 0,
                      ),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(
                        width: 0,
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5),
                child: AnimatedOpacity(
                  opacity: _isTextFieldExpanded ? 1 : 0,
                  duration: const Duration(milliseconds: 200),
                  child: AnimatedContainer(
                    width: _isTextFieldExpanded ? 50 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: CupertinoButton(
                      padding: const EdgeInsets.all(0),
                      child: Text(
                        "cancel",
                        maxLines: 1,
                        style: GoogleFonts.poppins(
                          color: appColors.accent,
                          fontSize: 14,
                        ),
                      ),
                      onPressed: () =>
                          FocusScope.of(context).requestFocus(FocusNode()),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
