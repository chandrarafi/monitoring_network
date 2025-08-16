import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/dhcp_provider.dart';
import '../../providers/room_provider.dart';
import '../../models/dhcp_lease.dart';
import '../../models/room.dart';
import '../../widgets/error_message_widget.dart';

class DhcpFormScreen extends StatefulWidget {
  final String? leaseId;
  final bool isEditMode;

  const DhcpFormScreen({
    super.key,
    this.leaseId,
    this.isEditMode = false,
  });

  @override
  State<DhcpFormScreen> createState() => _DhcpFormScreenState();
}

class _DhcpFormScreenState extends State<DhcpFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _addressController = TextEditingController();
  final _macAddressController = TextEditingController();
  final _clientIdController = TextEditingController();
  final _commentController = TextEditingController();
  final _serverController = TextEditingController();

  int? _selectedRoomId;
  bool _isDisabled = false;
  DhcpLease? _currentLease;
  DhcpUpdateResult? _updateResult;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RoomProvider>().loadRooms(refresh: true);
      
      if (widget.isEditMode && widget.leaseId != null) {
        _loadLeaseData();
      }
    });
  }

  void _loadLeaseData() {
    final dhcpProvider = context.read<DhcpProvider>();
    try {
      final lease = dhcpProvider.dhcpLeases.firstWhere(
        (lease) => lease.id.toString() == widget.leaseId,
      );
      _populateForm(lease);
    } catch (e) {
      // If lease not found in provider, show error
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('DHCP lease tidak ditemukan'),
          backgroundColor: Colors.red,
        ),
      );
      context.pop();
    }
  }

  void _populateForm(DhcpLease lease) {
    setState(() {
      _currentLease = lease;
      _addressController.text = lease.address;
      _macAddressController.text = lease.macAddress;
      _clientIdController.text = lease.clientId ?? '';
      _commentController.text = lease.comment ?? '';
      _serverController.text = lease.server ?? '';
      _selectedRoomId = lease.roomId;
      _isDisabled = lease.disabled;
    });
  }

  @override
  void dispose() {
    _addressController.dispose();
    _macAddressController.dispose();
    _clientIdController.dispose();
    _commentController.dispose();
    _serverController.dispose();
    super.dispose();
  }



  String? _validateIP(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'IP Address tidak boleh kosong';
    }
    
    final ipRegex = RegExp(r'^(\d{1,3}\.){3}\d{1,3}$');
    if (!ipRegex.hasMatch(value.trim())) {
      return 'Format IP Address tidak valid (contoh: 192.168.1.100)';
    }
    
    // Validate IP octets
    final octets = value.trim().split('.');
    for (final octet in octets) {
      final num = int.tryParse(octet);
      if (num == null || num < 0 || num > 255) {
        return 'IP Address tidak valid (0-255 untuk setiap oktet)';
      }
    }
    
    return null;
  }

  String? _validateMAC(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'MAC Address tidak boleh kosong';
    }
    
    final macRegex = RegExp(r'^([0-9A-Fa-f]{2}[:-]){5}([0-9A-Fa-f]{2})$');
    if (!macRegex.hasMatch(value.trim())) {
      return 'Format MAC Address tidak valid (contoh: AA:BB:CC:DD:EE:FF)';
    }
    
    return null;
  }

  Future<String?> _validateForDuplicates() async {
    final dhcpProvider = context.read<DhcpProvider>();
    final ipAddress = _addressController.text.trim();
    final macAddress = _macAddressController.text.trim();
    
    try {
      // Check existing leases in current provider data first (faster)
      final existingLeases = dhcpProvider.dhcpLeases;
      
      // Check for duplicate IP in loaded data
      final ipMatches = existingLeases.where((lease) => 
        lease.address == ipAddress && lease.id != _currentLease?.id);
      if (ipMatches.isNotEmpty) {
        final existingIpLease = ipMatches.first;
        return 'IP Address $ipAddress sudah digunakan oleh lease lain (MAC: ${existingIpLease.macAddress})';
      }
      
      // Check for duplicate MAC in loaded data
      final macMatches = existingLeases.where((lease) => 
        lease.macAddress.toLowerCase() == macAddress.toLowerCase() && lease.id != _currentLease?.id);
      if (macMatches.isNotEmpty) {
        final existingMacLease = macMatches.first;
        return 'MAC Address $macAddress sudah digunakan oleh lease lain (IP: ${existingMacLease.address})';
      }
      
      return null; // No duplicates found
    } catch (e) {
      // If validation fails, allow the submit to proceed and let server handle it
      print('Duplicate validation failed: $e');
      return null;
    }
  }

  String _getCleanErrorMessage(String errorMessage) {
    String cleanMessage = errorMessage;
    
    // Remove nested "Exception:" prefixes
    while (cleanMessage.startsWith('Exception: ')) {
      cleanMessage = cleanMessage.substring(11);
    }
    
    // Remove common prefixes
    final prefixesToRemove = [
      'Gagal menambahkan DHCP lease: ',
      'Gagal mengambil DHCP lease berdasarkan IP: ',
      'Gagal mengambil DHCP lease berdasarkan MAC: ',
      'Terjadi kesalahan: ',
    ];
    
    for (final prefix in prefixesToRemove) {
      if (cleanMessage.startsWith(prefix)) {
        cleanMessage = cleanMessage.substring(prefix.length);
        break;
      }
    }
    
    // Handle HTML response errors (server returning HTML instead of JSON)
    if (cleanMessage.contains('FormatException: Unexpected character') ||
        cleanMessage.contains('</html>') ||
        cleanMessage.contains('<html>')) {
      return 'Server sedang bermasalah. Silakan coba lagi dalam beberapa saat';
    }
    
    // Handle JSON parsing errors
    if (cleanMessage.toLowerCase().contains('formatexception') ||
        cleanMessage.toLowerCase().contains('unexpected character')) {
      return 'Server mengembalikan response yang tidak valid. Silakan coba lagi';
    }
    
    // Handle common database constraint errors
    if (cleanMessage.toLowerCase().contains('duplicate') || 
        cleanMessage.toLowerCase().contains('unique constraint')) {
      if (cleanMessage.toLowerCase().contains('address')) {
        return 'IP Address sudah digunakan oleh lease lain';
      }
      if (cleanMessage.toLowerCase().contains('mac_address')) {
        return 'MAC Address sudah digunakan oleh lease lain';
      }
      return 'Data sudah ada. Silakan gunakan IP Address atau MAC Address yang berbeda';
    }
    
    // Handle HTTP status errors
    if (cleanMessage.contains('401') || cleanMessage.toLowerCase().contains('unauthorized')) {
      return 'Session expired. Silakan login kembali';
    }
    
    if (cleanMessage.contains('403') || cleanMessage.toLowerCase().contains('forbidden')) {
      return 'Tidak memiliki akses untuk operasi ini';
    }
    
    if (cleanMessage.contains('404') || cleanMessage.toLowerCase().contains('not found')) {
      return 'Endpoint tidak ditemukan. Silakan hubungi administrator';
    }
    
    if (cleanMessage.contains('500') || cleanMessage.toLowerCase().contains('internal server error')) {
      return 'Server error. Silakan coba lagi nanti';
    }
    
    // Handle connection errors
    if (cleanMessage.toLowerCase().contains('connection') ||
        cleanMessage.toLowerCase().contains('network') ||
        cleanMessage.toLowerCase().contains('timeout')) {
      return 'Koneksi bermasalah. Silakan coba lagi';
    }
    
    // Default cleaned message
    return cleanMessage.isNotEmpty ? cleanMessage : 'Terjadi kesalahan tidak diketahui';
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    final dhcpProvider = context.read<DhcpProvider>();
    
    // Validate for duplicates before submitting (only for new leases)
    if (!widget.isEditMode) {
      // Show loading indicator while validating
      dhcpProvider.clearError();
      
      final duplicateValidationResult = await _validateForDuplicates();
      if (duplicateValidationResult != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ $duplicateValidationResult'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
        return;
      }
    }
    
    bool success;
    
    if (widget.isEditMode && _currentLease != null) {
      // Check if lease has valid ID for update
      if (_currentLease!.id == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('DHCP lease tidak memiliki ID yang valid untuk diupdate'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      
      // Update existing lease
      final updateResult = await dhcpProvider.updateDhcpLease(
        id: _currentLease!.id!.toString(),
        address: _addressController.text.trim(),
        macAddress: _macAddressController.text.trim(),
        roomId: _selectedRoomId,
        server: _serverController.text.trim().isNotEmpty 
            ? _serverController.text.trim() : null,
        clientId: _clientIdController.text.trim().isNotEmpty 
            ? _clientIdController.text.trim() : null,
        comment: _commentController.text.trim().isNotEmpty 
            ? _commentController.text.trim() : null,
        disabled: _isDisabled,
      );
      
      success = updateResult.success;
      _updateResult = updateResult;
    } else {
      // Create new lease
      success = await dhcpProvider.addDhcpLease(
        address: _addressController.text.trim(),
        macAddress: _macAddressController.text.trim(),
        roomId: _selectedRoomId,
        server: _serverController.text.trim().isNotEmpty 
            ? _serverController.text.trim() : null,
        clientId: _clientIdController.text.trim().isNotEmpty 
            ? _clientIdController.text.trim() : null,
        comment: _commentController.text.trim().isNotEmpty 
            ? _commentController.text.trim() : null,
        disabled: _isDisabled,
      );
    }

    if (mounted) {
      if (success) {
        dhcpProvider.clearError();
        
        if (widget.isEditMode && _updateResult != null) {
          // Show different messages based on update location
          final icon = _updateResult!.isFullyUpdated ? '✅' : '⚠️';
          final color = _updateResult!.isFullyUpdated ? Colors.green : Colors.orange;
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('$icon ${_updateResult!.statusMessage} (otomatis disinkronisasi)'),
              backgroundColor: color,
              duration: const Duration(seconds: 4),
            ),
          );
          
          // Show additional info if database only
          if (!_updateResult!.isFullyUpdated && _updateResult!.reason != null) {
            Future.delayed(const Duration(seconds: 1), () {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Info: ${_updateResult!.reason}'),
                    backgroundColor: Colors.blue,
                    duration: const Duration(seconds: 3),
                  ),
                );
              }
            });
          }
        } else {
          // Create success message with auto sync info
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ DHCP lease berhasil ditambahkan dan disinkronisasi ke MikroTik'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 4),
            ),
          );
        }
        
        context.go('/dhcp'); // Navigate back to DHCP list
      } else {
        // Show more detailed error message
        final errorMessage = widget.isEditMode && _updateResult != null
            ? _updateResult!.statusMessage
            : dhcpProvider.errorMessage ?? "Unknown error";
        
        // Clean up the error message for better user experience
        String cleanErrorMessage = _getCleanErrorMessage(errorMessage);
            
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.isEditMode 
                ? '❌ Gagal memperbarui DHCP lease: $cleanErrorMessage'
                : '❌ Gagal menambahkan DHCP lease: $cleanErrorMessage'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
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
        title: Text(
          widget.isEditMode ? 'Edit DHCP Lease' : 'Tambah DHCP Lease',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.green,
        elevation: 0,
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

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Network Information Card
                        _buildNetworkInfoCard(),
                        
                        const SizedBox(height: 16),
                        
                        // Room Selection Card
                        _buildRoomSelectionCard(),
                        
                        const SizedBox(height: 16),
                        
                        // Server & Client Info Card
                        _buildServerInfoCard(),
                        
                        const SizedBox(height: 16),
                        
                        // Additional Options Card
                        _buildOptionsCard(),
                        
                        const SizedBox(height: 24),
                        
                        // Submit Button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: dhcpProvider.isLoading ? null : _handleSubmit,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: dhcpProvider.isLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                    ),
                                  )
                                : Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(widget.isEditMode ? Icons.save : Icons.add),
                                      const SizedBox(width: 8),
                                      Text(
                                        widget.isEditMode ? 'Update Lease' : 'Tambah Lease',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildNetworkInfoCard() {
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
            
            // IP Address
            TextFormField(
              controller: _addressController,
              decoration: const InputDecoration(
                labelText: 'IP Address *',
                hintText: 'Contoh: 192.168.1.100',
                prefixIcon: Icon(Icons.language),
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              validator: _validateIP,
              keyboardType: TextInputType.number,
            ),
            
            const SizedBox(height: 16),
            
            // MAC Address
            TextFormField(
              controller: _macAddressController,
              decoration: const InputDecoration(
                labelText: 'MAC Address *',
                hintText: 'Contoh: AA:BB:CC:DD:EE:FF',
                prefixIcon: Icon(Icons.memory),
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              validator: _validateMAC,
              textCapitalization: TextCapitalization.characters,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoomSelectionCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Ruangan',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            
            const SizedBox(height: 16),
            
            Consumer<RoomProvider>(
              builder: (context, roomProvider, child) {
                final activeRooms = roomProvider.rooms.where((room) => room.isActive ?? false).toList();
                
                return DropdownButtonFormField<int?>(
                  value: _selectedRoomId,
                  decoration: const InputDecoration(
                    labelText: 'Pilih Ruangan (Opsional)',
                    prefixIcon: Icon(Icons.room),
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  items: [
                    const DropdownMenuItem<int?>(
                      value: null,
                      child: Text('Tidak ada ruangan'),
                    ),
                    ...activeRooms.map((room) => DropdownMenuItem<int?>(
                      value: room.id,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(room.name),
                          if (room.ipRangeDisplay != null)
                            Text(
                              room.ipRangeDisplay!,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                        ],
                      ),
                    )),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedRoomId = value;
                    });
                  },
                );
              },
            ),
            
            if (_selectedRoomId != null) ...[
              const SizedBox(height: 12),
              Consumer<RoomProvider>(
                builder: (context, roomProvider, child) {
                  final selectedRoom = roomProvider.rooms.firstWhere(
                    (room) => room.id == _selectedRoomId,
                    orElse: () => Room(id: 0, name: 'Unknown', isActive: true),
                  );
                  
                  return Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue, width: 1),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Info Ruangan: ${selectedRoom.name}',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Colors.blue[700],
                          ),
                        ),
                        if (selectedRoom.ipRangeDisplay != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            'IP Range: ${selectedRoom.ipRangeDisplay}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.blue[600],
                            ),
                          ),
                        ],
                      ],
                    ),
                  );
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildServerInfoCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Informasi Server & Client',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            
            const SizedBox(height: 16),
            
            // DHCP Server
            TextFormField(
              controller: _serverController,
              decoration: const InputDecoration(
                labelText: 'DHCP Server (Opsional)',
                hintText: 'Contoh: dhcp1',
                prefixIcon: Icon(Icons.dns),
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Client ID
            TextFormField(
              controller: _clientIdController,
              decoration: const InputDecoration(
                labelText: 'Client ID (Opsional)',
                hintText: 'Client identifier',
                prefixIcon: Icon(Icons.fingerprint),
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Comment
            TextFormField(
              controller: _commentController,
              decoration: const InputDecoration(
                labelText: 'Comment (Opsional)',
                hintText: 'Deskripsi atau keterangan',
                prefixIcon: Icon(Icons.comment),
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              maxLines: 2,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionsCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Opsi Tambahan',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Disabled toggle
            SwitchListTile(
              title: const Text('Disabled'),
              subtitle: const Text('Nonaktifkan lease ini'),
              value: _isDisabled,
              onChanged: (value) {
                setState(() {
                  _isDisabled = value;
                });
              },
              contentPadding: EdgeInsets.zero,
            ),
          ],
        ),
      ),
    );
  }
}