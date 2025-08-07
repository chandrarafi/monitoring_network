import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/room_provider.dart';
import '../../models/room.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/error_message_widget.dart';

class RoomFormScreen extends StatefulWidget {
  final String? roomId;

  const RoomFormScreen({
    super.key,
    this.roomId,
  });

  bool get isEditMode => roomId != null;

  @override
  State<RoomFormScreen> createState() => _RoomFormScreenState();
}

class _RoomFormScreenState extends State<RoomFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _ipRangeStartController = TextEditingController();
  final _ipRangeEndController = TextEditingController();



  bool _isActive = true;
  Room? _currentRoom;

  @override
  void initState() {
    super.initState();
    if (widget.isEditMode) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _loadRoomData();
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _ipRangeStartController.dispose();
    _ipRangeEndController.dispose();
    super.dispose();
  }

  void _loadRoomData() {
    final roomProvider = context.read<RoomProvider>();
    final roomId = int.tryParse(widget.roomId!);
    
    if (roomId != null) {
      roomProvider.loadRoomDetail(roomId).then((_) {
        final room = roomProvider.selectedRoom;
        if (room != null && mounted) {
          _populateForm(room);
        }
      });
    }
  }

  void _populateForm(Room room) {
    setState(() {
      _currentRoom = room;
      _nameController.text = room.name;
      _descriptionController.text = room.description ?? '';
      _ipRangeStartController.text = room.ipRangeStart ?? '';
      _ipRangeEndController.text = room.ipRangeEnd ?? '';
      _isActive = room.isActive ?? true;
    });
  }

  String? _validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName tidak boleh kosong';
    }
    return null;
  }

  String? _validateIP(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName tidak boleh kosong';
    }
    
    final ipRegex = RegExp(r'^(\d{1,3}\.){3}\d{1,3}$');
    if (!ipRegex.hasMatch(value.trim())) {
      return '$fieldName harus berformat IP yang valid (contoh: 192.168.1.1)';
    }
    
    final parts = value.trim().split('.');
    for (final part in parts) {
      final num = int.tryParse(part);
      if (num == null || num < 0 || num > 255) {
        return '$fieldName tidak valid (setiap oktet harus 0-255)';
      }
    }
    
    return null;
  }





  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    final roomProvider = context.read<RoomProvider>();
    
    bool success;
    
    if (widget.isEditMode && _currentRoom != null) {
      // Update existing room
      success = await roomProvider.updateRoom(
        id: _currentRoom!.id,
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim().isNotEmpty 
            ? _descriptionController.text.trim() : null,
        ipRangeStart: _ipRangeStartController.text.trim(),
        ipRangeEnd: _ipRangeEndController.text.trim(),
        subnetMask: null,
        gateway: null,
        dnsServer: null,
        isActive: _isActive,
        capacity: null,
        additionalInfo: null,
      );
    } else {
      // Create new room
      success = await roomProvider.createRoom(
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim().isNotEmpty 
            ? _descriptionController.text.trim() : null,
        ipRangeStart: _ipRangeStartController.text.trim(),
        ipRangeEnd: _ipRangeEndController.text.trim(),
        subnetMask: null,
        gateway: null,
        dnsServer: null,
        isActive: _isActive,
        capacity: null,
        additionalInfo: null,
      );
    }

    if (mounted) {
      if (success) {
        // Clear any previous errors
        roomProvider.clearError();
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.isEditMode 
                ? 'Ruangan berhasil diperbarui' 
                : 'Ruangan berhasil dibuat'),
            backgroundColor: Colors.green,
          ),
        );
        context.pop();
      }
      // Error will be shown by ErrorMessageWidget
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          widget.isEditMode ? 'Edit Ruangan' : 'Tambah Ruangan',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.blue,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.pop(),
        ),
      ),
      body: Consumer<RoomProvider>(
        builder: (context, roomProvider, child) {
          if (widget.isEditMode && roomProvider.isLoading && _currentRoom == null) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Error Message
                  if (roomProvider.hasError)
                    ErrorMessageWidget(
                      message: roomProvider.errorMessage ?? 'Terjadi kesalahan',
                      onDismiss: () {
                        roomProvider.clearError();
                      },
                    ),

                  // Basic Information Card
                  _buildCard(
                    'Informasi Dasar',
                    [
                      CustomTextField(
                        label: 'Nama Ruangan *',
                        controller: _nameController,
                        prefixIcon: Icons.room,
                        validator: (value) => _validateRequired(value, 'Nama ruangan'),
                      ),
                      const SizedBox(height: 16),
                      CustomTextField(
                        label: 'Deskripsi',
                        controller: _descriptionController,
                        prefixIcon: Icons.description,
                        keyboardType: TextInputType.multiline,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          const Text(
                            'Status Ruangan',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Colors.black87,
                            ),
                          ),
                          const Spacer(),
                          Switch(
                            value: _isActive,
                            onChanged: (value) {
                              setState(() {
                                _isActive = value;
                              });
                            },
                            activeColor: Colors.green,
                          ),
                          Text(
                            _isActive ? 'Aktif' : 'Tidak Aktif',
                            style: TextStyle(
                              color: _isActive ? Colors.green : Colors.red,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // IP Range Configuration Card
                  _buildCard(
                    'Konfigurasi IP Range',
                    [
                      CustomTextField(
                        label: 'IP Range Start *',
                        controller: _ipRangeStartController,
                        prefixIcon: Icons.router,
                        keyboardType: TextInputType.number,
                        validator: (value) => _validateIP(value, 'IP Range Start'),
                        hintText: '192.168.1.10',
                      ),
                      const SizedBox(height: 16),
                      CustomTextField(
                        label: 'IP Range End *',
                        controller: _ipRangeEndController,
                        prefixIcon: Icons.router_outlined,
                        keyboardType: TextInputType.number,
                        validator: (value) => _validateIP(value, 'IP Range End'),
                        hintText: '192.168.1.50',
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),

                  // Submit Button
                  CustomButton(
                    text: widget.isEditMode ? 'Perbarui Ruangan' : 'Buat Ruangan',
                    onPressed: _handleSubmit,
                    isLoading: roomProvider.isLoading,
                    icon: widget.isEditMode ? Icons.update : Icons.add,
                  ),

                  const SizedBox(height: 16),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCard(String title, List<Widget> children) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }
}