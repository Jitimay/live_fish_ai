import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:live_fish_ai/features/catch_log/bloc/catch_log_bloc.dart';
import 'package:live_fish_ai/models/fish_catch.dart';
import 'package:live_fish_ai/theme/app_theme.dart';

class CatchLogView extends StatelessWidget {
  const CatchLogView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          CatchLogBloc()..add(const CatchesSubscriptionRequested()),
      child: const CatchLogBody(),
    );
  }
}

class CatchLogBody extends StatelessWidget {
  const CatchLogBody({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppTheme.surfaceLight, Colors.white],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Custom App Bar
              Container(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryBlue.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.history,
                        color: AppTheme.primaryBlue,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Catch Log',
                            style: Theme.of(context).textTheme.headlineMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.darkText,
                                ),
                          ),
                          Text(
                            'Your fishing history',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(color: AppTheme.lightText),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        // Add filter/search functionality
                      },
                      icon: const Icon(
                        Icons.filter_list,
                        color: AppTheme.lightText,
                      ),
                    ),
                  ],
                ),
              ),

              // Content
              Expanded(
                child: BlocBuilder<CatchLogBloc, CatchLogState>(
                  builder: (context, state) {
                    if (state.status == CatchLogStatus.loading) {
                      return _buildLoadingView(context);
                    }
                    if (state.status == CatchLogStatus.failure) {
                      return _buildErrorView(context);
                    }
                    if (state.catches.isEmpty) {
                      return _buildEmptyView(context);
                    }
                    return _buildCatchList(state.catches);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingView(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryBlue),
          ),
          SizedBox(height: 16),
          Text(
            'Loading your catches...',
            style: TextStyle(color: AppTheme.lightText, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorView(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.coral.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.error_outline,
              size: 48,
              color: AppTheme.coral,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Failed to load catches',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppTheme.darkText,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Please try again later',
            style: TextStyle(color: AppTheme.lightText),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyView(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppTheme.aqua.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.waves, size: 64, color: AppTheme.aqua),
            ),
            const SizedBox(height: 24),
            Text(
              'No catches yet',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppTheme.darkText,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Start using the camera to detect and log your first fish catch!',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppTheme.lightText,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppTheme.primaryBlue, AppTheme.aqua],
                ),
                borderRadius: BorderRadius.circular(25),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.camera_alt, color: Colors.white, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Go to Camera',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCatchList(List<FishCatch> catches) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: catches.length,
      itemBuilder: (context, index) {
        final fishCatch = catches[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: CatchCard(fishCatch: fishCatch),
        );
      },
    );
  }
}

class CatchCard extends StatelessWidget {
  const CatchCard({super.key, required this.fishCatch});

  final FishCatch fishCatch;

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat.yMMMd().add_jm();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [AppTheme.softShadow],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with species and status
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.aqua.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.phishing,
                    color: AppTheme.aqua,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        fishCatch.species.toUpperCase(),
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.darkText,
                        ),
                      ),
                      Text(
                        dateFormat.format(fishCatch.timestamp),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.lightText,
                        ),
                      ),
                    ],
                  ),
                ),
                _buildStatusChip(),
              ],
            ),

            const SizedBox(height: 20),

            // Stats row
            Row(
              children: [
                _buildStatItem(
                  icon: Icons.straighten,
                  label: 'Length',
                  value: '${fishCatch.length.toStringAsFixed(1)} cm',
                  color: AppTheme.primaryBlue,
                ),
                const SizedBox(width: 24),
                _buildStatItem(
                  icon: Icons.psychology,
                  label: 'Confidence',
                  value: '${(fishCatch.confidence * 100).toStringAsFixed(0)}%',
                  color: AppTheme.seaFoam,
                ),
              ],
            ),

            if (fishCatch.latitude != null && fishCatch.longitude != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceLight,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.location_on,
                      size: 16,
                      color: AppTheme.lightText,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${fishCatch.latitude!.toStringAsFixed(4)}, ${fishCatch.longitude!.toStringAsFixed(4)}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.lightText,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip() {
    final isJuvenile = fishCatch.isJuvenile;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isJuvenile
            ? AppTheme.coral.withValues(alpha: 0.1)
            : AppTheme.seaFoam.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isJuvenile
              ? AppTheme.coral.withValues(alpha: 0.3)
              : AppTheme.seaFoam.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isJuvenile ? Icons.warning : Icons.check_circle,
            size: 14,
            color: isJuvenile ? AppTheme.coral : AppTheme.seaFoam,
          ),
          const SizedBox(width: 4),
          Text(
            isJuvenile ? 'Juvenile' : 'Adult',
            style: TextStyle(
              color: isJuvenile ? AppTheme.coral : AppTheme.seaFoam,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 16, color: color),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: TextStyle(
                    color: color,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
