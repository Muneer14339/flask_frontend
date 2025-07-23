// // lib/core/widgets/unified_add_entry_dialog.dart
// import 'package:flutter/material.dart';
// import 'package:uuid/uuid.dart';
//
// import '../../../../core/theme/app_theme.dart';
// import '../../data/models/csv_ammunition_model.dart';
// import '../../data/models/csv_rifle_model.dart';
// import '../../data/repositories/csv_repository.dart';
//
// enum AddEntryType { rifle, manufacturer, model, caliber, ammunition, ammoManufacturer, ammoCaliber }
//
// class AddEntryContext {
//   final AddEntryType type;
//   final String? rifleName;
//   final String? manufacturer;
//   final String? model;
//   final String? ammunitionName;
//   final String? ammoManufacturer;
//
//   const AddEntryContext({
//     required this.type,
//     this.rifleName,
//     this.manufacturer,
//     this.model,
//     this.ammunitionName,
//     this.ammoManufacturer,
//   });
// }
//
// class UnifiedAddEntryDialog extends StatefulWidget {
//   final AddEntryContext context;
//   final VoidCallback onSuccess;
//
//   const UnifiedAddEntryDialog({
//     Key? key,
//     required this.context,
//     required this.onSuccess,
//   }) : super(key: key);
//
//   @override
//   State<UnifiedAddEntryDialog> createState() => _UnifiedAddEntryDialogState();
// }
//
// class _UnifiedAddEntryDialogState extends State<UnifiedAddEntryDialog> {
//   final _formKey = GlobalKey<FormState>();
//   late CSVRepository _csvRepository;
//
//   // Controllers for all possible fields
//   final _rifleNameController = TextEditingController();
//   final _manufacturerController = TextEditingController();
//   final _modelController = TextEditingController();
//   final _caliberController = TextEditingController();
//   final _notesController = TextEditingController();
//
//   // For ammunition
//   final _ammoNameController = TextEditingController();
//   final _ammoManufacturerController = TextEditingController();
//   final _ammoCaliberController = TextEditingController();
//
//   bool _isLoading = false;
//
//   @override
//   void initState() {
//     super.initState();
//     _csvRepository = CSVRepositoryImpl();
//     _initializeFields();
//   }
//
//   @override
//   void dispose() {
//     _rifleNameController.dispose();
//     _manufacturerController.dispose();
//     _modelController.dispose();
//     _caliberController.dispose();
//     _notesController.dispose();
//     _ammoNameController.dispose();
//     _ammoManufacturerController.dispose();
//     _ammoCaliberController.dispose();
//     super.dispose();
//   }
//
//   void _initializeFields() {
//     // Pre-fill fields based on context (non-editable fields)
//     switch (widget.context.type) {
//       case AddEntryType.rifle:
//       // All fields editable for new rifle
//         break;
//       case AddEntryType.manufacturer:
//         _rifleNameController.text = widget.context.rifleName ?? '';
//         break;
//       case AddEntryType.model:
//         _rifleNameController.text = widget.context.rifleName ?? '';
//         _manufacturerController.text = widget.context.manufacturer ?? '';
//         break;
//       case AddEntryType.caliber:
//         _rifleNameController.text = widget.context.rifleName ?? '';
//         _manufacturerController.text = widget.context.manufacturer ?? '';
//         _modelController.text = widget.context.model ?? '';
//         break;
//       case AddEntryType.ammunition:
//       // All fields editable for new ammunition
//         break;
//       case AddEntryType.ammoManufacturer:
//         _ammoNameController.text = widget.context.ammunitionName ?? '';
//         break;
//       case AddEntryType.ammoCaliber:
//         _ammoNameController.text = widget.context.ammunitionName ?? '';
//         _ammoManufacturerController.text = widget.context.ammoManufacturer ?? '';
//         break;
//     }
//   }
//
//   String _getDialogTitle() {
//     switch (widget.context.type) {
//       case AddEntryType.rifle:
//         return 'Add New Rifle';
//       case AddEntryType.manufacturer:
//         return 'Add New Manufacturer';
//       case AddEntryType.model:
//         return 'Add New Model';
//       case AddEntryType.caliber:
//         return 'Add New Caliber';
//       case AddEntryType.ammunition:
//         return 'Add New Ammunition';
//       case AddEntryType.ammoManufacturer:
//         return 'Add New Manufacturer';
//       case AddEntryType.ammoCaliber:
//         return 'Add New Caliber';
//     }
//   }
//
//   bool _isFieldEditable(String fieldName) {
//     switch (widget.context.type) {
//       case AddEntryType.rifle:
//         return true; // All fields editable
//       case AddEntryType.manufacturer:
//         return fieldName != 'rifleName'; // Rifle name locked, others editable
//       case AddEntryType.model:
//         return !['rifleName', 'manufacturer'].contains(fieldName);
//       case AddEntryType.caliber:
//         return !['rifleName', 'manufacturer', 'model'].contains(fieldName);
//       case AddEntryType.ammunition:
//         return true; // All fields editable
//       case AddEntryType.ammoManufacturer:
//         return fieldName != 'ammunitionName';
//       case AddEntryType.ammoCaliber:
//         return !['ammunitionName', 'manufacturer'].contains(fieldName);
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final isRifleType = [AddEntryType.rifle, AddEntryType.manufacturer, AddEntryType.model, AddEntryType.caliber]
//         .contains(widget.context.type);
//
//     return Dialog(
//       insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
//       child: ConstrainedBox(
//         constraints: BoxConstraints(
//           maxHeight: MediaQuery.of(context).size.height * 0.8,
//           maxWidth: MediaQuery.of(context).size.width * 0.9,
//         ),
//         child: Column(
//           children: [
//             // Header
//             Container(
//               padding: const EdgeInsets.all(20),
//               decoration: const BoxDecoration(
//                 color: AppTheme.primary,
//                 borderRadius: BorderRadius.only(
//                   topLeft: Radius.circular(10),
//                   topRight: Radius.circular(10),
//                 ),
//               ),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Text(
//                     _getDialogTitle(),
//                     style: const TextStyle(
//                       color: Colors.white,
//                       fontSize: 18,
//                       fontWeight: FontWeight.w600,
//                     ),
//                   ),
//                   IconButton(
//                     icon: const Icon(Icons.close, color: Colors.white),
//                     onPressed: () => Navigator.of(context).pop(),
//                   ),
//                 ],
//               ),
//             ),
//
//             // Content
//             Expanded(
//               child: SingleChildScrollView(
//                 padding: const EdgeInsets.all(20),
//                 child: Form(
//                   key: _formKey,
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         'Enter ${_getDialogTitle().split(' ').last} Details',
//                         style: const TextStyle(
//                           fontSize: 16,
//                           fontWeight: FontWeight.w600,
//                           color: AppTheme.primary,
//                         ),
//                       ),
//                       const SizedBox(height: 16),
//
//                       if (isRifleType) ...[
//                         // Rifle fields
//                         _buildTextField(
//                           controller: _rifleNameController,
//                           label: 'Rifle Name *',
//                           hint: 'Enter rifle name',
//                           fieldName: 'rifleName',
//                         ),
//                         const SizedBox(height: 16),
//                         _buildTextField(
//                           controller: _manufacturerController,
//                           label: 'Manufacturer *',
//                           hint: 'Enter manufacturer name',
//                           fieldName: 'manufacturer',
//                         ),
//                         const SizedBox(height: 16),
//                         _buildTextField(
//                           controller: _modelController,
//                           label: 'Model *',
//                           hint: 'Enter model name',
//                           fieldName: 'model',
//                         ),
//                         const SizedBox(height: 16),
//                         _buildTextField(
//                           controller: _caliberController,
//                           label: 'Caliber *',
//                           hint: 'e.g., 6.5 Creedmoor',
//                           fieldName: 'caliber',
//                         ),
//                         const SizedBox(height: 16),
//                         _buildTextField(
//                           controller: _notesController,
//                           label: 'Notes *',
//                           hint: 'Additional details about this rifle',
//                           fieldName: 'notes',
//                           maxLines: 2,
//                         ),
//                       ] else ...[
//                         // Ammunition fields
//                         _buildTextField(
//                           controller: _ammoNameController,
//                           label: 'Ammunition Name *',
//                           hint: 'Enter ammunition name',
//                           fieldName: 'ammunitionName',
//                         ),
//                         const SizedBox(height: 16),
//                         _buildTextField(
//                           controller: _ammoManufacturerController,
//                           label: 'Manufacturer *',
//                           hint: 'Enter manufacturer name',
//                           fieldName: 'manufacturer',
//                         ),
//                         const SizedBox(height: 16),
//                         _buildTextField(
//                           controller: _ammoCaliberController,
//                           label: 'Caliber *',
//                           hint: 'e.g., 6.5 Creedmoor',
//                           fieldName: 'caliber',
//                         ),
//                       ],
//
//                       const SizedBox(height: 16),
//
//                       // Info box showing what will be added
//                       Container(
//                         padding: const EdgeInsets.all(12),
//                         decoration: BoxDecoration(
//                           color: AppTheme.primary.withOpacity(0.1),
//                           borderRadius: BorderRadius.circular(8),
//                           border: Border.all(color: AppTheme.primary.withOpacity(0.3)),
//                         ),
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text(
//                               'This will add a new entry to the database:',
//                               style: const TextStyle(
//                                 fontSize: 12,
//                                 fontWeight: FontWeight.w600,
//                                 color: AppTheme.primary,
//                               ),
//                             ),
//                             const SizedBox(height: 4),
//                             Text(
//                               _getPreviewText(),
//                               style: const TextStyle(
//                                 fontSize: 11,
//                                 color: AppTheme.textSecondary,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//
//             // Bottom buttons
//             Container(
//               padding: const EdgeInsets.all(20),
//               decoration: BoxDecoration(
//                 border: Border(top: BorderSide(color: AppTheme.borderColor)),
//               ),
//               child: Row(
//                 children: [
//                   Expanded(
//                     child: OutlinedButton(
//                       onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
//                       child: const Text('Cancel'),
//                     ),
//                   ),
//                   const SizedBox(width: 12),
//                   Expanded(
//                     child: ElevatedButton(
//                       onPressed: _isLoading ? null : _submitForm,
//                       child: _isLoading
//                           ? const SizedBox(
//                         height: 16,
//                         width: 16,
//                         child: CircularProgressIndicator(strokeWidth: 2),
//                       )
//                           : const Text('Add'),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildTextField({
//     required TextEditingController controller,
//     required String label,
//     required String hint,
//     required String fieldName,
//     int maxLines = 1,
//   }) {
//     final isEditable = _isFieldEditable(fieldName);
//
//     return TextFormField(
//       controller: controller,
//       decoration: InputDecoration(
//         labelText: label,
//         hintText: hint,
//         border: const OutlineInputBorder(),
//         fillColor: isEditable ? null : Colors.grey.shade100,
//         filled: !isEditable,
//         prefixIcon: !isEditable ? const Icon(Icons.lock, size: 16) : null,
//       ),
//       maxLines: maxLines,
//       readOnly: !isEditable,
//       validator: (value) {
//         if (isEditable && (value == null || value.isEmpty)) {
//           return 'This field is required';
//         }
//         return null;
//       },
//     );
//   }
//
//   String _getPreviewText() {
//     switch (widget.context.type) {
//       case AddEntryType.rifle:
//         return 'New rifle entry with all details';
//       case AddEntryType.manufacturer:
//         return 'New manufacturer for "${widget.context.rifleName}"';
//       case AddEntryType.model:
//         return 'New model for "${widget.context.rifleName}" by "${widget.context.manufacturer}"';
//       case AddEntryType.caliber:
//         return 'New caliber for "${widget.context.rifleName}" ${widget.context.manufacturer} ${widget.context.model}';
//       case AddEntryType.ammunition:
//         return 'New ammunition entry with all details';
//       case AddEntryType.ammoManufacturer:
//         return 'New manufacturer for "${widget.context.ammunitionName}"';
//       case AddEntryType.ammoCaliber:
//         return 'New caliber for "${widget.context.ammunitionName}" by "${widget.context.ammoManufacturer}"';
//     }
//   }
//
//   void _submitForm() async {
//     if (!_formKey.currentState!.validate()) return;
//
//     setState(() {
//       _isLoading = true;
//     });
//
//     try {
//       final isRifleType = [AddEntryType.rifle, AddEntryType.manufacturer, AddEntryType.model, AddEntryType.caliber]
//           .contains(widget.context.type);
//
//       if (isRifleType) {
//         // Add rifle entry
//         await _csvRepository.addRifle(CSVRifleModel(
//           rifleName: _rifleNameController.text,
//           manufacturer: _manufacturerController.text,
//           model: _modelController.text,
//           caliber: _caliberController.text,
//           notes: _notesController.text,
//         ));
//       } else {
//         // Add ammunition entry
//         await _csvRepository.addAmmunition(CSVAmmunitionModel(
//           ammunitionName: _ammoNameController.text,
//           manufacturer: _ammoManufacturerController.text,
//           caliber: _ammoCaliberController.text,
//         ));
//       }
//
//       if (mounted) {
//         Navigator.of(context).pop();
//         widget.onSuccess();
//
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('${_getDialogTitle()} added successfully!'),
//             backgroundColor: AppTheme.success,
//           ),
//         );
//       }
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('Failed to add entry: $e'),
//             backgroundColor: AppTheme.danger,
//           ),
//         );
//       }
//     } finally {
//       if (mounted) {
//         setState(() {
//           _isLoading = false;
//         });
//       }
//     }
//   }
// }