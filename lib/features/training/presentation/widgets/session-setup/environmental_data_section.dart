// lib/features/training/presentation/widgets/environmental_data_section.dart
import 'package:flutter/material.dart';
import '../../../../../core/theme/app_theme.dart';

class EnvironmentalDataSection extends StatefulWidget {
  const EnvironmentalDataSection({Key? key}) : super(key: key);

  @override
  State<EnvironmentalDataSection> createState() => _EnvironmentalDataSectionState();
}

class _EnvironmentalDataSectionState extends State<EnvironmentalDataSection> {
  String selectedWeather = '';
  final _temperatureController = TextEditingController();
  final _windSpeedController = TextEditingController();
  final _humidityController = TextEditingController();

  // ✅ NEW: Check if section is completed (optional section, so always true)
  bool get isCompleted => true; // Environmental data is optional

  @override
  Widget build(BuildContext context) {
    return _buildSection(
      title: '🌤️ Environmental Data',
      sectionNumber: 4,
      isCompleted: isCompleted,
      isOptional: true, // ✅ NEW: Mark as optional
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildDropdownField(
                  'Weather Conditions',
                  selectedWeather,
                  [
                    {'value': '', 'label': 'Select'},
                    {'value': 'clear', 'label': 'Clear'},
                    {'value': 'cloudy', 'label': 'Cloudy'},
                    {'value': 'rainy', 'label': 'Rainy'},
                    {'value': 'windy', 'label': 'Windy'},
                    {'value': 'foggy', 'label': 'Foggy'},
                    {'value': 'snowy', 'label': 'Snowy'},
                  ],
                      (value) => setState(() => selectedWeather = value!),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildFormField(
                  'Temperature (°F)',
                  _temperatureController,
                  'e.g. 72',
                  TextInputType.number,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildFormField(
                  'Wind Speed (mph)',
                  _windSpeedController,
                  'e.g. 5',
                  TextInputType.number,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildFormField(
                  'Humidity (%)',
                  _humidityController,
                  'e.g. 45',
                  TextInputType.number,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required int sectionNumber,
    required bool isCompleted,
    required Widget child,
    bool isOptional = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          initiallyExpanded: false, // ❗ collapsed by default
          title: Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (isOptional) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppTheme.textSecondary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'Optional',
                          style: TextStyle(
                            fontSize: 10,
                            color: AppTheme.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isCompleted ? AppTheme.success : AppTheme.borderColor,
                ),
                child: isCompleted
                    ? const Icon(Icons.check, color: Colors.white, size: 16)
                    : Center(
                  child: Text(
                    '$sectionNumber',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
          children: [child],
        ),
      ),
    );
  }


  Widget _buildFormField(String label, TextEditingController controller, String hint, TextInputType type) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: type,
          decoration: InputDecoration(
            hintText: hint,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField(String label, String value, List<Map<String, String>> items, Function(String?) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          value: value.isEmpty ? null : value,
          onChanged: onChanged,
          items: items.map((item) {
            return DropdownMenuItem<String>(
              value: item['value'],
              child: Text(item['label']!),
            );
          }).toList(),
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _temperatureController.dispose();
    _windSpeedController.dispose();
    _humidityController.dispose();
    super.dispose();
  }
}