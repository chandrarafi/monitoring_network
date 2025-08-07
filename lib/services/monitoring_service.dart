import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/monitoring.dart';
import '../utils/constants.dart';
import '../services/auth_service.dart';

class MonitoringService {
  static const String baseUrl = '${ApiConstants.baseUrl}/api/monitoring';

  // Helper method to get headers with authentication
  static Future<Map<String, String>> _getHeaders() async {
    final token = await AuthService.getAccessToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // Helper method to handle HTTP errors
  static void _handleHttpError(http.Response response, String operation) {
    if (response.statusCode != 200) {
      throw Exception('HTTP ${response.statusCode}: Failed to $operation');
    }
  }

  // Helper method to parse response and handle errors
  static Map<String, dynamic> _parseResponse(http.Response response, String operation) {
    _handleHttpError(response, operation);
    
    try {
      return json.decode(response.body) as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Failed to parse response for $operation: $e');
    }
  }

  /// 1. GET /api/monitoring/dashboard - Dashboard Overview
  static Future<MonitoringDashboardResponse> getDashboard() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/dashboard'),
        headers: headers,
      );

      final responseData = _parseResponse(response, 'get dashboard');
      return MonitoringDashboardResponse.fromJson(responseData);
    } catch (e) {
      throw Exception('Gagal mengambil dashboard monitoring: $e');
    }
  }

  /// 2. GET /api/monitoring/realtime - Real-time Monitoring
  static Future<RealtimeMonitoringResponse> getRealtimeMonitoring() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/realtime'),
        headers: headers,
      );

      final responseData = _parseResponse(response, 'get realtime monitoring');
      return RealtimeMonitoringResponse.fromJson(responseData);
    } catch (e) {
      throw Exception('Gagal mengambil real-time monitoring: $e');
    }
  }

  /// 3. GET /api/monitoring/alerts - Network Alerts
  static Future<AlertsResponse> getAlerts() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/alerts'),
        headers: headers,
      );

      final responseData = _parseResponse(response, 'get alerts');
      return AlertsResponse.fromJson(responseData);
    } catch (e) {
      throw Exception('Gagal mengambil alerts monitoring: $e');
    }
  }

  /// 4. GET /api/monitoring/room/{room_id} - Room Detail Monitoring
  static Future<RoomDetailResponse> getRoomDetail(int roomId) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/room/$roomId'),
        headers: headers,
      );

      final responseData = _parseResponse(response, 'get room detail monitoring');
      return RoomDetailResponse.fromJson(responseData);
    } catch (e) {
      throw Exception('Gagal mengambil detail monitoring ruangan: $e');
    }
  }

  /// 5. GET /api/monitoring/analytics - Analytics & Trends
  static Future<AnalyticsResponse> getAnalytics({String period = '24h'}) async {
    try {
      final headers = await _getHeaders();
      final uri = Uri.parse('$baseUrl/analytics').replace(
        queryParameters: {'period': period},
      );
      
      final response = await http.get(uri, headers: headers);

      final responseData = _parseResponse(response, 'get analytics');
      return AnalyticsResponse.fromJson(responseData);
    } catch (e) {
      throw Exception('Gagal mengambil analytics monitoring: $e');
    }
  }

  // Helper method to clean error messages
  static String _cleanErrorMessage(String errorMessage) {
    // Remove common exception prefixes
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

  // Static method to get available periods for analytics
  static List<String> getAvailablePeriods() {
    return ['1h', '24h', '7d', '30d'];
  }

  // Static method to get period display names
  static String getPeriodDisplayName(String period) {
    switch (period) {
      case '1h':
        return '1 Jam';
      case '24h':
        return '24 Jam';
      case '7d':
        return '7 Hari';
      case '30d':
        return '30 Hari';
      default:
        return period;
    }
  }

  // Static method to get status color helpers
  static Map<String, dynamic> getStatusColors() {
    return {
      'critical': {
        'color': 0xFFD32F2F, // Red
        'backgroundColor': 0xFFFFEBEE,
        'icon': 'error',
      },
      'warning': {
        'color': 0xFFF57C00, // Orange
        'backgroundColor': 0xFFFFF3E0,
        'icon': 'warning',
      },
      'normal': {
        'color': 0xFF388E3C, // Green
        'backgroundColor': 0xFFE8F5E8,
        'icon': 'check_circle',
      },
    };
  }

  // Static method to get severity colors for alerts
  static Map<String, dynamic> getSeverityColors() {
    return {
      'high': {
        'color': 0xFFD32F2F, // Red
        'backgroundColor': 0xFFFFEBEE,
      },
      'medium': {
        'color': 0xFFF57C00, // Orange
        'backgroundColor': 0xFFFFF3E0,
      },
      'low': {
        'color': 0xFF1976D2, // Blue
        'backgroundColor': 0xFFE3F2FD,
      },
    };
  }
}