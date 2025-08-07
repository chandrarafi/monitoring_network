import 'package:flutter/foundation.dart';
import '../models/monitoring.dart';
import '../services/monitoring_service.dart';

enum MonitoringState { initial, loading, loaded, error }

class MonitoringProvider with ChangeNotifier {
  // State management
  MonitoringState _state = MonitoringState.initial;
  String? _errorMessage;

  // Dashboard data
  MonitoringDashboardData? _dashboardData;
  
  // Real-time monitoring data
  RealtimeMonitoringResponseData? _realtimeData;
  
  // Alerts data
  AlertsResponseData? _alertsData;
  
  // Room detail data
  Map<int, RoomDetailData> _roomDetails = {};
  
  // Analytics data
  AnalyticsData? _analyticsData;
  String _currentPeriod = '24h';

  // Auto-refresh settings
  bool _autoRefreshEnabled = false;
  
  // Getters
  MonitoringState get state => _state;
  String? get errorMessage => _errorMessage;
  MonitoringDashboardData? get dashboardData => _dashboardData;
  RealtimeMonitoringResponseData? get realtimeData => _realtimeData;
  AlertsResponseData? get alertsData => _alertsData;
  Map<int, RoomDetailData> get roomDetails => _roomDetails;
  AnalyticsData? get analyticsData => _analyticsData;
  String get currentPeriod => _currentPeriod;
  bool get autoRefreshEnabled => _autoRefreshEnabled;

  // Computed getters
  bool get isLoading => _state == MonitoringState.loading;
  bool get hasError => _state == MonitoringState.error;
  bool get hasData => _state == MonitoringState.loaded;
  
  // Dashboard helpers
  int get totalCriticalAlerts => _alertsData?.summary.criticalAlerts ?? 0;
  int get totalWarningAlerts => _alertsData?.summary.warningAlerts ?? 0;
  int get totalAlerts => _alertsData?.summary.totalAlerts ?? 0;
  
  // Quick stats from dashboard
  double get overallUtilization => _dashboardData?.overview.overallUtilization ?? 0.0;
  int get totalRooms => _dashboardData?.overview.totalRooms ?? 0;
  int get criticalRooms => _dashboardData?.overview.criticalRooms ?? 0;
  int get warningRooms => _dashboardData?.overview.warningRooms ?? 0;
  int get normalRooms => _dashboardData?.overview.normalRooms ?? 0;

  // Private methods
  void _setState(MonitoringState newState) {
    _state = newState;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    _setState(MonitoringState.error);
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  String _cleanErrorMessage(String errorMessage) {
    final patterns = [
      'Exception: ',
      'FormatException: ',
      'HttpException: ',
      'SocketException: ',
    ];
    
    String cleaned = errorMessage;
    for (final pattern in patterns) {
      if (cleaned.startsWith(pattern)) {
        cleaned = cleaned.substring(pattern.length);
        break;
      }
    }
    
    return cleaned;
  }

  /// Load dashboard overview
  Future<bool> loadDashboard({bool refresh = false}) async {
    if (!refresh && _dashboardData != null && _state == MonitoringState.loaded) {
      return true;
    }

    _setState(MonitoringState.loading);

    try {
      final response = await MonitoringService.getDashboard();
      
      if (response.success) {
        _dashboardData = response.data;
        _setState(MonitoringState.loaded);
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

  /// Load real-time monitoring data
  Future<bool> loadRealtimeMonitoring({bool refresh = false}) async {
    if (!refresh && _realtimeData != null && _state == MonitoringState.loaded) {
      return true;
    }

    _setState(MonitoringState.loading);

    try {
      final response = await MonitoringService.getRealtimeMonitoring();
      
      if (response.success) {
        _realtimeData = response.data;
        _setState(MonitoringState.loaded);
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

  /// Load alerts
  Future<bool> loadAlerts({bool refresh = false}) async {
    if (!refresh && _alertsData != null && _state == MonitoringState.loaded) {
      return true;
    }

    _setState(MonitoringState.loading);

    try {
      final response = await MonitoringService.getAlerts();
      
      if (response.success) {
        _alertsData = response.data;
        _setState(MonitoringState.loaded);
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

  /// Load room detail monitoring
  Future<bool> loadRoomDetail(int roomId, {bool refresh = false}) async {
    if (!refresh && _roomDetails.containsKey(roomId)) {
      return true;
    }

    _setState(MonitoringState.loading);

    try {
      final response = await MonitoringService.getRoomDetail(roomId);
      
      if (response.success) {
        _roomDetails[roomId] = response.data;
        _setState(MonitoringState.loaded);
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

  /// Load analytics with period
  Future<bool> loadAnalytics({String? period, bool refresh = false}) async {
    final targetPeriod = period ?? _currentPeriod;
    
    if (!refresh && _analyticsData != null && 
        _analyticsData!.period == targetPeriod && 
        _state == MonitoringState.loaded) {
      return true;
    }

    _setState(MonitoringState.loading);

    try {
      final response = await MonitoringService.getAnalytics(period: targetPeriod);
      
      if (response.success) {
        _analyticsData = response.data;
        _currentPeriod = targetPeriod;
        _setState(MonitoringState.loaded);
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

  /// Load all data (for comprehensive refresh)
  Future<bool> loadAllData({bool refresh = false}) async {
    _setState(MonitoringState.loading);

    try {
      // Load dashboard and alerts in parallel
      final results = await Future.wait([
        loadDashboard(refresh: refresh),
        loadAlerts(refresh: refresh),
      ]);

      // Check if both succeeded
      final success = results.every((result) => result);
      
      if (success) {
        _setState(MonitoringState.loaded);
      }
      
      return success;
    } catch (e) {
      _setError(_cleanErrorMessage(e.toString()));
      return false;
    }
  }

  /// Change analytics period
  Future<bool> changePeriod(String period) async {
    if (period == _currentPeriod) return true;
    
    return await loadAnalytics(period: period, refresh: true);
  }

  /// Toggle auto-refresh
  void toggleAutoRefresh() {
    _autoRefreshEnabled = !_autoRefreshEnabled;
    notifyListeners();
  }

  /// Get room detail by ID (from cache or load)
  RoomDetailData? getRoomDetail(int roomId) {
    return _roomDetails[roomId];
  }

  /// Clear specific room detail from cache
  void clearRoomDetail(int roomId) {
    _roomDetails.remove(roomId);
    notifyListeners();
  }

  /// Clear all cached data
  void clearAllData() {
    _dashboardData = null;
    _realtimeData = null;
    _alertsData = null;
    _roomDetails.clear();
    _analyticsData = null;
    _setState(MonitoringState.initial);
  }

  /// Refresh all visible data
  Future<bool> refreshAll() async {
    return await loadAllData(refresh: true);
  }

  /// Get rooms with critical status
  List<RoomMonitoring> get criticalRoomsList {
    return _dashboardData?.rooms.where((room) => room.isCritical).toList() ?? [];
  }

  /// Get rooms with warning status
  List<RoomMonitoring> get warningRoomsList {
    return _dashboardData?.rooms.where((room) => room.isWarning).toList() ?? [];
  }

  /// Get rooms with normal status
  List<RoomMonitoring> get normalRoomsList {
    return _dashboardData?.rooms.where((room) => room.isNormal).toList() ?? [];
  }

  /// Get critical alerts
  List<MonitoringAlert> get criticalAlerts {
    return _alertsData?.alerts.where((alert) => alert.isCritical).toList() ?? [];
  }

  /// Get warning alerts
  List<MonitoringAlert> get warningAlerts {
    return _alertsData?.alerts.where((alert) => alert.isWarning).toList() ?? [];
  }

  /// Get available periods for analytics
  List<String> get availablePeriods => MonitoringService.getAvailablePeriods();

  /// Get period display name
  String getPeriodDisplayName(String period) {
    return MonitoringService.getPeriodDisplayName(period);
  }
}