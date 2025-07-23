import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_theme.dart';
import '../bloc/loadout_bloc.dart';
import '../widgets/loadout_overview_section.dart';
import '../widgets/rifle_profiles_section.dart';
import '../widgets/ammunition_inventory_section.dart';
import '../widgets/scope_profiles_section.dart';
import '../widgets/maintenance_schedule_section.dart';
import '../widgets/ballistic_tools_section.dart';

class LoadoutPage extends StatefulWidget {
  const LoadoutPage({Key? key}) : super(key: key);

  @override
  State<LoadoutPage> createState() => _LoadoutPageState();
}

class _LoadoutPageState extends State<LoadoutPage> {
  @override
  void initState() {
    super.initState();
    context.read<LoadoutBloc>().add(LoadLoadoutEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text(
          'Loadout',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 24,
          ),
        ),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.file_download),
            onPressed: _exportData,
          ),
        ],
      ),
      body: BlocBuilder<LoadoutBloc, LoadoutState>(
        builder: (context, state) {
          if (state is LoadoutLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is LoadoutError) {
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
                      context.read<LoadoutBloc>().add(LoadLoadoutEvent());
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (state is LoadoutLoaded) {
            return Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        LoadoutOverviewSection(state: state),
                        RifleProfilesSection(state: state),
                        AmmunitionInventorySection(state: state),
                        ScopeProfilesSection(state: state),
                        MaintenanceScheduleSection(state: state),
                        // const BallisticToolsSection(),
                      ],
                    ),
                  ),
                ),
              ],
            );
          }

          return const Center(child: Text('Unknown state'));
        },
      ),
    );
  }

  void _exportData() {
    // Implementation for exporting data
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Export functionality coming soon!'),
        backgroundColor: AppTheme.primary,
      ),
    );
  }
}
