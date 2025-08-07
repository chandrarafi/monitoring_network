import 'package:json_annotation/json_annotation.dart';
import 'room.dart';

part 'monitoring.g.dart';

// Helper functions to safely parse numbers
int _parseIntId(dynamic value) {
  if (value == null) throw ArgumentError('Cannot parse ID from null');
  if (value is int) return value;
  if (value is String) {
    if (value.isEmpty) throw ArgumentError('Cannot parse ID from empty string');
    return int.parse(value);
  }
  if (value is num) return value.toInt();
  throw ArgumentError('Cannot parse ID from $value');
}

int? _parseIntIdNullable(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is String) {
    if (value.isEmpty) return null;
    return int.tryParse(value);
  }
  if (value is num) return value.toInt();
  return null;
}

double _parseDouble(dynamic value) {
  if (value == null) return 0.0;
  if (value is double) return value;
  if (value is int) return value.toDouble();
  if (value is String) {
    return double.tryParse(value) ?? 0.0;
  }
  if (value is num) return value.toDouble();
  return 0.0;
}

// Dashboard Overview Models
@JsonSerializable()
class MonitoringOverview {
  @JsonKey(name: 'total_rooms', fromJson: _parseIntId)
  final int totalRooms;
  @JsonKey(name: 'total_ips', fromJson: _parseIntId)
  final int totalIps;
  @JsonKey(name: 'total_used_ips', fromJson: _parseIntId)
  final int totalUsedIps;
  @JsonKey(name: 'total_available_ips', fromJson: _parseIntId)
  final int totalAvailableIps;
  @JsonKey(name: 'critical_rooms', fromJson: _parseIntId)
  final int criticalRooms;
  @JsonKey(name: 'warning_rooms', fromJson: _parseIntId)
  final int warningRooms;
  @JsonKey(name: 'normal_rooms', fromJson: _parseIntId)
  final int normalRooms;
  @JsonKey(name: 'overall_utilization', fromJson: _parseDouble)
  final double overallUtilization;

  const MonitoringOverview({
    required this.totalRooms,
    required this.totalIps,
    required this.totalUsedIps,
    required this.totalAvailableIps,
    required this.criticalRooms,
    required this.warningRooms,
    required this.normalRooms,
    required this.overallUtilization,
  });

  factory MonitoringOverview.fromJson(Map<String, dynamic> json) =>
      _$MonitoringOverviewFromJson(json);
  Map<String, dynamic> toJson() => _$MonitoringOverviewToJson(this);
}

@JsonSerializable()
class RoomMonitoring {
  @JsonKey(fromJson: _parseIntId)
  final int id;
  final String name;
  final String? description;
  @JsonKey(name: 'ip_range')
  final String ipRange;
  @JsonKey(name: 'total_ips', fromJson: _parseIntId)
  final int totalIps;
  @JsonKey(name: 'used_ips', fromJson: _parseIntId)
  final int usedIps;
  @JsonKey(name: 'available_ips', fromJson: _parseIntId)
  final int availableIps;
  @JsonKey(name: 'utilization_percentage', fromJson: _parseDouble)
  final double utilizationPercentage;
  final String status;
  @JsonKey(name: 'active_leases', fromJson: _parseIntId)
  final int activeLeases;
  @JsonKey(name: 'last_monitored')
  final String lastMonitored;

  const RoomMonitoring({
    required this.id,
    required this.name,
    this.description,
    required this.ipRange,
    required this.totalIps,
    required this.usedIps,
    required this.availableIps,
    required this.utilizationPercentage,
    required this.status,
    required this.activeLeases,
    required this.lastMonitored,
  });

  factory RoomMonitoring.fromJson(Map<String, dynamic> json) =>
      _$RoomMonitoringFromJson(json);
  Map<String, dynamic> toJson() => _$RoomMonitoringToJson(this);

  // Helper getters
  String get statusDisplay => status.toUpperCase();
  bool get isCritical => status.toLowerCase() == 'critical';
  bool get isWarning => status.toLowerCase() == 'warning';
  bool get isNormal => status.toLowerCase() == 'normal';
}

@JsonSerializable()
class MonitoringDashboardData {
  final MonitoringOverview overview;
  final List<RoomMonitoring> rooms;
  @JsonKey(name: 'last_updated')
  final String lastUpdated;

  const MonitoringDashboardData({
    required this.overview,
    required this.rooms,
    required this.lastUpdated,
  });

  factory MonitoringDashboardData.fromJson(Map<String, dynamic> json) =>
      _$MonitoringDashboardDataFromJson(json);
  Map<String, dynamic> toJson() => _$MonitoringDashboardDataToJson(this);
}

@JsonSerializable()
class MonitoringDashboardResponse {
  final bool success;
  final String message;
  final MonitoringDashboardData data;

  const MonitoringDashboardResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory MonitoringDashboardResponse.fromJson(Map<String, dynamic> json) =>
      _$MonitoringDashboardResponseFromJson(json);
  Map<String, dynamic> toJson() => _$MonitoringDashboardResponseToJson(this);
}

// Real-time Monitoring Models
@JsonSerializable()
class RealtimeMonitoringData {
  @JsonKey(name: 'room_id', fromJson: _parseIntId)
  final int roomId;
  @JsonKey(name: 'room_name')
  final String roomName;
  @JsonKey(name: 'ip_range')
  final String ipRange;
  @JsonKey(name: 'total_ips', fromJson: _parseIntId)
  final int totalIps;
  @JsonKey(name: 'used_ips', fromJson: _parseIntId)
  final int usedIps;
  @JsonKey(name: 'available_ips', fromJson: _parseIntId)
  final int availableIps;
  @JsonKey(name: 'active_leases', fromJson: _parseIntId)
  final int activeLeases;
  @JsonKey(name: 'utilization_percentage', fromJson: _parseDouble)
  final double utilizationPercentage;
  final String status;
  @JsonKey(name: 'monitored_at')
  final String monitoredAt;

  const RealtimeMonitoringData({
    required this.roomId,
    required this.roomName,
    required this.ipRange,
    required this.totalIps,
    required this.usedIps,
    required this.availableIps,
    required this.activeLeases,
    required this.utilizationPercentage,
    required this.status,
    required this.monitoredAt,
  });

  factory RealtimeMonitoringData.fromJson(Map<String, dynamic> json) =>
      _$RealtimeMonitoringDataFromJson(json);
  Map<String, dynamic> toJson() => _$RealtimeMonitoringDataToJson(this);
}

@JsonSerializable()
class RealtimeSummary {
  @JsonKey(name: 'total_rooms_monitored', fromJson: _parseIntId)
  final int totalRoomsMonitored;
  @JsonKey(name: 'critical_rooms', fromJson: _parseIntId)
  final int criticalRooms;
  @JsonKey(name: 'warning_rooms', fromJson: _parseIntId)
  final int warningRooms;
  @JsonKey(name: 'normal_rooms', fromJson: _parseIntId)
  final int normalRooms;
  @JsonKey(name: 'total_used_ips', fromJson: _parseIntId)
  final int totalUsedIps;
  @JsonKey(name: 'total_available_ips', fromJson: _parseIntId)
  final int totalAvailableIps;

  const RealtimeSummary({
    required this.totalRoomsMonitored,
    required this.criticalRooms,
    required this.warningRooms,
    required this.normalRooms,
    required this.totalUsedIps,
    required this.totalAvailableIps,
  });

  factory RealtimeSummary.fromJson(Map<String, dynamic> json) =>
      _$RealtimeSummaryFromJson(json);
  Map<String, dynamic> toJson() => _$RealtimeSummaryToJson(this);
}

@JsonSerializable()
class RealtimeMonitoringResponse {
  final bool success;
  final String message;
  @JsonKey(name: 'data')
  final RealtimeMonitoringResponseData data;

  const RealtimeMonitoringResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory RealtimeMonitoringResponse.fromJson(Map<String, dynamic> json) =>
      _$RealtimeMonitoringResponseFromJson(json);
  Map<String, dynamic> toJson() => _$RealtimeMonitoringResponseToJson(this);
}

@JsonSerializable()
class RealtimeMonitoringResponseData {
  final List<RealtimeMonitoringData> monitoring;
  final RealtimeSummary summary;
  final String timestamp;

  const RealtimeMonitoringResponseData({
    required this.monitoring,
    required this.summary,
    required this.timestamp,
  });

  factory RealtimeMonitoringResponseData.fromJson(Map<String, dynamic> json) =>
      _$RealtimeMonitoringResponseDataFromJson(json);
  Map<String, dynamic> toJson() => _$RealtimeMonitoringResponseDataToJson(this);
}

// Alerts Models
@JsonSerializable()
class MonitoringAlert {
  @JsonKey(name: 'room_id', fromJson: _parseIntId)
  final int roomId;
  @JsonKey(name: 'room_name')
  final String roomName;
  @JsonKey(name: 'alert_type')
  final String alertType;
  final String severity;
  final String message;
  @JsonKey(name: 'utilization_percentage', fromJson: _parseDouble)
  final double utilizationPercentage;
  @JsonKey(name: 'used_ips', fromJson: _parseIntId)
  final int usedIps;
  @JsonKey(name: 'available_ips', fromJson: _parseIntId)
  final int availableIps;
  final List<String> recommendations;
  @JsonKey(name: 'detected_at')
  final String detectedAt;

  const MonitoringAlert({
    required this.roomId,
    required this.roomName,
    required this.alertType,
    required this.severity,
    required this.message,
    required this.utilizationPercentage,
    required this.usedIps,
    required this.availableIps,
    required this.recommendations,
    required this.detectedAt,
  });

  factory MonitoringAlert.fromJson(Map<String, dynamic> json) =>
      _$MonitoringAlertFromJson(json);
  Map<String, dynamic> toJson() => _$MonitoringAlertToJson(this);

  // Helper getters
  bool get isCritical => alertType.toLowerCase() == 'critical';
  bool get isWarning => alertType.toLowerCase() == 'warning';
  String get severityDisplay => severity.toUpperCase();
}

@JsonSerializable()
class AlertsSummary {
  @JsonKey(name: 'total_alerts', fromJson: _parseIntId)
  final int totalAlerts;
  @JsonKey(name: 'critical_alerts', fromJson: _parseIntId)
  final int criticalAlerts;
  @JsonKey(name: 'warning_alerts', fromJson: _parseIntId)
  final int warningAlerts;

  const AlertsSummary({
    required this.totalAlerts,
    required this.criticalAlerts,
    required this.warningAlerts,
  });

  factory AlertsSummary.fromJson(Map<String, dynamic> json) =>
      _$AlertsSummaryFromJson(json);
  Map<String, dynamic> toJson() => _$AlertsSummaryToJson(this);
}

@JsonSerializable()
class AlertsResponseData {
  final List<MonitoringAlert> alerts;
  final AlertsSummary summary;
  @JsonKey(name: 'generated_at')
  final String generatedAt;

  const AlertsResponseData({
    required this.alerts,
    required this.summary,
    required this.generatedAt,
  });

  factory AlertsResponseData.fromJson(Map<String, dynamic> json) =>
      _$AlertsResponseDataFromJson(json);
  Map<String, dynamic> toJson() => _$AlertsResponseDataToJson(this);
}

@JsonSerializable()
class AlertsResponse {
  final bool success;
  final String message;
  final AlertsResponseData data;

  const AlertsResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory AlertsResponse.fromJson(Map<String, dynamic> json) =>
      _$AlertsResponseFromJson(json);
  Map<String, dynamic> toJson() => _$AlertsResponseToJson(this);
}

// Room Detail Monitoring Models
@JsonSerializable()
class RoomCurrentStatus {
  @JsonKey(name: 'total_ips', fromJson: _parseIntId)
  final int totalIps;
  @JsonKey(name: 'used_ips', fromJson: _parseIntId)
  final int usedIps;
  @JsonKey(name: 'available_ips', fromJson: _parseIntId)
  final int availableIps;
  @JsonKey(name: 'utilization_percentage', fromJson: _parseDouble)
  final double utilizationPercentage;
  final String status;

  const RoomCurrentStatus({
    required this.totalIps,
    required this.usedIps,
    required this.availableIps,
    required this.utilizationPercentage,
    required this.status,
  });

  factory RoomCurrentStatus.fromJson(Map<String, dynamic> json) =>
      _$RoomCurrentStatusFromJson(json);
  Map<String, dynamic> toJson() => _$RoomCurrentStatusToJson(this);
}

@JsonSerializable()
class RoomLease {
  @JsonKey(fromJson: _parseIntId)
  final int id;
  final String address;
  @JsonKey(name: 'mac_address')
  final String macAddress;
  final String? comment;
  final String status;
  @JsonKey(name: 'room_id', fromJson: _parseIntId)
  final int roomId;

  const RoomLease({
    required this.id,
    required this.address,
    required this.macAddress,
    this.comment,
    required this.status,
    required this.roomId,
  });

  factory RoomLease.fromJson(Map<String, dynamic> json) =>
      _$RoomLeaseFromJson(json);
  Map<String, dynamic> toJson() => _$RoomLeaseToJson(this);
}

@JsonSerializable()
class RoomIpDetails {
  @JsonKey(name: 'used_ips')
  final List<String> usedIps;
  @JsonKey(name: 'free_ips')
  final List<String> freeIps;
  @JsonKey(name: 'ip_range_start')
  final String ipRangeStart;
  @JsonKey(name: 'ip_range_end')
  final String ipRangeEnd;

  const RoomIpDetails({
    required this.usedIps,
    required this.freeIps,
    required this.ipRangeStart,
    required this.ipRangeEnd,
  });

  factory RoomIpDetails.fromJson(Map<String, dynamic> json) =>
      _$RoomIpDetailsFromJson(json);
  Map<String, dynamic> toJson() => _$RoomIpDetailsToJson(this);
}

@JsonSerializable()
class HistoricalData {
  @JsonKey(name: 'monitored_at')
  final String monitoredAt;
  @JsonKey(name: 'utilization_percentage', fromJson: _parseDouble)
  final double utilizationPercentage;
  @JsonKey(name: 'used_ips', fromJson: _parseIntId)
  final int usedIps;
  final String status;

  const HistoricalData({
    required this.monitoredAt,
    required this.utilizationPercentage,
    required this.usedIps,
    required this.status,
  });

  factory HistoricalData.fromJson(Map<String, dynamic> json) =>
      _$HistoricalDataFromJson(json);
  Map<String, dynamic> toJson() => _$HistoricalDataToJson(this);
}

@JsonSerializable()
class RoomDetailData {
  final Room room;
  @JsonKey(name: 'current_status')
  final RoomCurrentStatus currentStatus;
  final List<RoomLease> leases;
  @JsonKey(name: 'ip_details')
  final RoomIpDetails ipDetails;
  @JsonKey(name: 'historical_data')
  final List<HistoricalData> historicalData;
  @JsonKey(name: 'last_updated')
  final String lastUpdated;

  const RoomDetailData({
    required this.room,
    required this.currentStatus,
    required this.leases,
    required this.ipDetails,
    required this.historicalData,
    required this.lastUpdated,
  });

  factory RoomDetailData.fromJson(Map<String, dynamic> json) =>
      _$RoomDetailDataFromJson(json);
  Map<String, dynamic> toJson() => _$RoomDetailDataToJson(this);
}

@JsonSerializable()
class RoomDetailResponse {
  final bool success;
  final String message;
  final RoomDetailData data;

  const RoomDetailResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory RoomDetailResponse.fromJson(Map<String, dynamic> json) =>
      _$RoomDetailResponseFromJson(json);
  Map<String, dynamic> toJson() => _$RoomDetailResponseToJson(this);
}

// Analytics Models
@JsonSerializable()
class AnalyticsDataPoint {
  final String time;
  @JsonKey(fromJson: _parseDouble)
  final double utilization;
  @JsonKey(name: 'used_ips', fromJson: _parseIntId)
  final int usedIps;
  final String status;

  const AnalyticsDataPoint({
    required this.time,
    required this.utilization,
    required this.usedIps,
    required this.status,
  });

  factory AnalyticsDataPoint.fromJson(Map<String, dynamic> json) =>
      _$AnalyticsDataPointFromJson(json);
  Map<String, dynamic> toJson() => _$AnalyticsDataPointToJson(this);
}

@JsonSerializable()
class RoomTrend {
  @JsonKey(name: 'room_id', fromJson: _parseIntId)
  final int roomId;
  @JsonKey(name: 'room_name')
  final String roomName;
  @JsonKey(name: 'data_points')
  final List<AnalyticsDataPoint> dataPoints;
  @JsonKey(name: 'average_utilization', fromJson: _parseDouble)
  final double averageUtilization;
  @JsonKey(name: 'peak_utilization', fromJson: _parseDouble)
  final double peakUtilization;
  @JsonKey(name: 'current_status')
  final String currentStatus;

  const RoomTrend({
    required this.roomId,
    required this.roomName,
    required this.dataPoints,
    required this.averageUtilization,
    required this.peakUtilization,
    required this.currentStatus,
  });

  factory RoomTrend.fromJson(Map<String, dynamic> json) =>
      _$RoomTrendFromJson(json);
  Map<String, dynamic> toJson() => _$RoomTrendToJson(this);
}

@JsonSerializable()
class AnalyticsSummary {
  @JsonKey(name: 'total_data_points', fromJson: _parseIntId)
  final int totalDataPoints;
  @JsonKey(name: 'rooms_monitored', fromJson: _parseIntId)
  final int roomsMonitored;
  @JsonKey(name: 'average_utilization', fromJson: _parseDouble)
  final double averageUtilization;
  @JsonKey(name: 'peak_utilization', fromJson: _parseDouble)
  final double peakUtilization;

  const AnalyticsSummary({
    required this.totalDataPoints,
    required this.roomsMonitored,
    required this.averageUtilization,
    required this.peakUtilization,
  });

  factory AnalyticsSummary.fromJson(Map<String, dynamic> json) =>
      _$AnalyticsSummaryFromJson(json);
  Map<String, dynamic> toJson() => _$AnalyticsSummaryToJson(this);
}

@JsonSerializable()
class DateRange {
  final String start;
  final String end;

  const DateRange({
    required this.start,
    required this.end,
  });

  factory DateRange.fromJson(Map<String, dynamic> json) =>
      _$DateRangeFromJson(json);
  Map<String, dynamic> toJson() => _$DateRangeToJson(this);
}

@JsonSerializable()
class AnalyticsData {
  final String period;
  @JsonKey(name: 'date_range')
  final DateRange dateRange;
  @JsonKey(name: 'room_trends')
  final Map<String, RoomTrend> roomTrends;
  final AnalyticsSummary summary;

  const AnalyticsData({
    required this.period,
    required this.dateRange,
    required this.roomTrends,
    required this.summary,
  });

  factory AnalyticsData.fromJson(Map<String, dynamic> json) =>
      _$AnalyticsDataFromJson(json);
  Map<String, dynamic> toJson() => _$AnalyticsDataToJson(this);
}

@JsonSerializable()
class AnalyticsResponse {
  final bool success;
  final String message;
  final AnalyticsData data;

  const AnalyticsResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory AnalyticsResponse.fromJson(Map<String, dynamic> json) =>
      _$AnalyticsResponseFromJson(json);
  Map<String, dynamic> toJson() => _$AnalyticsResponseToJson(this);
}