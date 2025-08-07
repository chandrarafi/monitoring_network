import 'package:flutter/foundation.dart';
import '../models/room.dart';
import '../services/room_service.dart';

enum RoomState {
  initial,
  loading,
  loaded,
  error,
}

class RoomProvider with ChangeNotifier {
  RoomState _state = RoomState.initial;
  List<Room> _rooms = [];
  Room? _selectedRoom;
  String? _errorMessage;
  PaginationInfo? _pagination;
  AvailableIpsData? _availableIps;

  // Filters
  String _searchQuery = '';
  bool? _activeFilter;
  String _sortBy = 'name';
  String _sortOrder = 'asc';
  int _currentPage = 1;
  final int _perPage = 15;

  // Getters
  RoomState get state => _state;
  List<Room> get rooms => _rooms;
  Room? get selectedRoom => _selectedRoom;
  String? get errorMessage => _errorMessage;
  PaginationInfo? get pagination => _pagination;
  AvailableIpsData? get availableIps => _availableIps;
  bool get isLoading => _state == RoomState.loading;
  bool get hasError => _state == RoomState.error;

  // Filter getters
  String get searchQuery => _searchQuery;
  bool? get activeFilter => _activeFilter;
  String get sortBy => _sortBy;
  String get sortOrder => _sortOrder;
  int get currentPage => _currentPage;

  // Load rooms with filters
  Future<void> loadRooms({
    bool refresh = false,
    int? page,
  }) async {
    if (refresh) {
      _currentPage = 1;
      _rooms.clear();
    }

    if (page != null) {
      _currentPage = page;
    }

    _setState(RoomState.loading);

    try {
      final response = await RoomService.getRooms(
        active: _activeFilter,
        search: _searchQuery.isNotEmpty ? _searchQuery : null,
        sortBy: _sortBy,
        sortOrder: _sortOrder,
        perPage: _perPage,
        page: _currentPage,
      );

      if (response.success) {
        if (refresh || _currentPage == 1) {
          _rooms = response.data;
        } else {
          _rooms.addAll(response.data);
        }
        _pagination = response.pagination;
        _setState(RoomState.loaded);
      } else {
        _setError(response.message);
      }
    } catch (e) {
      _setError(_cleanErrorMessage(e.toString()));
    }
  }

  // Load room detail
  Future<void> loadRoomDetail(int id) async {
    _setState(RoomState.loading);

    try {
      final response = await RoomService.getRoomById(id);

      if (response.success && response.data != null) {
        _selectedRoom = response.data;
        _setState(RoomState.loaded);
      } else {
        _setError(response.message);
      }
    } catch (e) {
      _setError(_cleanErrorMessage(e.toString()));
    }
  }

  // Create new room
  Future<bool> createRoom({
    required String name,
    String? description,
    required String ipRangeStart,
    required String ipRangeEnd,
    String? subnetMask,
    String? gateway,
    String? dnsServer,
    bool isActive = true,
    int? capacity,
    Map<String, dynamic>? additionalInfo,
  }) async {
    _setState(RoomState.loading);

    try {
      final response = await RoomService.createRoom(
        name: name,
        description: description,
        ipRangeStart: ipRangeStart,
        ipRangeEnd: ipRangeEnd,
        subnetMask: subnetMask,
        gateway: gateway,
        dnsServer: dnsServer,
        isActive: isActive,
        capacity: capacity,
        additionalInfo: additionalInfo,
      );

      if (response.success && response.data != null) {
        // Create Room object with the correct isActive value since API response may not include it
        final newRoom = Room(
          id: response.data!.id,
          name: response.data!.name,
          description: response.data!.description,
          ipRangeStart: ipRangeStart,
          ipRangeEnd: ipRangeEnd,
          ipRangeDisplay: response.data!.ipRangeDisplay,
          totalIps: response.data!.totalIps,
          subnetMask: subnetMask,
          gateway: gateway,
          dnsServer: dnsServer,
          isActive: isActive, // Use the value we sent to API
          capacity: capacity,
          additionalInfo: additionalInfo,
          createdAt: response.data!.createdAt,
          updatedAt: response.data!.updatedAt,
        );
        
        // Add new room to the beginning of the list
        _rooms.insert(0, newRoom);
        _setState(RoomState.loaded);
        return true;
      } else {
        _setError(response.message);
        return false;
      }
    } catch (e) {
      _setError(_cleanErrorMessage(e.toString()));
      return false;
    }
  }

  // Update room
  Future<bool> updateRoom({
    required int id,
    String? name,
    String? description,
    String? ipRangeStart,
    String? ipRangeEnd,
    String? subnetMask,
    String? gateway,
    String? dnsServer,
    bool? isActive,
    int? capacity,
    Map<String, dynamic>? additionalInfo,
  }) async {
    _setState(RoomState.loading);

    try {
      final response = await RoomService.updateRoom(
        id: id,
        name: name,
        description: description,
        ipRangeStart: ipRangeStart,
        ipRangeEnd: ipRangeEnd,
        subnetMask: subnetMask,
        gateway: gateway,
        dnsServer: dnsServer,
        isActive: isActive,
        capacity: capacity,
        additionalInfo: additionalInfo,
      );

      if (response.success && response.data != null) {
        // Update room in the list
        final index = _rooms.indexWhere((room) => room.id == id);
        if (index != -1) {
          _rooms[index] = response.data!;
        }
        _selectedRoom = response.data;
        _setState(RoomState.loaded);
        return true;
      } else {
        _setError(response.message);
        return false;
      }
    } catch (e) {
      _setError(_cleanErrorMessage(e.toString()));
      return false;
    }
  }

  // Delete room
  Future<bool> deleteRoom(int id) async {
    _setState(RoomState.loading);

    try {
      final response = await RoomService.deleteRoom(id);

      if (response['success'] == true) {
        // Remove room from the list
        _rooms.removeWhere((room) => room.id == id);
        if (_selectedRoom?.id == id) {
          _selectedRoom = null;
        }
        _setState(RoomState.loaded);
        return true;
      } else {
        _setError(response['message'] ?? 'Gagal menghapus ruangan');
        return false;
      }
    } catch (e) {
      _setError(_cleanErrorMessage(e.toString()));
      return false;
    }
  }

  // Load available IPs for a room
  Future<void> loadAvailableIps(int roomId) async {
    _setState(RoomState.loading);

    try {
      final response = await RoomService.getAvailableIps(roomId);

      if (response.success) {
        _availableIps = response.data;
        _setState(RoomState.loaded);
      } else {
        _setError(response.message);
      }
    } catch (e) {
      _setError(_cleanErrorMessage(e.toString()));
    }
  }

  // Find room by IP
  Future<Room?> findRoomByIp(String ip) async {
    try {
      final response = await RoomService.findRoomByIp(ip);

      if (response.success && response.data != null) {
        return response.data!.room;
      }
      return null;
    } catch (e) {
      _setError(_cleanErrorMessage(e.toString()));
      return null;
    }
  }

  // Set search query and reload
  void setSearchQuery(String query) {
    if (_searchQuery != query) {
      _searchQuery = query;
      _currentPage = 1;
      loadRooms(refresh: true);
    }
  }

  // Set active filter and reload
  void setActiveFilter(bool? active) {
    if (_activeFilter != active) {
      _activeFilter = active;
      _currentPage = 1;
      loadRooms(refresh: true);
    }
  }

  // Set sort options and reload
  void setSortOptions(String sortBy, String sortOrder) {
    if (_sortBy != sortBy || _sortOrder != sortOrder) {
      _sortBy = sortBy;
      _sortOrder = sortOrder;
      _currentPage = 1;
      loadRooms(refresh: true);
    }
  }

  // Select room
  void selectRoom(Room? room) {
    _selectedRoom = room;
    notifyListeners();
  }

  // Clear error
  void clearError() {
    _errorMessage = null;
    if (_state == RoomState.error) {
      _setState(RoomState.initial);
    }
  }

  // Clear available IPs
  void clearAvailableIps() {
    _availableIps = null;
    notifyListeners();
  }

  // Reset filters
  void resetFilters() {
    _searchQuery = '';
    _activeFilter = null;
    _sortBy = 'name';
    _sortOrder = 'asc';
    _currentPage = 1;
    loadRooms(refresh: true);
  }

  void _setState(RoomState newState) {
    _state = newState;
    if (newState != RoomState.error) {
      _errorMessage = null;
    }
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = _cleanErrorMessage(error);
    _setState(RoomState.error);
  }

  String _cleanErrorMessage(String error) {
    String cleanError = error;
    
    if (cleanError.startsWith('Exception: ')) {
      cleanError = cleanError.substring(11);
    }
    
    if (cleanError.contains('gagal: Exception: ')) {
      cleanError = cleanError.split('gagal: Exception: ').last;
    }
    
    while (cleanError.startsWith('Exception: ')) {
      cleanError = cleanError.substring(11);
    }
    
    return cleanError.trim();
  }
}