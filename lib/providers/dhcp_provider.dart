import 'package:flutter/foundation.dart';
import '../models/dhcp_lease.dart';
import '../models/room.dart';
import '../services/dhcp_service.dart';

class DhcpUpdateResult {
  final bool success;
  final bool isFullyUpdated;
  final String statusMessage;
  final String? reason;
  final String? mikrotikError;

  const DhcpUpdateResult({
    required this.success,
    required this.isFullyUpdated,
    required this.statusMessage,
    this.reason,
    this.mikrotikError,
  });
}

class DhcpDeleteResult {
  final bool success;
  final bool isFullyDeleted;
  final String statusMessage;
  final DhcpDeletedLease? deletedLease;
  final String? reason;
  final String? mikrotikError;

  const DhcpDeleteResult({
    required this.success,
    required this.isFullyDeleted,
    required this.statusMessage,
    this.deletedLease,
    this.reason,
    this.mikrotikError,
  });
}

enum DhcpState {
  initial,
  loading,
  loaded,
  error,
}

class DhcpProvider with ChangeNotifier {
  DhcpState _state = DhcpState.initial;
  List<DhcpLease> _dhcpLeases = [];
  DhcpLease? _selectedLease;
  String? _errorMessage;
  PaginationInfo? _pagination;
  MikrotikStatus? _mikrotikStatus;
  SyncResult? _lastSyncResult;

  // Filters
  String _searchQuery = '';
  bool? _activeFilter;
  int? _roomFilter;
  String? _statusFilter;
  String _sortBy = 'address';
  String _sortOrder = 'asc';
  int _currentPage = 1;
  final int _perPage = 15;

  // Getters
  DhcpState get state => _state;
  List<DhcpLease> get dhcpLeases => _dhcpLeases;
  DhcpLease? get selectedLease => _selectedLease;
  String? get errorMessage => _errorMessage;
  PaginationInfo? get pagination => _pagination;
  MikrotikStatus? get mikrotikStatus => _mikrotikStatus;
  SyncResult? get lastSyncResult => _lastSyncResult;
  bool get isLoading => _state == DhcpState.loading;
  bool get hasError => _state == DhcpState.error;

  // Filter getters
  String get searchQuery => _searchQuery;
  bool? get activeFilter => _activeFilter;
  int? get roomFilter => _roomFilter;
  String? get statusFilter => _statusFilter;
  String get sortBy => _sortBy;
  String get sortOrder => _sortOrder;
  int get currentPage => _currentPage;

  // Load MikroTik connection status
  Future<void> loadMikrotikStatus() async {
    _setState(DhcpState.loading);

    try {
      final response = await DhcpService.getMikrotikStatus();

      if (response.success && response.routerInfo != null) {
        _mikrotikStatus = response.routerInfo;
        _setState(DhcpState.loaded);
      } else {
        _setError(response.message);
      }
    } catch (e) {
      _setError(_cleanErrorMessage(e.toString()));
    }
  }

  // Load DHCP leases from database with filters
  Future<void> loadDhcpLeases({
    bool refresh = false,
    int? page,
    bool fromMikrotik = false,
  }) async {
    if (refresh) {
      _currentPage = 1;
      _dhcpLeases.clear();
    }

    if (page != null) {
      _currentPage = page;
    }

    _setState(DhcpState.loading);

    try {
      DhcpLeaseListResponse response;

      if (fromMikrotik) {
        response = await DhcpService.getDhcpLeasesFromMikrotik();
      } else {
        response = await DhcpService.getDhcpLeasesFromDatabase(
          active: _activeFilter,
          roomId: _roomFilter,
          status: _statusFilter,
          search: _searchQuery.isNotEmpty ? _searchQuery : null,
          sortBy: _sortBy,
          sortOrder: _sortOrder,
          perPage: _perPage,
          page: _currentPage,
        );
      }

      if (response.success) {
        if (refresh || _currentPage == 1) {
          _dhcpLeases = response.data;
        } else {
          _dhcpLeases.addAll(response.data);
        }
        _pagination = response.pagination;
        _setState(DhcpState.loaded);
      } else {
        _setError(response.message);
      }
    } catch (e) {
      _setError(_cleanErrorMessage(e.toString()));
    }
  }

  // Load DHCP leases by room
  Future<void> loadDhcpLeasesByRoom(int roomId) async {
    _setState(DhcpState.loading);

    try {
      final response = await DhcpService.getDhcpLeasesByRoom(roomId);

      if (response.success) {
        _dhcpLeases = response.data;
        _pagination = response.pagination;
        _setState(DhcpState.loaded);
      } else {
        _setError(response.message);
      }
    } catch (e) {
      _setError(_cleanErrorMessage(e.toString()));
    }
  }

  // Load active DHCP leases only
  Future<void> loadActiveDhcpLeases() async {
    _setState(DhcpState.loading);

    try {
      final response = await DhcpService.getActiveDhcpLeases();

      if (response.success) {
        _dhcpLeases = response.data;
        _pagination = response.pagination;
        _setState(DhcpState.loaded);
      } else {
        _setError(response.message);
      }
    } catch (e) {
      _setError(_cleanErrorMessage(e.toString()));
    }
  }

  // Get DHCP lease by IP
  Future<DhcpLease?> getDhcpLeaseByIp(String ip) async {
    try {
      final response = await DhcpService.getDhcpLeaseByIp(ip);

      if (response.success && response.data != null) {
        return response.data;
      }
      return null;
    } catch (e) {
      _setError(_cleanErrorMessage(e.toString()));
      return null;
    }
  }

  // Get DHCP lease by MAC address
  Future<DhcpLease?> getDhcpLeaseByMac(String mac) async {
    try {
      final response = await DhcpService.getDhcpLeaseByMac(mac);

      if (response.success && response.data != null) {
        return response.data;
      }
      return null;
    } catch (e) {
      _setError(_cleanErrorMessage(e.toString()));
      return null;
    }
  }

  // Add DHCP lease
  Future<bool> addDhcpLease({
    required String address,
    required String macAddress,
    int? roomId,
    String? server,
    String? clientId,
    String? comment,
    bool disabled = false,
  }) async {
    _setState(DhcpState.loading);

    try {
      final response = await DhcpService.addDhcpLease(
        address: address,
        macAddress: macAddress,
        roomId: roomId,
        server: server,
        clientId: clientId,
        comment: comment,
        disabled: disabled,
      );

      if (response.success && response.data != null) {
        // Add new lease to the beginning of the list
        _dhcpLeases.insert(0, response.data!);
        _setState(DhcpState.loaded);
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

  // Update DHCP lease
  Future<DhcpUpdateResult> updateDhcpLease({
    required String id,
    String? address,
    String? macAddress,
    int? roomId,
    String? server,
    String? clientId,
    String? comment,
    bool? disabled,
  }) async {
    _setState(DhcpState.loading);

    try {
      final response = await DhcpService.updateDhcpLease(
        id: id,
        address: address,
        macAddress: macAddress,
        roomId: roomId,
        server: server,
        clientId: clientId,
        comment: comment,
        disabled: disabled,
      );

      if (response.success) {
        // Update lease in the list - need to refresh or construct updated lease
        await loadDhcpLeases(refresh: true);
        
        _setState(DhcpState.loaded);
        return DhcpUpdateResult(
          success: true,
          isFullyUpdated: response.data.isMikrotikUpdated,
          statusMessage: response.data.statusMessage,
          reason: response.data.reason,
          mikrotikError: response.data.mikrotikError,
        );
      } else {
        _setError(response.message);
        return DhcpUpdateResult(
          success: false,
          isFullyUpdated: false,
          statusMessage: response.message,
        );
      }
    } catch (e) {
      final errorMessage = _cleanErrorMessage(e.toString());
      _setError(errorMessage);
      return DhcpUpdateResult(
        success: false,
        isFullyUpdated: false,
        statusMessage: errorMessage,
      );
    }
  }

  // Delete DHCP lease
  Future<DhcpDeleteResult> deleteDhcpLease(String id) async {
    _setState(DhcpState.loading);

    try {
      final response = await DhcpService.deleteDhcpLease(id);

      if (response.success) {
        // Remove lease from the list
        _dhcpLeases.removeWhere((lease) => lease.id?.toString() == id);
        if (_selectedLease?.id?.toString() == id) {
          _selectedLease = null;
        }
        _setState(DhcpState.loaded);
        
        return DhcpDeleteResult(
          success: true,
          isFullyDeleted: response.data.isFullyDeleted,
          statusMessage: response.data.statusMessage,
          deletedLease: response.data.deletedLease,
          reason: response.data.reason,
          mikrotikError: response.data.mikrotikError,
        );
      } else {
        _setError(response.message);
        return DhcpDeleteResult(
          success: false,
          isFullyDeleted: false,
          statusMessage: response.message,
        );
      }
    } catch (e) {
      final errorMessage = _cleanErrorMessage(e.toString());
      _setError(errorMessage);
      return DhcpDeleteResult(
        success: false,
        isFullyDeleted: false,
        statusMessage: errorMessage,
      );
    }
  }

  // Sync DHCP leases from MikroTik
  Future<bool> syncDhcpLeases() async {
    _setState(DhcpState.loading);

    try {
      final response = await DhcpService.syncDhcpLeases();

      if (response.success) {
        _lastSyncResult = response.data;
        // Reload leases after sync
        await loadDhcpLeases(refresh: true);
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

  // Set search query and reload
  void setSearchQuery(String query) {
    if (_searchQuery != query) {
      _searchQuery = query;
      _currentPage = 1;
      loadDhcpLeases(refresh: true);
    }
  }

  // Set active filter and reload
  void setActiveFilter(bool? active) {
    if (_activeFilter != active) {
      _activeFilter = active;
      _currentPage = 1;
      loadDhcpLeases(refresh: true);
    }
  }

  // Set room filter and reload
  void setRoomFilter(int? roomId) {
    if (_roomFilter != roomId) {
      _roomFilter = roomId;
      _currentPage = 1;
      loadDhcpLeases(refresh: true);
    }
  }

  // Set status filter and reload
  void setStatusFilter(String? status) {
    if (_statusFilter != status) {
      _statusFilter = status;
      _currentPage = 1;
      loadDhcpLeases(refresh: true);
    }
  }

  // Set sort options and reload
  void setSortOptions(String sortBy, String sortOrder) {
    if (_sortBy != sortBy || _sortOrder != sortOrder) {
      _sortBy = sortBy;
      _sortOrder = sortOrder;
      _currentPage = 1;
      loadDhcpLeases(refresh: true);
    }
  }

  // Select lease
  void selectLease(DhcpLease? lease) {
    _selectedLease = lease;
    notifyListeners();
  }

  // Clear error
  void clearError() {
    _errorMessage = null;
    if (_state == DhcpState.error) {
      _setState(DhcpState.initial);
    }
  }

  // Reset filters
  void resetFilters() {
    _searchQuery = '';
    _activeFilter = null;
    _roomFilter = null;
    _statusFilter = null;
    _sortBy = 'address';
    _sortOrder = 'asc';
    _currentPage = 1;
    loadDhcpLeases(refresh: true);
  }

  void _setState(DhcpState newState) {
    _state = newState;
    if (newState != DhcpState.error) {
      _errorMessage = null;
    }
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = _cleanErrorMessage(error);
    _setState(DhcpState.error);
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