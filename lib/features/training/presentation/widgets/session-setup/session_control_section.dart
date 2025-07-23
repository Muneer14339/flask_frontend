// lib/features/training/presentation/widgets/session_control_section.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/theme/app_theme.dart';
import '../../../domain/entities/session-setup/session_information.dart';
import '../../bloc/training_bloc.dart';
import '../../bloc/training_event.dart';

class SessionInformationSection extends StatefulWidget {
  final SessionInformation sessionInformation;
  final bool isCompleted;

  const SessionInformationSection({
    Key? key,
    required this.sessionInformation,
    required this.isCompleted,
  }) : super(key: key);

  @override
  State<SessionInformationSection> createState() => _SessionInformationSectionState();
}

class _SessionInformationSectionState extends State<SessionInformationSection> {
  late TextEditingController _sessionNameController;
  late TextEditingController _distanceController;

  String selectedSessionType = '';
  String selectedShootingPosition = '';
  DateTime selectedDate = DateTime.now();
  TimeOfDay selectedTime = TimeOfDay.now();

  @override
  void initState() {
    super.initState();

    // Initialize controllers with current values
    _sessionNameController = TextEditingController(
        text: widget.sessionInformation.sessionName ?? ''
    );
    _distanceController = TextEditingController(
        text: widget.sessionInformation.distance ?? ''
    );

    // Initialize dropdown values
    selectedSessionType = widget.sessionInformation.sessionType ?? '';
    selectedShootingPosition = widget.sessionInformation.shootingPosition ?? '';
    selectedDate = widget.sessionInformation.date ?? DateTime.now();
    selectedTime = widget.sessionInformation.time ?? TimeOfDay.now();
  }

  @override
  void didUpdateWidget(SessionInformationSection oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Update controllers if session information changed
    if (widget.sessionInformation != oldWidget.sessionInformation) {
      _sessionNameController.text = widget.sessionInformation.sessionName ?? '';
      _distanceController.text = widget.sessionInformation.distance ?? '';
      selectedSessionType = widget.sessionInformation.sessionType ?? '';
      selectedShootingPosition = widget.sessionInformation.shootingPosition ?? '';
      selectedDate = widget.sessionInformation.date ?? DateTime.now();
      selectedTime = widget.sessionInformation.time ?? TimeOfDay.now();
    }
  }

  @override
  Widget build(BuildContext context) {
    return _buildSection(
      title: '📋 Session Information',
      sectionNumber: 3,
      isCompleted: widget.isCompleted,
      child: Column(
        children: [
          _buildFormField(
            'Session Name*',
            _sessionNameController,
            'e.g., Morning Practice',
            onChanged: (value) {
              context.read<TrainingBloc>().add(UpdateSessionNameEvent(sessionName: value));
            },
          ),
          const SizedBox(height: 12),
          _buildDropdownField(
            'Session Type*',
            selectedSessionType,
            [
              {'value': 'dry-fire', 'label': 'Dry Fire Training'},
              {'value': 'live-fire', 'label': 'Live Fire Practice'},
              {'value': 'competition', 'label': 'Competition Prep'},
              {'value': 'zeroing', 'label': 'Scope Zeroing'},
              {'value': 'custom', 'label': 'Custom'},
            ],
                (value) {
              setState(() => selectedSessionType = value!);
              context.read<TrainingBloc>().add(UpdateSessionTypeEvent(sessionType: value!));
            },
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildDateField('Date', selectedDate, () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: selectedDate,
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );
                  if (picked != null) {
                    setState(() => selectedDate = picked);
                    context.read<TrainingBloc>().add(UpdateSessionDateEvent(date: picked));
                  }
                }),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildTimeField('Start Time', selectedTime, () async {
                  final picked = await showTimePicker(
                    context: context,
                    initialTime: selectedTime,
                  );
                  if (picked != null) {
                    setState(() => selectedTime = picked);
                    context.read<TrainingBloc>().add(UpdateSessionTimeEvent(time: picked));
                  }
                }),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildDropdownField(
            'Shooting Position*',
            selectedShootingPosition,
            [
              {'value': 'benchrest', 'label': 'Benchrest'},
              {'value': 'prone', 'label': 'Prone'},
              {'value': 'kneeling', 'label': 'Kneeling'},
              {'value': 'standing', 'label': 'Standing'},
              {'value': 'field', 'label': 'Field/Offhand'},
              {'value': 'other', 'label': 'Other'},
            ],
                (value) {
              setState(() => selectedShootingPosition = value!);
              context.read<TrainingBloc>().add(UpdateShootingPositionEvent(shootingPosition: value!));
            },
          ),
          const SizedBox(height: 12),
          _buildFormField(
            'Distance (yards)*',
            _distanceController,
            'e.g., 100',
            keyboardType: TextInputType.number,
            onChanged: (value) {
              context.read<TrainingBloc>().add(UpdateDistanceEvent(distance: value));
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required int sectionNumber,
    required bool isCompleted,
    required Widget child
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                  title,
                  style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600
                  )
              ),
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isCompleted ? AppTheme.success : AppTheme.borderColor,
                ),
                child: isCompleted
                    ? const Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 16
                )
                    : Text(
                  '$sectionNumber',
                  style: const TextStyle(
                      fontSize: 12,
                      color: Colors.white,
                      fontWeight: FontWeight.w600
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _buildFormField(
      String label,
      TextEditingController controller,
      String hint,
      {
        TextInputType keyboardType = TextInputType.text,
        Function(String)? onChanged,
      }
      ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          onChanged: onChanged,
          decoration: InputDecoration(
            hintText: hint,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField(
      String label,
      String value,
      List<Map<String, String>> items,
      Function(String?) onChanged
      ) {
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

  Widget _buildDateField(String label, DateTime value, VoidCallback onTap) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label),
        const SizedBox(height: 6),
        InkWell(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            decoration: BoxDecoration(
              border: Border.all(color: AppTheme.borderColor),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text('${value.toLocal()}'.split(' ')[0]),
          ),
        ),
      ],
    );
  }

  Widget _buildTimeField(String label, TimeOfDay value, VoidCallback onTap) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label),
        const SizedBox(height: 6),
        InkWell(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            decoration: BoxDecoration(
              border: Border.all(color: AppTheme.borderColor),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(value.format(context)),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _sessionNameController.dispose();
    _distanceController.dispose();
    super.dispose();
  }
}