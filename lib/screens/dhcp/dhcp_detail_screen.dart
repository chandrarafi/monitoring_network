import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/dhcp_provider.dart';
import '../../models/dhcp_lease.dart';
import '../../widgets/error_message_widget.dart';

class DhcpDetailScreen extends StatefulWidget {
  final String leaseId;

  const DhcpDetailScreen({
    super.key,
    required this.leaseId,
  });

  @override
  State<DhcpDetailScreen> createState() => _DhcpDetailScreenState();
}

class _DhcpDetailScreenState extends State<DhcpDetailScreen> {
  DhcpLease? _currentLease;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _findLeaseById();
    });
  }

  @override
  void didUpdateWidget(DhcpDetailScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Refresh data when widget updates
    if (oldWidget.leaseId != widget.leaseId) {
      _findLeaseById();
    }
  }



  void _findLeaseById() {
    final dhcpProvider = context.read<DhcpProvider>();
    
    try {
      final lease = dhcpProvider.dhcpLeases.firstWhere(
        (lease) => lease.id?.toString() == widget.leaseId,
        orElse: () => throw Exception('DHCP lease not found'),
      );
      
      // Debug: Print lease info
      print('Found lease: ID=${lease.id}, Address=${lease.address}, MAC=${lease.macAddress}');
      
      setState(() {
        _currentLease = lease;
      });
      
      dhcpProvider.selectLease(lease);
    } catch (e) {
      print('Error finding lease with ID ${widget.leaseId}: $e');
      print('Available leases: ${dhcpProvider.dhcpLeases.map((l) => 'ID=${l.id}, Address=${l.address}').join(', ')}');
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('DHCP lease tidak ditemukan'),
          backgroundColor: Colors.red,
        ),
      );
      context.pop();
    }
  }

  Future<void> _deleteLease(DhcpLease lease) async {
    // Check if lease has valid ID
    if (lease.id == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('DHCP lease tidak memiliki ID yang valid'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => _buildDeleteConfirmationDialog(lease),
    );

    if (confirmed == true && mounted) {
      final dhcpProvider = context.read<DhcpProvider>();
      
      try {
        final result = await dhcpProvider.deleteDhcpLease(lease.id!.toString());
        
        if (mounted) {
          if (result.success) {
            // Show different messages based on deletion location
            final icon = result.isFullyDeleted ? '✅' : '⚠️';
            final color = result.isFullyDeleted ? Colors.green : Colors.orange;
            
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('$icon ${result.statusMessage}'),
                backgroundColor: color,
                duration: const Duration(seconds: 4),
              ),
            );
            
            // Show additional info if database only
            if (!result.isFullyDeleted && result.reason != null) {
              Future.delayed(const Duration(seconds: 1), () {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Info: ${result.reason}'),
                      backgroundColor: Colors.blue,
                      duration: const Duration(seconds: 3),
                    ),
                  );
                }
              });
            }
            
            // Kembali ke halaman sebelumnya
            context.pop();
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('❌ ${result.statusMessage}'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('❌ Error menghapus DHCP lease: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          _currentLease?.address ?? 'DHCP Detail',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.green,
        elevation: 0,
        actions: [
          if (_currentLease != null) ...[
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.white),
              onPressed: () {
                if (_currentLease!.id != null) {
                  context.push('/dhcp/edit/${_currentLease!.id}');
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('DHCP lease tidak memiliki ID yang valid untuk diedit'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.white),
              onPressed: () => _deleteLease(_currentLease!),
            ),
          ],
        ],
      ),
      body: Consumer<DhcpProvider>(
        builder: (context, dhcpProvider, child) {
          if (_currentLease == null) {
            return const Center(child: CircularProgressIndicator());
          }

          final lease = _currentLease!;

          return Column(
            children: [
              // Error Message
              ErrorMessageWidget(
                message: dhcpProvider.errorMessage,
                onDismiss: () => dhcpProvider.clearError(),
              ),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header Card
                      _buildHeaderCard(lease),
                      
                      const SizedBox(height: 16),
                      
                      // Network Information
                      _buildNetworkInfoCard(lease),
                      
                      const SizedBox(height: 16),
                      
                      // Room Information
                      if (lease.hasRoom) ...[
                        _buildRoomInfoCard(lease),
                        const SizedBox(height: 16),
                      ],
                      
                      // Server Information
                      _buildServerInfoCard(lease),
                      
                      const SizedBox(height: 16),
                      
                      // Status & Timestamps
                      _buildStatusCard(lease),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: _currentLease != null ? _buildBottomActions() : null,
    );
  }

  Widget _buildHeaderCard(DhcpLease lease) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'IP Address',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        lease.address,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: _getStatusColor(lease).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: _getStatusColor(lease),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    lease.statusDisplay,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: _getStatusColor(lease),
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Status Chips
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (lease.isActive)
                  Chip(
                    label: const Text('Aktif'),
                    backgroundColor: Colors.green.withValues(alpha: 0.1),
                    labelStyle: TextStyle(
                      fontSize: 12,
                      color: Colors.green[700],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                if (lease.isDisabled)
                  Chip(
                    label: const Text('Disabled'),
                    backgroundColor: Colors.red.withValues(alpha: 0.1),
                    labelStyle: TextStyle(
                      fontSize: 12,
                      color: Colors.red[700],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                if (lease.dynamicLease)
                  Chip(
                    label: const Text('Dynamic'),
                    backgroundColor: Colors.blue.withValues(alpha: 0.1),
                    labelStyle: TextStyle(
                      fontSize: 12,
                      color: Colors.blue[700],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNetworkInfoCard(DhcpLease lease) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Informasi Jaringan',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            
            const SizedBox(height: 16),
            
            _buildInfoRow('MAC Address', lease.macAddress, Icons.memory),
            
            if (lease.clientId != null && lease.clientId!.isNotEmpty) ...[
              const SizedBox(height: 12),
              _buildInfoRow('Client ID', lease.clientId!, Icons.fingerprint),
            ],
            
            if (lease.comment != null && lease.comment!.isNotEmpty) ...[
              const SizedBox(height: 12),
              _buildInfoRow('Comment', lease.comment!, Icons.comment),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildRoomInfoCard(DhcpLease lease) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Informasi Ruangan',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            
            const SizedBox(height: 16),
            
            _buildInfoRow('Nama Ruangan', lease.roomName, Icons.room),
            
            if (lease.room?.ipRangeDisplay != null) ...[
              const SizedBox(height: 12),
              _buildInfoRow('IP Range', lease.room!.ipRangeDisplay!, Icons.lan),
            ],
            
            const SizedBox(height: 16),
            
            ElevatedButton.icon(
              onPressed: () {
                context.push('/rooms/${lease.roomId}');
              },
              icon: const Icon(Icons.open_in_new),
              label: const Text('Lihat Detail Ruangan'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServerInfoCard(DhcpLease lease) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Informasi Server',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            
            const SizedBox(height: 16),
            
            _buildInfoRow('DHCP Server', lease.server ?? 'Default', Icons.dns),
            
            if (lease.id != null) ...[
              const SizedBox(height: 12),
              _buildInfoRow('Lease ID', lease.id.toString(), Icons.tag),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard(DhcpLease lease) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Status & Waktu',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            
            const SizedBox(height: 16),
            
            if (lease.syncedAt != null) ...[
              _buildInfoRow('Terakhir Sync', _formatDateTime(lease.syncedAt!), Icons.sync),
              const SizedBox(height: 12),
            ],
            
            if (lease.createdAt != null) ...[
              _buildInfoRow('Dibuat', _formatDateTime(lease.createdAt!), Icons.add_circle),
              const SizedBox(height: 12),
            ],
            
            if (lease.updatedAt != null)
              _buildInfoRow('Diupdate', _formatDateTime(lease.updatedAt!), Icons.update),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBottomActions() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  if (_currentLease!.id != null) {
                    context.push('/dhcp/edit/${_currentLease!.id}');
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('DHCP lease tidak memiliki ID yang valid untuk diedit'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
                icon: const Icon(Icons.edit),
                label: const Text('Edit Lease'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.green,
                  side: const BorderSide(color: Colors.green),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _deleteLease(_currentLease!),
                icon: const Icon(Icons.delete),
                label: const Text('Hapus'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeleteConfirmationDialog(DhcpLease lease) {
    return AlertDialog(
      title: const Text('Konfirmasi Hapus'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Apakah Anda yakin ingin menghapus DHCP lease berikut?'),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('IP: ${lease.address}', style: const TextStyle(fontWeight: FontWeight.bold)),
                Text('MAC: ${lease.macAddress}'),
                if (lease.hasRoom) Text('Room: ${lease.roomName}'),
              ],
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Tindakan ini tidak dapat dibatalkan!',
            style: TextStyle(
              color: Colors.red,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Batal'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(true),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
          ),
          child: const Text('Hapus'),
        ),
      ],
    );
  }

  Color _getStatusColor(DhcpLease lease) {
    // Prioritize MikroTik status over database active status
    if (lease.status != null && lease.status!.isNotEmpty) {
      switch (lease.status!.toLowerCase()) {
        case 'bound':
          return Colors.green;
        case 'waiting':
          return Colors.orange;
        case 'offered':
          return Colors.blue;
        case 'expired':
          return Colors.red;
        default:
          return Colors.grey;
      }
    }
    
    // Fallback to active status from database
    if (lease.active != null) {
      return lease.active! ? Colors.green : Colors.red;
    }
    
    return Colors.grey;
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