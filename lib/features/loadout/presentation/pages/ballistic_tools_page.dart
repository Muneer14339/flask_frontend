// lib/features/loadout/presentation/pages/ballistic_tools_page.dart
import 'package:dartz/dartz.dart' as rifle;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import 'dart:math';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/ballistic_data.dart';
import '../../domain/entities/rifle.dart';
import '../../domain/entities/ammunition.dart';
import '../bloc/ballistic_bloc.dart';

class BallisticToolsPage extends StatefulWidget {
  final Rifle rifle;
  final Ammunition availableAmmunition; // Changed from List to single Ammunition

  const BallisticToolsPage({
    Key? key,
    required this.rifle,
    required this.availableAmmunition, // Changed from List to single Ammunition
  }) : super(key: key);

  @override
  State<BallisticToolsPage> createState() => _BallisticToolsPageState();
}

class _BallisticToolsPageState extends State<BallisticToolsPage> with TickerProviderStateMixin {
  late TabController _tabController;

  // DOPE Card controllers
  String? _selectedDistance;
  final _elevationController = TextEditingController();

  // Zero Tracker controllers
  String? _selectedZeroDistance;
  final _poiController = TextEditingController();
  String _zeroConfirmed = 'yes';

  // Chronograph controllers
  final _velocitiesController = TextEditingController();

  // Ballistic Calculator controllers
  final _bcController = TextEditingController();
  final _muzzleVelocityController = TextEditingController();
  final _targetDistanceController = TextEditingController();
  final _windController = TextEditingController();
  final _windDirController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);

    // Load ballistic data for this rifle
    context.read<BallisticBloc>().add(LoadBallisticDataEvent(widget.rifle.id));

    // Pre-fill ballistic calculator with ammunition data
    if (widget.availableAmmunition.bullet.bc.g1 != null) {
      _bcController.text = widget.availableAmmunition.bullet.bc.g1!.toString();
    }
    if (widget.availableAmmunition.velocity != null) {
      _muzzleVelocityController.text = widget.availableAmmunition.velocity!.toString();
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _elevationController.dispose();
    _poiController.dispose();
    _velocitiesController.dispose();
    _bcController.dispose();
    _muzzleVelocityController.dispose();
    _targetDistanceController.dispose();
    _windController.dispose();
    _windDirController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Ballistic Tools',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 20,
              ),
            ),
            Text(
              widget.rifle.name,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.normal,
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ),
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: 'DOPE'),
            Tab(text: 'Zero'),
            Tab(text: 'Chrono'),
            Tab(text: 'Calculator'),
          ],
        ),
      ),
      body: BlocBuilder<BallisticBloc, BallisticState>(
        builder: (context, state) {
          return TabBarView(
            controller: _tabController,
            children: [
              _buildDopeCardTab(state),
              _buildZeroTrackerTab(state),
              _buildChronographTab(state),
              _buildBallisticCalculatorTab(state),
            ],
          );
        },
      ),
    );
  }

  Widget _buildDopeCardTab(BallisticState state) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildDopeCardSection(state),
          const SizedBox(height: 20),
          _buildDopeHistorySection(state),
        ],
      ),
    );
  }

  Widget _buildDopeCardSection(BallisticState state) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('📋', style: TextStyle(fontSize: 24)),
              const SizedBox(width: 8),
              const Text(
                'DOPE Card Entry',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Rifle name (non-editable)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.background,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppTheme.borderColor),
            ),
            child: Row(
              children: [
                const Icon(Icons.lock, color: AppTheme.textSecondary, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Rifle: ${widget.rifle.name}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Ammunition (non-editable, locked like rifle)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.background,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppTheme.borderColor),
            ),
            child: Row(
              children: [
                const Icon(Icons.lock, color: AppTheme.textSecondary, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Ammunition: ${widget.availableAmmunition.name}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),
          _buildDropdown(
            label: 'Distance (yd) *',
            value: _selectedDistance,
            items: const ['100', '200', '300', '400', '500', '600', '700', '800', '900', '1000']
                .map((dist) => DropdownMenuItem(value: dist, child: Text(dist)))
                .toList(),
            onChanged: (value) => setState(() => _selectedDistance = value),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _elevationController,
            decoration: const InputDecoration(
              labelText: 'Elevation (MOA/MIL) *',
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              hintText: 'e.g. 2.5 MOA or 0.7 MIL',
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _saveDope,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: const Text('Save DOPE'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDopeHistorySection(BallisticState state) {
    if (state is! BallisticLoaded) {
      return const SizedBox();
    }

    final dopeEntries = state.dopeEntries;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '📄 DOPE History',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppTheme.primary,
            ),
          ),
          const SizedBox(height: 16),
          if (dopeEntries.isEmpty)
            Center(
              child: Column(
                children: [
                  Icon(Icons.note_add, size: 48, color: AppTheme.textSecondary),
                  const SizedBox(height: 8),
                  Text(
                    'No DOPE entries yet',
                    style: TextStyle(color: AppTheme.textSecondary),
                  ),
                ],
              ),
            )
          else
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: const [
                  DataColumn(label: Text('Distance')),
                  DataColumn(label: Text('Ammunition')),
                  DataColumn(label: Text('Elevation')),
                  DataColumn(label: Text('Date')),
                  DataColumn(label: Text('Actions')),
                ],
                rows: dopeEntries.map((entry) {
                  // For history, we need to find ammunition by ID from some source
                  // Since we only have one ammunition now, we'll show it or "Unknown"
                  String ammoName = entry.ammunitionId == widget.availableAmmunition.id
                      ? widget.availableAmmunition.name
                      : 'Unknown';

                  return DataRow(cells: [
                    DataCell(Text('${entry.distance} yd')),
                    DataCell(Text(ammoName)),
                    DataCell(Text(entry.elevation)),
                    DataCell(Text(_formatDate(entry.createdAt))),
                    DataCell(
                      IconButton(
                        icon: const Icon(Icons.delete, color: AppTheme.danger),
                        onPressed: () => _deleteDopeEntry(entry.id),
                      ),
                    ),
                  ]);
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildZeroTrackerTab(BallisticState state) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildZeroTrackerSection(),
          const SizedBox(height: 20),
          _buildZeroHistorySection(state),
        ],
      ),
    );
  }

  Widget _buildZeroTrackerSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('🎯', style: TextStyle(fontSize: 24)),
              const SizedBox(width: 8),
              const Text(
                'Zero Tracker',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Rifle name (non-editable)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.background,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppTheme.borderColor),
            ),
            child: Row(
              children: [
                const Icon(Icons.lock, color: AppTheme.textSecondary, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Rifle: ${widget.rifle.name}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Ammunition (non-editable, locked like rifle)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.background,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppTheme.borderColor),
            ),
            child: Row(
              children: [
                const Icon(Icons.lock, color: AppTheme.textSecondary, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Ammunition: ${widget.availableAmmunition.name}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),
          _buildDropdown(
            label: 'Zeroing Distance (yd) *',
            value: _selectedZeroDistance,
            items: const ['25', '50', '100', '200', '300']
                .map((dist) => DropdownMenuItem(value: dist, child: Text('$dist yd')))
                .toList(),
            onChanged: (value) => setState(() => _selectedZeroDistance = value),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _poiController,
            decoration: const InputDecoration(
              labelText: 'Point of Impact (POI) Offset *',
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              hintText: 'e.g. 2" high, 1" left',
            ),
          ),
          const SizedBox(height: 12),
          _buildDropdown(
            label: 'Confirmed Zero?',
            value: _zeroConfirmed,
            items: const [
              DropdownMenuItem(value: 'yes', child: Text('Yes')),
              DropdownMenuItem(value: 'no', child: Text('No')),
            ],
            onChanged: (value) => setState(() => _zeroConfirmed = value ?? 'yes'),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _logZero,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: const Text('Log Zero'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildZeroHistorySection(BallisticState state) {
    if (state is! BallisticLoaded) {
      return const SizedBox();
    }

    final zeroEntries = state.zeroEntries;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '🎯 Zero History',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppTheme.primary,
            ),
          ),
          const SizedBox(height: 16),
          if (zeroEntries.isEmpty)
            Center(
              child: Column(
                children: [
                  Icon(Icons.gps_fixed, size: 48, color: AppTheme.textSecondary),
                  const SizedBox(height: 8),
                  Text(
                    'No zero entries yet',
                    style: TextStyle(color: AppTheme.textSecondary),
                  ),
                ],
              ),
            )
          else
            ...zeroEntries.map((entry) => Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.background,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: entry.confirmed ? AppTheme.success : AppTheme.warning,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    entry.confirmed ? Icons.check_circle : Icons.warning,
                    color: entry.confirmed ? AppTheme.success : AppTheme.warning,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${entry.distance} yd - ${entry.poiOffset}',
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        Text(
                          '${entry.confirmed ? 'Confirmed' : 'Unconfirmed'} • ${_formatDate(entry.createdAt)}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: AppTheme.danger),
                    onPressed: () => _deleteZeroEntry(entry.id),
                  ),
                ],
              ),
            )),
        ],
      ),
    );
  }

  Widget _buildChronographTab(BallisticState state) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildChronographSection(),
          const SizedBox(height: 20),
          _buildChronographHistorySection(state),
        ],
      ),
    );
  }

  Widget _buildChronographSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('⏱️', style: TextStyle(fontSize: 24)),
              const SizedBox(width: 8),
              const Text(
                'Chronograph Data',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Rifle name (non-editable)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.background,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppTheme.borderColor),
            ),
            child: Row(
              children: [
                const Icon(Icons.lock, color: AppTheme.textSecondary, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Rifle: ${widget.rifle.name}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Ammunition (non-editable, locked like rifle)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.background,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppTheme.borderColor),
            ),
            child: Row(
              children: [
                const Icon(Icons.lock, color: AppTheme.textSecondary, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Ammunition: ${widget.availableAmmunition.name}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),
          TextFormField(
            controller: _velocitiesController,
            decoration: const InputDecoration(
              labelText: 'Enter Velocities (comma separated) *',
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              hintText: 'e.g. 2680, 2685, 2675, 2690, 2678',
            ),
            maxLines: 4,
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _analyzeVelocities,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: const Text('Analyze & Save'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChronographHistorySection(BallisticState state) {
    if (state is! BallisticLoaded) {
      return const SizedBox();
    }

    final chronoData = state.chronographData;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '⏱️ Chronograph History',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppTheme.primary,
            ),
          ),
          const SizedBox(height: 16),
          if (chronoData.isEmpty)
            Center(
              child: Column(
                children: [
                  Icon(Icons.speed, size: 48, color: AppTheme.textSecondary),
                  const SizedBox(height: 8),
                  Text(
                    'No chronograph data yet',
                    style: TextStyle(color: AppTheme.textSecondary),
                  ),
                ],
              ),
            )
          else
            ...chronoData.map((data) {
              // For history, show ammunition name if it matches current one, else "Unknown"
              String ammoName = data.ammunitionId == widget.availableAmmunition.id
                  ? widget.availableAmmunition.name
                  : 'Unknown Ammo';

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.background,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          ammoName,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: AppTheme.danger),
                          onPressed: () => _deleteChronographData(data.id),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard('Avg', '${data.average.toStringAsFixed(1)} fps'),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildStatCard('ES', '${data.extremeSpread.toStringAsFixed(1)} fps'),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildStatCard('SD', '${data.standardDeviation.toStringAsFixed(1)} fps'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Shots: ${data.velocities.length} • ${_formatDate(data.createdAt)}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }

  Widget _buildBallisticCalculatorTab(BallisticState state) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildBallisticCalculatorSection(),
          const SizedBox(height: 20),
          _buildCalculationHistorySection(state),
        ],
      ),
    );
  }

  Widget _buildBallisticCalculatorSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('📐', style: TextStyle(fontSize: 24)),
              const SizedBox(width: 8),
              const Text(
                'Ballistic Calculator',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Rifle name (non-editable)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.background,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppTheme.borderColor),
            ),
            child: Row(
              children: [
                const Icon(Icons.lock, color: AppTheme.textSecondary, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Rifle: ${widget.rifle.name}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Ammunition (non-editable, locked like rifle)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.background,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppTheme.borderColor),
            ),
            child: Row(
              children: [
                const Icon(Icons.lock, color: AppTheme.textSecondary, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Ammunition: ${widget.availableAmmunition.name}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),
          TextFormField(
            controller: _bcController,
            decoration: const InputDecoration(
              labelText: 'Ballistic Coefficient (BC) *',
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              hintText: 'e.g. 0.595',
            ),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _muzzleVelocityController,
            decoration: const InputDecoration(
              labelText: 'Muzzle Velocity (fps) *',
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              hintText: 'e.g. 2680',
            ),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _targetDistanceController,
            decoration: const InputDecoration(
              labelText: 'Target Distance (yd) *',
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              hintText: 'e.g. 600',
            ),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _windController,
                  decoration: const InputDecoration(
                    labelText: 'Wind Speed (mph)',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    hintText: 'e.g. 10',
                  ),
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  controller: _windDirController,
                  decoration: const InputDecoration(
                    labelText: 'Wind Direction (°)',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    hintText: 'e.g. 90',
                  ),
                  keyboardType: TextInputType.number,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _calculateBallistics,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: const Text('Calculate & Save'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalculationHistorySection(BallisticState state) {
    if (state is! BallisticLoaded) {
      return const SizedBox();
    }

    final calculations = state.ballisticCalculations;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '📐 Calculation History',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppTheme.primary,
            ),
          ),
          const SizedBox(height: 16),
          if (calculations.isEmpty)
            Center(
              child: Column(
                children: [
                  Icon(Icons.calculate, size: 48, color: AppTheme.textSecondary),
                  const SizedBox(height: 8),
                  Text(
                    'No calculations yet',
                    style: TextStyle(color: AppTheme.textSecondary),
                  ),
                ],
              ),
            )
          else
            ...calculations.map((calc) => Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.background,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'BC: ${calc.ballisticCoefficient} • ${calc.muzzleVelocity.toInt()} fps',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: AppTheme.danger),
                        onPressed: () => _deleteBallisticCalculation(calc.id),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Range: ${calc.targetDistance} yd • Wind: ${calc.windSpeed} mph at ${calc.windDirection}°',
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  Text(
                    '${_formatDate(calc.createdAt)}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildTrajectoryTable(calc.trajectoryData),
                ],
              ),
            )),
        ],
      ),
    );
  }

  Widget _buildTrajectoryTable(List<BallisticPoint> data) {
    if (data.isEmpty) return const SizedBox();

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columnSpacing: 20,
        dataRowMinHeight: 32,
        headingRowHeight: 40,
        columns: const [
          DataColumn(label: Text('Range')),
          DataColumn(label: Text('Drop')),
          DataColumn(label: Text('Drift')),
          DataColumn(label: Text('Velocity')),
        ],
        rows: data.take(5).map((point) => DataRow(cells: [
          DataCell(Text('${point.range} yd')),
          DataCell(Text('${point.drop.toStringAsFixed(1)}"')),
          DataCell(Text('${point.windDrift.toStringAsFixed(1)}"')),
          DataCell(Text('${point.velocity.toInt()} fps')),
        ])).toList(),
      ),
    );
  }

  Widget _buildDropdown<T>({
    required String label,
    required T? value,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 6),
        DropdownButtonFormField<T>(
          value: value,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
          isExpanded: true,
          items: items,
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildStatCard(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppTheme.primaryLight.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppTheme.primary,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date).inDays;

    if (diff == 0) return 'Today';
    if (diff == 1) return 'Yesterday';
    if (diff < 7) return '$diff days ago';
    return '${date.day}/${date.month}/${date.year}';
  }

  void _saveDope() {
    if (_selectedDistance == null || _elevationController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in all required fields'),
          backgroundColor: AppTheme.accent,
        ),
      );
      return;
    }

    final entry = DopeEntry(
      id: const Uuid().v4(),
      rifleId: widget.rifle.id,
      ammunitionId: widget.availableAmmunition.id, // Use single ammunition ID
      distance: int.parse(_selectedDistance!),
      elevation: _elevationController.text,
      windage: '0', // Default windage
      createdAt: DateTime.now(),
    );

    context.read<BallisticBloc>().add(SaveDopeEntryEvent(entry));

    // Clear form
    _elevationController.clear();
    setState(() {
      _selectedDistance = null;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('DOPE entry saved successfully!'),
        backgroundColor: AppTheme.success,
      ),
    );
  }

  void _logZero() {
    if (_selectedZeroDistance == null || _poiController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in all required fields'),
          backgroundColor: AppTheme.accent,
        ),
      );
      return;
    }

    final entry = ZeroEntry(
      id: const Uuid().v4(),
      rifleId: widget.rifle.id,
      distance: int.parse(_selectedZeroDistance!),
      poiOffset: _poiController.text,
      confirmed: _zeroConfirmed == 'yes',
      createdAt: DateTime.now(),
    );

    context.read<BallisticBloc>().add(SaveZeroEntryEvent(entry));

    // Clear form
    _poiController.clear();
    setState(() {
      _selectedZeroDistance = null;
      _zeroConfirmed = 'yes';
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Zero entry logged successfully!'),
        backgroundColor: AppTheme.success,
      ),
    );
  }

  void _analyzeVelocities() {
    if (_velocitiesController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in all required fields'),
          backgroundColor: AppTheme.accent,
        ),
      );
      return;
    }

    final velocities = _velocitiesController.text
        .split(',')
        .map((v) => double.tryParse(v.trim()))
        .where((v) => v != null)
        .cast<double>()
        .toList();

    if (velocities.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invalid velocity data. Please enter comma-separated numbers.'),
          backgroundColor: AppTheme.accent,
        ),
      );
      return;
    }

    final avg = velocities.reduce((a, b) => a + b) / velocities.length;
    final es = velocities.reduce((a, b) => a > b ? a : b) - velocities.reduce((a, b) => a < b ? a : b);
    final variance = velocities.map((v) => (v - avg) * (v - avg)).reduce((a, b) => a + b) / velocities.length;
    final sd = sqrt(variance);

    final data = ChronographData(
      id: const Uuid().v4(),
      rifleId: widget.rifle.id,
      ammunitionId: widget.availableAmmunition.id, // Use single ammunition ID
      velocities: velocities,
      average: avg,
      extremeSpread: es,
      standardDeviation: sd,
      createdAt: DateTime.now(),
    );

    context.read<BallisticBloc>().add(SaveChronographDataEvent(data));

    // Clear form
    _velocitiesController.clear();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Chronograph data saved! Avg: ${avg.toStringAsFixed(1)} fps, ES: ${es.toStringAsFixed(1)}, SD: ${sd.toStringAsFixed(1)}'),
        backgroundColor: AppTheme.success,
      ),
    );
  }

  void _calculateBallistics() {
    final bc = double.tryParse(_bcController.text);
    final velocity = double.tryParse(_muzzleVelocityController.text);
    final distance = int.tryParse(_targetDistanceController.text);
    final wind = double.tryParse(_windController.text) ?? 0;
    final windDir = double.tryParse(_windDirController.text) ?? 90;

    if (bc == null || velocity == null || distance == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter valid numbers for BC, velocity, and distance.'),
          backgroundColor: AppTheme.accent,
        ),
      );
      return;
    }

    context.read<BallisticBloc>().add(CalculateBallisticsEvent(
      rifleId: widget.rifle.id,
      ammunitionId: widget.availableAmmunition.id, // Use single ammunition ID
      ballisticCoefficient: bc,
      muzzleVelocity: velocity,
      targetDistance: distance,
      windSpeed: wind,
      windDirection: windDir,
    ));

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Ballistic calculation completed and saved!'),
        backgroundColor: AppTheme.success,
      ),
    );
  }

  void _deleteDopeEntry(String entryId) {
    context.read<BallisticBloc>().add(DeleteDopeEntryEvent(entryId));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('DOPE entry deleted'),
        backgroundColor: AppTheme.success,
      ),
    );
  }

  void _deleteZeroEntry(String entryId) {
    context.read<BallisticBloc>().add(DeleteZeroEntryEvent(entryId));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Zero entry deleted'),
        backgroundColor: AppTheme.success,
      ),
    );
  }

  void _deleteChronographData(String dataId) {
    context.read<BallisticBloc>().add(DeleteChronographDataEvent(dataId));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Chronograph data deleted'),
        backgroundColor: AppTheme.success,
      ),
    );
  }

  void _deleteBallisticCalculation(String calculationId) {
    context.read<BallisticBloc>().add(DeleteBallisticCalculationEvent(calculationId));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Calculation deleted'),
        backgroundColor: AppTheme.success,
      ),
    );
  }
}