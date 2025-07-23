// lib/features/loadout/presentation/pages/ballistic_data_view_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/ballistic_data.dart';
import '../../domain/entities/rifle.dart';
import '../../domain/entities/ammunition.dart';
import '../bloc/ballistic_bloc.dart';

class BallisticDataViewPage extends StatefulWidget {
  final Rifle rifle;
  final Ammunition ammunition;

  const BallisticDataViewPage({
    Key? key,
    required this.rifle,
    required this.ammunition,
  }) : super(key: key);

  @override
  State<BallisticDataViewPage> createState() => _BallisticDataViewPageState();
}

class _BallisticDataViewPageState extends State<BallisticDataViewPage> {
  @override
  void initState() {
    super.initState();
    // Load ballistic data for this rifle
    context.read<BallisticBloc>().add(LoadBallisticDataEvent(widget.rifle.id));
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
              'Ballistic Data',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 20,
              ),
            ),
            Text(
              '${widget.rifle.name} • ${widget.ammunition.name}',
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
      ),
      body: BlocBuilder<BallisticBloc, BallisticState>(
        builder: (context, state) {
          if (state is BallisticLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (state is BallisticError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: AppTheme.danger,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error: ${state.message}',
                    style: const TextStyle(fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<BallisticBloc>().add(
                        LoadBallisticDataEvent(widget.rifle.id),
                      );
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (state is BallisticLoaded) {
            // Check if any data exists
            if (state.dopeEntries.isEmpty &&
                state.zeroEntries.isEmpty &&
                state.chronographData.isEmpty &&
                state.ballisticCalculations.isEmpty) {
              return _buildNoDataView();
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header with Gun + Ammo info
                  _buildHeaderCard(),
                  const SizedBox(height: 20),

                  // DOPE Card Data
                  _buildDopeDataSection(state.dopeEntries),
                  const SizedBox(height: 20),

                  // Zero Data
                  _buildZeroDataSection(state.zeroEntries),
                  const SizedBox(height: 20),

                  // Chronograph Data
                  _buildChronographDataSection(state.chronographData),
                  const SizedBox(height: 20),

                  // Ballistic Calculations
                  _buildCalculationsDataSection(state.ballisticCalculations),
                ],
              ),
            );
          }

          return const Center(child: Text('Unknown state'));
        },
      ),
    );
  }

  Widget _buildNoDataView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.data_usage_outlined,
            size: 80,
            color: AppTheme.textSecondary,
          ),
          const SizedBox(height: 24),
          Text(
            'No Ballistic Data Found',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'No ballistic data has been recorded for this rifle and ammunition combination yet.',
            style: const TextStyle(
              fontSize: 16,
              color: AppTheme.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.of(context).pop();
            },
            icon: const Icon(Icons.arrow_back),
            label: const Text('Go Back'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.primary,
            AppTheme.primary.withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('🎯', style: TextStyle(fontSize: 28)),
              const SizedBox(width: 12),
              const Text(
                'Ballistic Profile',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildInfoRow('Rifle', widget.rifle.name),
          _buildInfoRow('Manufacturer', '${widget.rifle.manufacturer} ${widget.rifle.model}'),
          _buildInfoRow('Caliber', widget.rifle.caliber),
          const Divider(color: Colors.white24, height: 24),
          _buildInfoRow('Ammunition', widget.ammunition.name),
          _buildInfoRow('Manufacturer', widget.ammunition.manufacturer),
          if (widget.ammunition.velocity != null)
            _buildInfoRow('Muzzle Velocity', '${widget.ammunition.velocity} fps'),
          if (widget.ammunition.bullet.bc.g1 != null)
            _buildInfoRow('G1 BC', widget.ammunition.bullet.bc.g1!.toStringAsFixed(3)),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDopeDataSection(List<DopeEntry> dopeEntries) {
    return _buildDataSection(
      title: 'DOPE Card Data',
      icon: '📋',
      count: dopeEntries.length,
      child: dopeEntries.isEmpty
          ? _buildEmptyDataMessage('No DOPE entries recorded')
          : _buildDopeTable(dopeEntries),
    );
  }

  Widget _buildZeroDataSection(List<ZeroEntry> zeroEntries) {
    return _buildDataSection(
      title: 'Zero Data',
      icon: '🎯',
      count: zeroEntries.length,
      child: zeroEntries.isEmpty
          ? _buildEmptyDataMessage('No zero entries recorded')
          : _buildZeroTable(zeroEntries),
    );
  }

  Widget _buildChronographDataSection(List<ChronographData> chronographData) {
    return _buildDataSection(
      title: 'Chronograph Data',
      icon: '⏱️',
      count: chronographData.length,
      child: chronographData.isEmpty
          ? _buildEmptyDataMessage('No chronograph data recorded')
          : _buildChronographTable(chronographData),
    );
  }

  Widget _buildCalculationsDataSection(List<BallisticCalculation> calculations) {
    return _buildDataSection(
      title: 'Ballistic Calculations',
      icon: '📐',
      count: calculations.length,
      child: calculations.isEmpty
          ? _buildEmptyDataMessage('No ballistic calculations recorded')
          : _buildCalculationsTable(calculations),
    );
  }

  Widget _buildDataSection({
    required String title,
    required String icon,
    required int count,
    required Widget child,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Section Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.primary.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Text(icon, style: const TextStyle(fontSize: 24)),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.primary,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: count > 0 ? AppTheme.success : AppTheme.textSecondary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '$count',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Section Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: child,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyDataMessage(String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Icon(
            Icons.inbox_outlined,
            size: 48,
            color: AppTheme.textSecondary,
          ),
          const SizedBox(height: 12),
          Text(
            message,
            style: const TextStyle(
              fontSize: 16,
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDopeTable(List<DopeEntry> entries) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columnSpacing: 20,
        headingRowColor: MaterialStateProperty.all(AppTheme.background),
        columns: const [
          DataColumn(
            label: Text(
              'Distance',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          DataColumn(
            label: Text(
              'Elevation',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          DataColumn(
            label: Text(
              'Windage',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          DataColumn(
            label: Text(
              'Date',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
        rows: entries.map((entry) {
          return DataRow(
            cells: [
              DataCell(Text('${entry.distance} yd')),
              DataCell(Text(entry.elevation)),
              DataCell(Text(entry.windage)),
              DataCell(Text(_formatDate(entry.createdAt))),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildZeroTable(List<ZeroEntry> entries) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columnSpacing: 20,
        headingRowColor: MaterialStateProperty.all(AppTheme.background),
        columns: const [
          DataColumn(
            label: Text(
              'Distance',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          DataColumn(
            label: Text(
              'POI Offset',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          DataColumn(
            label: Text(
              'Status',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          DataColumn(
            label: Text(
              'Date',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
        rows: entries.map((entry) {
          return DataRow(
            cells: [
              DataCell(Text('${entry.distance} yd')),
              DataCell(Text(entry.poiOffset)),
              DataCell(
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: entry.confirmed ? AppTheme.success : AppTheme.warning,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    entry.confirmed ? 'Confirmed' : 'Unconfirmed',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              DataCell(Text(_formatDate(entry.createdAt))),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildChronographTable(List<ChronographData> data) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columnSpacing: 20,
        headingRowColor: MaterialStateProperty.all(AppTheme.background),
        columns: const [
          DataColumn(
            label: Text(
              'Shots',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          DataColumn(
            label: Text(
              'Average (fps)',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          DataColumn(
            label: Text(
              'ES (fps)',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          DataColumn(
            label: Text(
              'SD (fps)',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          DataColumn(
            label: Text(
              'Date',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
        rows: data.map((chrono) {
          return DataRow(
            cells: [
              DataCell(Text('${chrono.velocities.length}')),
              DataCell(Text(chrono.average.toStringAsFixed(1))),
              DataCell(Text(chrono.extremeSpread.toStringAsFixed(1))),
              DataCell(Text(chrono.standardDeviation.toStringAsFixed(1))),
              DataCell(Text(_formatDate(chrono.createdAt))),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildCalculationsTable(List<BallisticCalculation> calculations) {
    return Column(
      children: calculations.map((calc) {
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.background,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppTheme.borderColor),
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
                  Text(
                    _formatDate(calc.createdAt),
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.textSecondary,
                    ),
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
              const SizedBox(height: 12),
              _buildTrajectoryTable(calc.trajectoryData),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTrajectoryTable(List<BallisticPoint> data) {
    if (data.isEmpty) return const SizedBox();

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columnSpacing: 16,
        dataRowMinHeight: 32,
        headingRowHeight: 40,
        headingRowColor: MaterialStateProperty.all(AppTheme.primary.withOpacity(0.1)),
        columns: const [
          DataColumn(label: Text('Range', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600))),
          DataColumn(label: Text('Drop', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600))),
          DataColumn(label: Text('Drift', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600))),
          DataColumn(label: Text('Velocity', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600))),
          DataColumn(label: Text('Energy', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600))),
        ],
        rows: data.take(8).map((point) => DataRow(cells: [
          DataCell(Text('${point.range} yd', style: const TextStyle(fontSize: 12))),
          DataCell(Text('${point.drop.toStringAsFixed(1)}"', style: const TextStyle(fontSize: 12))),
          DataCell(Text('${point.windDrift.toStringAsFixed(1)}"', style: const TextStyle(fontSize: 12))),
          DataCell(Text('${point.velocity.toInt()} fps', style: const TextStyle(fontSize: 12))),
          DataCell(Text('${point.energy.toInt()} ft-lbs', style: const TextStyle(fontSize: 12))),
        ])).toList(),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date).inDays;

    if (diff == 0) return 'Today';
    if (diff == 1) return 'Yesterday';
    if (diff < 7) return '$diff days ago';
    if (diff < 30) return '${(diff / 7).round()} weeks ago';
    return '${date.day}/${date.month}/${date.year}';
  }
}