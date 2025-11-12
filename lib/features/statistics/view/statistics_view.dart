import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:live_fish_ai/features/catch_log/bloc/catch_log_bloc.dart';
import 'package:live_fish_ai/models/fish_catch.dart';
import 'package:live_fish_ai/theme/app_theme.dart';

class StatisticsView extends StatelessWidget {
  const StatisticsView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          CatchLogBloc()..add(const CatchesSubscriptionRequested()),
      child: const StatisticsBody(),
    );
  }
}

class StatisticsBody extends StatelessWidget {
  const StatisticsBody({super.key});

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
                        color: AppTheme.seaFoam.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.analytics,
                        color: AppTheme.seaFoam,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Statistics',
                            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppTheme.darkText,
                            ),
                          ),
                          Text(
                            'Your fishing insights',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppTheme.lightText,
                            ),
                          ),
                        ],
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
                    return _buildStatistics(context, state.catches);
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
            valueColor: AlwaysStoppedAnimation<Color>(AppTheme.seaFoam),
          ),
          SizedBox(height: 16),
          Text(
            'Analyzing your data...',
            style: TextStyle(
              color: AppTheme.lightText,
              fontSize: 16,
            ),
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
            'Failed to load statistics',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppTheme.darkText,
            ),
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
                color: AppTheme.seaFoam.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.analytics,
                size: 64,
                color: AppTheme.seaFoam,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No data to analyze',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppTheme.darkText,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Start logging catches to see your fishing statistics and insights!',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppTheme.lightText,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatistics(BuildContext context, List<FishCatch> catches) {
    final adultCount = catches.where((c) => !c.isJuvenile).length;
    final juvenileCount = catches.where((c) => c.isJuvenile).length;
    final avgLength = catches.map((c) => c.length).reduce((a, b) => a + b) / catches.length;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          // Summary Cards
          Row(
            children: [
              Expanded(
                child: _buildSummaryCard(
                  title: 'Total Catches',
                  value: catches.length.toString(),
                  icon: Icons.phishing,
                  color: AppTheme.primaryBlue,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildSummaryCard(
                  title: 'Avg Length',
                  value: '${avgLength.toStringAsFixed(1)} cm',
                  icon: Icons.straighten,
                  color: AppTheme.aqua,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          Row(
            children: [
              Expanded(
                child: _buildSummaryCard(
                  title: 'Adult Fish',
                  value: adultCount.toString(),
                  icon: Icons.check_circle,
                  color: AppTheme.seaFoam,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildSummaryCard(
                  title: 'Juveniles',
                  value: juvenileCount.toString(),
                  icon: Icons.warning,
                  color: AppTheme.coral,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Adult vs Juvenile Chart
          _buildChartCard(
            title: 'Adult vs Juvenile Distribution',
            child: SizedBox(
              height: 200,
              child: _buildBarChart(adultCount, juvenileCount),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Size Distribution Chart
          _buildChartCard(
            title: 'Size Distribution',
            child: SizedBox(
              height: 200,
              child: _buildPieChart(catches),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Conservation Impact
          _buildConservationCard(juvenileCount, catches.length),
          
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSummaryCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [AppTheme.softShadow],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 20,
                ),
              ),
              const Spacer(),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              color: AppTheme.lightText,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChartCard({required String title, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [AppTheme.softShadow],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.darkText,
            ),
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _buildConservationCard(int juvenileCount, int totalCount) {
    final conservationScore = totalCount > 0 
        ? ((totalCount - juvenileCount) / totalCount * 100).round()
        : 0;
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppTheme.seaFoam, AppTheme.aqua],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [AppTheme.softShadow],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.eco,
                color: Colors.white,
                size: 24,
              ),
              SizedBox(width: 8),
              Text(
                'Conservation Impact',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            '$conservationScore% Sustainable Catches',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            juvenileCount > 0 
                ? 'Great job! You\'ve released $juvenileCount juvenile fish.'
                : 'Perfect! All your catches were adult fish.',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBarChart(int adultCount, int juvenileCount) {
    return BarChart(
      BarChartData(
        barGroups: [
          BarChartGroupData(
            x: 0,
            barRods: [
              BarChartRodData(
                toY: adultCount.toDouble(),
                color: AppTheme.seaFoam,
                width: 40,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(4),
                  topRight: Radius.circular(4),
                ),
              ),
            ],
          ),
          BarChartGroupData(
            x: 1,
            barRods: [
              BarChartRodData(
                toY: juvenileCount.toDouble(),
                color: AppTheme.coral,
                width: 40,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(4),
                  topRight: Radius.circular(4),
                ),
              ),
            ],
          ),
        ],
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                const style = TextStyle(
                  color: AppTheme.lightText,
                  fontWeight: FontWeight.w500,
                  fontSize: 12,
                );
                Widget text;
                switch (value.toInt()) {
                  case 0:
                    text = const Text('Adult', style: style);
                    break;
                  case 1:
                    text = const Text('Juvenile', style: style);
                    break;
                  default:
                    text = const Text('', style: style);
                    break;
                }
                return SideTitleWidget(
                  axisSide: meta.axisSide,
                  space: 8,
                  child: text,
                );
              },
            ),
          ),
          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        gridData: const FlGridData(show: false),
        barTouchData: BarTouchData(enabled: false),
      ),
    );
  }

  Widget _buildPieChart(List<FishCatch> catches) {
    final sizeBuckets = <String, int>{};
    for (final fish in catches) {
      final bucket = fish.length < 20 
          ? 'Small (<20cm)'
          : fish.length < 40 
              ? 'Medium (20-40cm)'
              : 'Large (>40cm)';
      sizeBuckets.update(bucket, (value) => value + 1, ifAbsent: () => 1);
    }

    final colors = [AppTheme.coral, AppTheme.aqua, AppTheme.seaFoam];
    int colorIndex = 0;

    final sections = sizeBuckets.entries.map((entry) {
      final color = colors[colorIndex % colors.length];
      colorIndex++;
      
      return PieChartSectionData(
        color: color,
        value: entry.value.toDouble(),
        title: '${entry.value}',
        radius: 60,
        titleStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();

    return Row(
      children: [
        Expanded(
          flex: 2,
          child: PieChart(
            PieChartData(
              sections: sections,
              sectionsSpace: 2,
              centerSpaceRadius: 30,
              pieTouchData: PieTouchData(enabled: false),
            ),
          ),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: sizeBuckets.entries.map((entry) {
              final color = colors[(sizeBuckets.keys.toList().indexOf(entry.key)) % colors.length];
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        entry.key,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppTheme.lightText,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
