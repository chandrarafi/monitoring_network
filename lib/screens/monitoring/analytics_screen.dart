import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/monitoring_provider.dart';
import '../../models/monitoring.dart';
import '../../widgets/error_message_widget.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MonitoringProvider>().loadAnalytics();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Network Analytics',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.purple,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () {
              final provider = context.read<MonitoringProvider>();
              provider.loadAnalytics(refresh: true);
            },
          ),
        ],
      ),
      body: Consumer<MonitoringProvider>(
        builder: (context, monitoringProvider, child) {
          if (monitoringProvider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (monitoringProvider.hasError) {
            return Center(
              child: ErrorMessageWidget(
                message: monitoringProvider.errorMessage,
              ),
            );
          }

          final analyticsData = monitoringProvider.analyticsData;
          if (analyticsData == null) {
            return const Center(
              child: Text('Tidak ada data analytics'),
            );
          }

          return RefreshIndicator(
            onRefresh: () => monitoringProvider.loadAnalytics(refresh: true),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Period Selector
                  _buildPeriodSelector(context, monitoringProvider),
                  
                  const SizedBox(height: 16),
                  
                  // Date Range Info
                  _buildDateRangeInfo(analyticsData.dateRange),
                  
                  const SizedBox(height: 24),
                  
                  // Summary Cards
                  _buildSummaryCards(analyticsData.summary),
                  
                  const SizedBox(height: 24),
                  
                  // Room Trends
                  _buildRoomTrends(context, analyticsData.roomTrends),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPeriodSelector(BuildContext context, MonitoringProvider provider) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Time Period',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: provider.availablePeriods.map((period) {
                final isSelected = period == provider.currentPeriod;
                return FilterChip(
                  label: Text(
                    provider.getPeriodDisplayName(period),
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.purple,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected && period != provider.currentPeriod) {
                      provider.changePeriod(period);
                    }
                  },
                  selectedColor: Colors.purple,
                  checkmarkColor: Colors.white,
                  backgroundColor: Colors.purple.withOpacity(0.1),
                  side: BorderSide(
                    color: isSelected ? Colors.purple : Colors.purple.withOpacity(0.3),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateRangeInfo(DateRange dateRange) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.purple.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.purple.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.date_range, color: Colors.purple, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Data from ${_formatDate(dateRange.start)} to ${_formatDate(dateRange.end)}',
              style: const TextStyle(
                fontSize: 14,
                color: Colors.purple,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCards(AnalyticsSummary summary) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Analytics Summary',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildSummaryCard(
                'Rooms Monitored',
                summary.roomsMonitored.toString(),
                Icons.meeting_room,
                Colors.blue,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildSummaryCard(
                'Data Points',
                summary.totalDataPoints.toString(),
                Icons.timeline,
                Colors.indigo,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildSummaryCard(
                'Avg Utilization',
                '${summary.averageUtilization.toStringAsFixed(1)}%',
                Icons.pie_chart,
                Colors.green,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildSummaryCard(
                'Peak Utilization',
                '${summary.peakUtilization.toStringAsFixed(1)}%',
                Icons.trending_up,
                Colors.red,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSummaryCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoomTrends(BuildContext context, Map<String, RoomTrend> roomTrends) {
    final sortedTrends = roomTrends.values.toList();
    // Sort by peak utilization (highest first)
    sortedTrends.sort((a, b) => b.peakUtilization.compareTo(a.peakUtilization));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Room Trends',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: sortedTrends.length,
          itemBuilder: (context, index) {
            final trend = sortedTrends[index];
            return _buildRoomTrendCard(context, trend);
          },
        ),
      ],
    );
  }

  Widget _buildRoomTrendCard(BuildContext context, RoomTrend trend) {
    Color statusColor = _getStatusColor(trend.currentStatus);
    
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        trend.roomName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          trend.currentStatus.toUpperCase(),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: statusColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${trend.peakUtilization.toStringAsFixed(1)}%',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: statusColor,
                      ),
                    ),
                    const Text(
                      'Peak',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Statistics Row
            Row(
              children: [
                Expanded(
                  child: _buildTrendStat(
                    'Average',
                    '${trend.averageUtilization.toStringAsFixed(1)}%',
                    Icons.trending_flat,
                    Colors.blue,
                  ),
                ),
                Expanded(
                  child: _buildTrendStat(
                    'Peak',
                    '${trend.peakUtilization.toStringAsFixed(1)}%',
                    Icons.trending_up,
                    Colors.red,
                  ),
                ),
                Expanded(
                  child: _buildTrendStat(
                    'Data Points',
                    trend.dataPoints.length.toString(),
                    Icons.timeline,
                    Colors.purple,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Trend Chart
            if (trend.dataPoints.isNotEmpty) ...[
              const Text(
                'Utilization Trend',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 120,
                child: _buildTrendChart(trend.dataPoints),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTrendStat(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildTrendChart(List<AnalyticsDataPoint> dataPoints) {
    // Take only last 24 data points for better visualization
    final displayPoints = dataPoints.length > 24 
        ? dataPoints.sublist(dataPoints.length - 24)
        : dataPoints;
    
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: displayPoints.length,
      itemBuilder: (context, index) {
        final point = displayPoints[index];
        return _buildDataPointBar(point, index == displayPoints.length - 1, index);
      },
    );
  }

  Widget _buildDataPointBar(AnalyticsDataPoint point, bool isLast, int index) {
    final statusColor = _getStatusColor(point.status);
    final height = (point.utilization / 100) * 80; // Max height 80px
    
    return Container(
      width: 24,
      margin: const EdgeInsets.only(right: 4),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // Utilization percentage (only show on last point)
          if (isLast) ...[
            Text(
              '${point.utilization.toStringAsFixed(0)}%',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: statusColor,
              ),
            ),
            const SizedBox(height: 4),
          ] else
            const SizedBox(height: 20),
          
          // Bar
          Container(
            height: height.clamp(2.0, 80.0), // Minimum 2px height
            width: 20,
            decoration: BoxDecoration(
              color: statusColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          const SizedBox(height: 4),
          
          // Time label (only show every 4th point)
          SizedBox(
            height: 16,
            child: index % 4 == 0 
                ? Text(
                    _formatTime(point.time),
                    style: const TextStyle(
                      fontSize: 8,
                      color: Colors.grey,
                    ),
                  )
                : null,
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'critical':
        return Colors.red;
      case 'warning':
        return Colors.orange;
      default:
        return Colors.green;
    }
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateString;
    }
  }

  String _formatTime(String timeString) {
    try {
      // Try to parse as full datetime first
      if (timeString.contains('-')) {
        final dateTime = DateTime.parse(timeString);
        return '${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
      }
      // If it's just time format like "14:30"
      return timeString;
    } catch (e) {
      return timeString;
    }
  }
}