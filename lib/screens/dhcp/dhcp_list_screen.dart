import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/dhcp_provider.dart';
import '../../providers/room_provider.dart';
import '../../models/dhcp_lease.dart';
import '../../models/room.dart';
import '../../utils/responsive_helper.dart';
import '../../widgets/error_message_widget.dart';

class DhcpListScreen extends StatefulWidget {
  const DhcpListScreen({super.key});

  @override
  State<DhcpListScreen> createState() => _DhcpListScreenState();
}

class _DhcpListScreenState extends State<DhcpListScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DhcpProvider>().loadDhcpLeases(refresh: true);
      context.read<DhcpProvider>().loadMikrotikStatus();
      context.read<RoomProvider>().loadRooms(refresh: true);
    });

    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      final dhcpProvider = context.read<DhcpProvider>();
      final pagination = dhcpProvider.pagination;
      
      if (pagination != null && 
          pagination.currentPage < pagination.lastPage &&
          !dhcpProvider.isLoading) {
        dhcpProvider.loadDhcpLeases(page: pagination.currentPage + 1);
      }
    }
  }

  void _onSearchChanged(String value) {
    // Debounce search
    Future.delayed(const Duration(milliseconds: 500), () {
      if (_searchController.text == value && mounted) {
        context.read<DhcpProvider>().setSearchQuery(value);
      }
    });
  }

  Future<void> _syncDhcpLeases() async {
    final dhcpProvider = context.read<DhcpProvider>();
    final success = await dhcpProvider.syncDhcpLeases();
    
    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('DHCP leases berhasil disinkronkan'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Gagal menyinkronkan DHCP leases'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'DHCP Management',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.green,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () {
              context.read<DhcpProvider>().loadDhcpLeases(refresh: true);
            },
          ),
          IconButton(
            icon: const Icon(Icons.sync, color: Colors.white),
            onPressed: _syncDhcpLeases,
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onSelected: (value) {
              switch (value) {
                case 'mikrotik_status':
                  _showMikrotikStatus();
                  break;
                case 'from_mikrotik':
                  context.read<DhcpProvider>().loadDhcpLeases(refresh: true, fromMikrotik: true);
                  break;
                case 'active_only':
                  context.read<DhcpProvider>().loadActiveDhcpLeases();
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'mikrotik_status',
                child: Row(
                  children: [
                    Icon(Icons.info_outline),
                    SizedBox(width: 8),
                    Text('Status MikroTik'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'from_mikrotik',
                child: Row(
                  children: [
                    Icon(Icons.router),
                    SizedBox(width: 8),
                    Text('Load dari MikroTik'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'active_only',
                child: Row(
                  children: [
                    Icon(Icons.wifi),
                    SizedBox(width: 8),
                    Text('Hanya yang Aktif'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Consumer<DhcpProvider>(
        builder: (context, dhcpProvider, child) {
          return Column(
            children: [
              // Error Message
              ErrorMessageWidget(
                message: dhcpProvider.errorMessage,
                onDismiss: () => dhcpProvider.clearError(),
              ),
              
              // Search and Filters
              _buildFiltersSection(dhcpProvider),
              
              // DHCP Leases List
              Expanded(
                child: dhcpProvider.isLoading && dhcpProvider.dhcpLeases.isEmpty
                    ? const Center(child: CircularProgressIndicator())
                    : dhcpProvider.dhcpLeases.isEmpty
                        ? _buildEmptyState()
                        : _buildLeasesList(dhcpProvider),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.push('/dhcp/add');
        },
        backgroundColor: Colors.green,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildFiltersSection(DhcpProvider dhcpProvider) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Column(
        children: [
          // Search
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Cari berdasarkan IP, MAC, atau comment...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            onChanged: _onSearchChanged,
          ),
          
          const SizedBox(height: 12),
          
          // Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                Consumer<RoomProvider>(
                  builder: (context, roomProvider, child) {
                    return _buildRoomFilter(dhcpProvider, roomProvider.rooms);
                  },
                ),
                const SizedBox(width: 8),
                _buildStatusFilter(dhcpProvider),
                const SizedBox(width: 8),
                _buildActiveFilter(dhcpProvider),
                const SizedBox(width: 8),
                _buildResetFiltersChip(dhcpProvider),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoomFilter(DhcpProvider dhcpProvider, List<Room> rooms) {
    return PopupMenuButton<int?>(
      child: Chip(
        label: Text(dhcpProvider.roomFilter != null 
            ? 'Room: ${rooms.firstWhere((r) => r.id == dhcpProvider.roomFilter, orElse: () => Room(id: 0, name: 'Unknown', isActive: true)).name}'
            : 'Semua Room'),
        deleteIcon: dhcpProvider.roomFilter != null ? const Icon(Icons.close, size: 18) : null,
        onDeleted: dhcpProvider.roomFilter != null 
            ? () => dhcpProvider.setRoomFilter(null)
            : null,
      ),
      onSelected: (roomId) => dhcpProvider.setRoomFilter(roomId),
      itemBuilder: (context) => [
        const PopupMenuItem<int?>(
          value: null,
          child: Text('Semua Room'),
        ),
        ...rooms.map((room) => PopupMenuItem<int>(
          value: room.id,
          child: Text(room.name),
        )),
      ],
    );
  }

  Widget _buildStatusFilter(DhcpProvider dhcpProvider) {
    final statusOptions = ['bound', 'waiting', 'offered', 'expired'];
    
    return PopupMenuButton<String?>(
      child: Chip(
        label: Text(dhcpProvider.statusFilter ?? 'Semua Status'),
        deleteIcon: dhcpProvider.statusFilter != null ? const Icon(Icons.close, size: 18) : null,
        onDeleted: dhcpProvider.statusFilter != null 
            ? () => dhcpProvider.setStatusFilter(null)
            : null,
      ),
      onSelected: (status) => dhcpProvider.setStatusFilter(status),
      itemBuilder: (context) => [
        const PopupMenuItem<String?>(
          value: null,
          child: Text('Semua Status'),
        ),
        ...statusOptions.map((status) => PopupMenuItem<String>(
          value: status,
          child: Text(status.toUpperCase()),
        )),
      ],
    );
  }

  Widget _buildActiveFilter(DhcpProvider dhcpProvider) {
    return FilterChip(
      label: const Text('Aktif Saja'),
      selected: dhcpProvider.activeFilter == true,
      onSelected: (selected) {
        dhcpProvider.setActiveFilter(selected ? true : null);
      },
    );
  }

  Widget _buildResetFiltersChip(DhcpProvider dhcpProvider) {
    final hasFilters = dhcpProvider.searchQuery.isNotEmpty ||
        dhcpProvider.activeFilter != null ||
        dhcpProvider.roomFilter != null ||
        dhcpProvider.statusFilter != null;

    if (!hasFilters) return const SizedBox.shrink();

    return ActionChip(
      label: const Text('Reset Filter'),
      avatar: const Icon(Icons.clear_all, size: 18),
      onPressed: () {
        _searchController.clear();
        dhcpProvider.resetFilters();
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.settings_ethernet,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Belum ada DHCP lease',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tambah DHCP lease atau sinkronkan dari MikroTik',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _syncDhcpLeases,
            icon: const Icon(Icons.sync),
            label: const Text('Sync dari MikroTik'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLeasesList(DhcpProvider dhcpProvider) {
    return RefreshIndicator(
      onRefresh: () => dhcpProvider.loadDhcpLeases(refresh: true),
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(16),
        itemCount: dhcpProvider.dhcpLeases.length + 
            (dhcpProvider.isLoading ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == dhcpProvider.dhcpLeases.length) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: CircularProgressIndicator(),
              ),
            );
          }

          final lease = dhcpProvider.dhcpLeases[index];
          return _buildLeaseCard(lease);
        },
      ),
    );
  }

  Widget _buildLeaseCard(DhcpLease lease) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          context.push('/dhcp/detail/${lease.id ?? 0}');
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with IP and Status
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      lease.address,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: _getStatusColor(lease),
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // MAC Address
              Row(
                children: [
                  Icon(Icons.memory, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 8),
                  Text(
                    lease.macAddress,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
                      fontFamily: 'monospace',
                    ),
                  ),
                ],
              ),
              
              // Room info
              if (lease.hasRoom) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.room, size: 16, color: Colors.blue[600]),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        lease.roomName,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.blue[700],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
              
              // Comment
              if (lease.comment != null && lease.comment!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.comment, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        lease.comment!,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
              
              const SizedBox(height: 12),
              
              // Additional info chips
              Row(
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
                  if (lease.isDisabled) ...[
                    const SizedBox(width: 8),
                    Chip(
                      label: const Text('Disabled'),
                      backgroundColor: Colors.red.withValues(alpha: 0.1),
                      labelStyle: TextStyle(
                        fontSize: 12,
                        color: Colors.red[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                  if (lease.dynamicLease) ...[
                    const SizedBox(width: 8),
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
                ],
              ),
            ],
          ),
        ),
      ),
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

  void _showMikrotikStatus() {
    final dhcpProvider = context.read<DhcpProvider>();
    final status = dhcpProvider.mikrotikStatus;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Status Koneksi MikroTik'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (status != null) ...[
              Text('Host: ${status.host}'),
              Text('Port: ${status.port}'),
              Text('Username: ${status.username}'),
              const SizedBox(height: 16),
              const Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.green),
                  SizedBox(width: 8),
                  Text('Terhubung'),
                ],
              ),
            ] else ...[
              const Row(
                children: [
                  Icon(Icons.error, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Tidak terhubung'),
                ],
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Tutup'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.read<DhcpProvider>().loadMikrotikStatus();
            },
            child: const Text('Refresh'),
          ),
        ],
      ),
    );
  }
}