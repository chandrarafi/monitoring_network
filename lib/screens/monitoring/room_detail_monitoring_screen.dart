import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/monitoring_provider.dart';
import '../../models/monitoring.dart';
import '../../models/room.dart';
import '../../widgets/error_message_widget.dart';

class RoomDetailMonitoringScreen extends StatefulWidget {
  final String roomId;

  const RoomDetailMonitoringScreen({
    super.key,
    required this.roomId,
  });

  @override
  State<RoomDetailMonitoringScreen> createState() => _RoomDetailMonitoringScreenState();
}

class _RoomDetailMonitoringScreenState extends State<RoomDetailMonitoringScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final roomId = int.tryParse(widget.roomId);
      if (roomId != null) {
        context.read<MonitoringProvider>().loadRoomDetail(roomId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final roomId = int.tryParse(widget.roomId);
    
    if (roomId == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Room Detail'),
          backgroundColor: Colors.blue,
        ),
        body: const Center(
          child: Text('Invalid room ID'),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Room Detail Monitoring',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blue,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () {
              context.read<MonitoringProvider>().loadRoomDetail(roomId, refresh: true);
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

          final roomDetail = monitoringProvider.getRoomDetail(roomId);
          if (roomDetail == null) {
            return const Center(
              child: Text('Room detail tidak ditemukan'),
            );
          }

          return RefreshIndicator(
            onRefresh: () => monitoringProvider.loadRoomDetail(roomId, refresh: true),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Room Info Card
                  _buildRoomInfoCard(roomDetail.room, roomDetail.currentStatus),
                  
                  const SizedBox(height: 16),
                  
                  // Current Status Card
                  _buildCurrentStatusCard(roomDetail.currentStatus),
                  
                  const SizedBox(height: 16),
                  
                  // IP Details Card
                  _buildIpDetailsCard(roomDetail.ipDetails),
                  
                  const SizedBox(height: 16),
                  
                  // Historical Data Chart
                  _buildHistoricalDataCard(roomDetail.historicalData),
                  
                  const SizedBox(height: 16),
                  
                  // Active Leases
                  _buildActiveLeasesCard(context, roomDetail.leases),
                  
                  const SizedBox(height: 16),
                  
                  // Last Updated
                  _buildLastUpdated(roomDetail.lastUpdated),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildRoomInfoCard(Room room, RoomCurrentStatus status) {
    Color statusColor;
    IconData statusIcon;
    
    switch (status.status.toLowerCase()) {
      case 'critical':
        statusColor = Colors.red;
        statusIcon = Icons.error;
        break;
      case 'warning':
        statusColor = Colors.orange;
        statusIcon = Icons.warning;
        break;
      default:
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
    }

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: [Colors.blue, Colors.blue.shade700],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        room.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (room.description != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          room.description!,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                      ],
                      const SizedBox(height: 8),
                      Text(
                        'IP Range: ${_getIPRangeDisplay(room)}',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    statusIcon,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                status.status.toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentStatusCard(RoomCurrentStatus status) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Current Status',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            
            // Utilization Progress
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Utilization',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
                Text(
                  '${status.utilizationPercentage.toStringAsFixed(1)}%',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: _getStatusColor(status.status),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: status.utilizationPercentage / 100,
              backgroundColor: Colors.grey.withOpacity(0.3),
              valueColor: AlwaysStoppedAnimation<Color>(_getStatusColor(status.status)),
              minHeight: 8,
            ),
            
            const SizedBox(height: 20),
            
            // Stats Grid
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Total IPs',
                    status.totalIps.toString(),
                    Icons.router,
                    Colors.blue,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    'Used IPs',
                    status.usedIps.toString(),
                    Icons.device_hub,
                    Colors.indigo,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    'Available',
                    status.availableIps.toString(),
                    Icons.inventory,
                    Colors.green,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
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
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildIpDetailsCard(RoomIpDetails ipDetails) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'IP Details',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            
            // IP Range
            _buildDetailRow(
              'IP Range',
              '${ipDetails.ipRangeStart} - ${ipDetails.ipRangeEnd}',
              Icons.router,
              Colors.blue,
            ),
            
            const SizedBox(height: 12),
            
            // Used IPs
            if (ipDetails.usedIps.isNotEmpty) ...[
              _buildIpListSection(
                'Used IPs (${ipDetails.usedIps.length})',
                ipDetails.usedIps,
                Colors.red,
                Icons.device_hub,
              ),
              const SizedBox(height: 12),
            ],
            
            // Free IPs
            if (ipDetails.freeIps.isNotEmpty) ...[
              _buildIpListSection(
                'Free IPs (${ipDetails.freeIps.length})',
                ipDetails.freeIps,
                Colors.green,
                Icons.inventory,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String title, String value, IconData icon, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildIpListSection(String title, List<String> ips, Color color, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 16),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: ips.take(10).map((ip) => Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: color.withOpacity(0.3)),
            ),
            child: Text(
              ip,
              style: TextStyle(
                fontSize: 12,
                color: color,
                fontWeight: FontWeight.w500,
              ),
            ),
          )).toList(),
        ),
        if (ips.length > 10)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              '... and ${ips.length - 10} more',
              style: TextStyle(
                fontSize: 12,
                color: color,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildHistoricalDataCard(List<HistoricalData> historicalData) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Historical Trends',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            
            if (historicalData.isEmpty)
              const Center(
                child: Text(
                  'No historical data available',
                  style: TextStyle(color: Colors.grey),
                ),
              )
            else
              SizedBox(
                height: 200,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: historicalData.length,
                  itemBuilder: (context, index) {
                    final data = historicalData[index];
                    return _buildHistoricalDataPoint(data);
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoricalDataPoint(HistoricalData data) {
    final statusColor = _getStatusColor(data.status);
    
    return Container(
      width: 80,
      margin: const EdgeInsets.only(right: 12),
      child: Column(
        children: [
          Expanded(
            child: Container(
              width: 40,
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    height: (data.utilizationPercentage / 100) * 120,
                    width: 40,
                    decoration: BoxDecoration(
                      color: statusColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${data.utilizationPercentage.toStringAsFixed(0)}%',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: statusColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            data.monitoredAt,
            style: const TextStyle(
              fontSize: 10,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveLeasesCard(BuildContext context, List<RoomLease> leases) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Active Leases (${leases.length})',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                if (leases.isNotEmpty)
                  TextButton.icon(
                    onPressed: () => context.push('/dhcp'),
                    icon: const Icon(Icons.arrow_forward, size: 16),
                    label: const Text('View All'),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            
            if (leases.isEmpty)
              const Center(
                child: Text(
                  'No active leases',
                  style: TextStyle(color: Colors.grey),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: leases.take(5).length,
                itemBuilder: (context, index) {
                  final lease = leases[index];
                  return _buildLeaseItem(lease);
                },
              ),
            
            if (leases.length > 5)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Center(
                  child: Text(
                    '... and ${leases.length - 5} more leases',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildLeaseItem(RoomLease lease) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: lease.status.toLowerCase() == 'bound' ? Colors.green : Colors.orange,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  lease.address,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  lease.macAddress.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
                if (lease.comment != null && lease.comment!.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    lease.comment!,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.blue,
                    ),
                  ),
                ],
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: lease.status.toLowerCase() == 'bound' 
                  ? Colors.green.withOpacity(0.1)
                  : Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              lease.status.toUpperCase(),
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: lease.status.toLowerCase() == 'bound' ? Colors.green : Colors.orange,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLastUpdated(String lastUpdated) {
    return Center(
      child: Text(
        'Last updated: ${_formatDateTime(lastUpdated)}',
        style: const TextStyle(
          fontSize: 12,
          color: Colors.grey,
        ),
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

  String _getIPRangeDisplay(Room room) {
    // Cek jika ada ipRangeStart dan ipRangeEnd
    if (room.ipRangeStart != null && room.ipRangeEnd != null) {
      return '${room.ipRangeStart} - ${room.ipRangeEnd}';
    }
    
    // Fallback ke ipRangeDisplay jika ada
    if (room.ipRangeDisplay != null && room.ipRangeDisplay!.isNotEmpty) {
      return room.ipRangeDisplay!;
    }
    
    // Jika tidak ada range info, tampilkan placeholder
    return 'IP Range not configured';
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