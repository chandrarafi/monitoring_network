import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/monitoring_provider.dart';
import '../../models/monitoring.dart';
import '../../widgets/error_message_widget.dart';

class RealtimeMonitoringScreen extends StatefulWidget {
  const RealtimeMonitoringScreen({super.key});

  @override
  State<RealtimeMonitoringScreen> createState() => _RealtimeMonitoringScreenState();
}

class _RealtimeMonitoringScreenState extends State<RealtimeMonitoringScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MonitoringProvider>().loadRealtimeMonitoring();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Real-time Monitoring',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blue,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () {
              context.read<MonitoringProvider>().loadRealtimeMonitoring(refresh: true);
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

          final realtimeData = monitoringProvider.realtimeData;
          if (realtimeData == null) {
            return const Center(
              child: Text('Tidak ada data real-time monitoring'),
            );
          }

          return RefreshIndicator(
            onRefresh: () => monitoringProvider.loadRealtimeMonitoring(refresh: true),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Summary Cards
                  _buildSummaryCards(realtimeData.summary),
                  
                  const SizedBox(height: 24),
                  
                  // Rooms Monitoring List
                  _buildRoomsMonitoring(context, realtimeData.monitoring),
                  
                  const SizedBox(height: 16),
                  
                  // Last Updated
                  _buildLastUpdated(realtimeData.timestamp),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSummaryCards(RealtimeSummary summary) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Summary',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        
        // Room Status Cards
        Row(
          children: [
            Expanded(
              child: _buildSummaryCard(
                'Critical',
                summary.criticalRooms.toString(),
                Colors.red,
                Icons.error,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildSummaryCard(
                'Warning',
                summary.warningRooms.toString(),
                Colors.orange,
                Icons.warning,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildSummaryCard(
                'Normal',
                summary.normalRooms.toString(),
                Colors.green,
                Icons.check_circle,
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 16),
        
        // IP Usage Cards
        Row(
          children: [
            Expanded(
              child: _buildSummaryCard(
                'Total Rooms',
                summary.totalRoomsMonitored.toString(),
                Colors.blue,
                Icons.meeting_room,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildSummaryCard(
                'Used IPs',
                summary.totalUsedIps.toString(),
                Colors.indigo,
                Icons.router,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildSummaryCard(
                'Available IPs',
                summary.totalAvailableIps.toString(),
                Colors.teal,
                Icons.inventory,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSummaryCard(String title, String value, Color color, IconData icon) {
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

  Widget _buildRoomsMonitoring(BuildContext context, List<RealtimeMonitoringData> rooms) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Rooms Monitoring',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        
        // Sort rooms by status (critical first, then warning, then normal)
        Builder(
          builder: (context) {
            final sortedRooms = List<RealtimeMonitoringData>.from(rooms);
            sortedRooms.sort((a, b) {
              // Priority: critical > warning > normal
              int getPriority(String status) {
                switch (status.toLowerCase()) {
                  case 'critical': return 0;
                  case 'warning': return 1;
                  default: return 2;
                }
              }
              return getPriority(a.status).compareTo(getPriority(b.status));
            });
            
            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: sortedRooms.length,
              itemBuilder: (context, index) {
                final room = sortedRooms[index];
                return _buildRoomCard(context, room);
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildRoomCard(BuildContext context, RealtimeMonitoringData room) {
    Color statusColor;
    IconData statusIcon;
    Color backgroundColor;
    
    switch (room.status.toLowerCase()) {
      case 'critical':
        statusColor = Colors.red;
        statusIcon = Icons.error;
        backgroundColor = Colors.red.withOpacity(0.1);
        break;
      case 'warning':
        statusColor = Colors.orange;
        statusIcon = Icons.warning;
        backgroundColor = Colors.orange.withOpacity(0.1);
        break;
      default:
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        backgroundColor = Colors.green.withOpacity(0.1);
    }

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => context.push('/monitoring/room/${room.roomId}'),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: statusColor.withOpacity(0.3), width: 1),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Row
                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: backgroundColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(statusIcon, color: statusColor, size: 24),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            room.roomName,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            room.ipRange,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: backgroundColor,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        room.status.toUpperCase(),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: statusColor,
                        ),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // Utilization Progress Bar
                Row(
                  children: [
                    const Text(
                      'Utilization: ',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                    Text(
                      '${room.utilizationPercentage.toStringAsFixed(1)}%',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: statusColor,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 8),
                
                LinearProgressIndicator(
                  value: room.utilizationPercentage / 100,
                  backgroundColor: Colors.grey.withOpacity(0.3),
                  valueColor: AlwaysStoppedAnimation<Color>(statusColor),
                  minHeight: 6,
                ),
                
                const SizedBox(height: 16),
                
                // Statistics Row
                Row(
                  children: [
                    Expanded(
                      child: _buildStatItem(
                        'Total IPs',
                        room.totalIps.toString(),
                        Icons.router,
                        Colors.blue,
                      ),
                    ),
                    Expanded(
                      child: _buildStatItem(
                        'Used IPs',
                        room.usedIps.toString(),
                        Icons.device_hub,
                        Colors.indigo,
                      ),
                    ),
                    Expanded(
                      child: _buildStatItem(
                        'Available',
                        room.availableIps.toString(),
                        Icons.inventory,
                        Colors.green,
                      ),
                    ),
                    Expanded(
                      child: _buildStatItem(
                        'Active Leases',
                        room.activeLeases.toString(),
                        Icons.network_check,
                        Colors.teal,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 12),
                
                // Last Monitored
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Last monitored: ${_formatDateTime(room.monitoredAt)}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.grey,
                      size: 16,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
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
            fontSize: 10,
            color: Colors.grey,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildLastUpdated(String timestamp) {
    return Center(
      child: Text(
        'Last updated: ${_formatDateTime(timestamp)}',
        style: const TextStyle(
          fontSize: 12,
          color: Colors.grey,
        ),
      ),
    );
  }

  String _formatDateTime(String dateTimeString) {
    try {
      final dateTime = DateTime.parse(dateTimeString);
      return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateTimeString;
    }
  }
}