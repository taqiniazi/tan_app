import 'package:csc_picker_plus/csc_picker_plus.dart';
import 'package:flutter/material.dart';
import 'package:tan_network/theme/app_theme.dart';

class CustomLocationPicker extends StatefulWidget {
  final Function(String) onCountrySelected;
  final Function(String?) onStateSelected;
  final Function(String?) onCitySelected;

  const CustomLocationPicker({
    super.key,
    required this.onCountrySelected,
    required this.onStateSelected,
    required this.onCitySelected,
  });

  @override
  State<CustomLocationPicker> createState() => _CustomLocationPickerState();
}

class _CustomLocationPickerState extends State<CustomLocationPicker> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: CSCPickerPlus(
        ///Show Flag
        flagState: CountryFlag.ENABLE,

        ///Dropdown box decoration
        dropdownDecoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: AppColors.card,
            border: Border.all(color: AppColors.primary.withValues(alpha: 0.5), width: 1.5),
        ),

        ///Disabled Dropdown box decoration
        disabledDropdownDecoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: AppColors.card.withValues(alpha: 0.5),
            border: Border.all(color: Colors.white.withValues(alpha: 0.05), width: 1)),

        ///Layout
        layout: Layout.vertical,

        ///placeholders for dropdown search field
        countrySearchPlaceholder: "Select Country",
        stateSearchPlaceholder: "Select State",
        citySearchPlaceholder: "Select City",

        ///labels for dropdown
        countryDropdownLabel: "Country",
        stateDropdownLabel: "State",
        cityDropdownLabel: "City",

        ///Selected item style [OPTIONAL PARAMETER]
        selectedItemStyle: const TextStyle(
          color: AppColors.textPrimary,
          fontSize: 14,
        ),

        ///Dropdown [OPTIONAL PARAMETER]
        dropdownHeadingStyle: const TextStyle(
            color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.bold),

        ///Dropdown [OPTIONAL PARAMETER]
        dropdownItemStyle: const TextStyle(
          color: AppColors.textPrimary,
          fontSize: 14,
        ),

        ///Dialog box [OPTIONAL PARAMETER]
        dropdownDialogRadius: 20.0,

        ///Search bar [OPTIONAL PARAMETER]
        searchBarRadius: 10.0,

        ///triggers once country selected in dropdown
        onCountryChanged: (value) {
          widget.onCountrySelected(value);
        },

        ///triggers once state selected in dropdown
        onStateChanged: (value) {
          widget.onStateSelected(value);
        },

        ///triggers once city selected in dropdown
        onCityChanged: (value) {
          widget.onCitySelected(value);
        },
      ),
    );
  }
}
