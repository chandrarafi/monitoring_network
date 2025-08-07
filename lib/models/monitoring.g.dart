// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'monitoring.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MonitoringOverview _$MonitoringOverviewFromJson(Map<String, dynamic> json) =>
    MonitoringOverview(
      totalRooms: _parseIntId(json['total_rooms']),
      totalIps: _parseIntId(json['total_ips']),
      totalUsedIps: _parseIntId(json['total_used_ips']),
      totalAvailableIps: _parseIntId(json['total_available_ips']),
      criticalRooms: _parseIntId(json['critical_rooms']),
      warningRooms: _parseIntId(json['warning_rooms']),
      normalRooms: _parseIntId(json['normal_rooms']),
      overallUtilization: _parseDouble(json['overall_utilization']),
    );

Map<String, dynamic> _$MonitoringOverviewToJson(MonitoringOverview instance) =>
    <String, dynamic>{
      'total_rooms': instance.totalRooms,
      'total_ips': instance.totalIps,
      'total_used_ips': instance.totalUsedIps,
      'total_available_ips': instance.totalAvailableIps,
      'critical_rooms': instance.criticalRooms,
      'warning_rooms': instance.warningRooms,
      'normal_rooms': instance.normalRooms,
      'overall_utilization': instance.overallUtilization,
    };

RoomMonitoring _$RoomMonitoringFromJson(Map<String, dynamic> json) =>
    RoomMonitoring(
      id: _parseIntId(json['id']),
      name: json['name'] as String,
      description: json['description'] as String?,
      ipRange: json['ip_range'] as String,
      totalIps: _parseIntId(json['total_ips']),
      usedIps: _parseIntId(json['used_ips']),
      availableIps: _parseIntId(json['available_ips']),
      utilizationPercentage: _parseDouble(json['utilization_percentage']),
      status: json['status'] as String,
      activeLeases: _parseIntId(json['active_leases']),
      lastMonitored: json['last_monitored'] as String,
    );

Map<String, dynamic> _$RoomMonitoringToJson(RoomMonitoring instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'ip_range': instance.ipRange,
      'total_ips': instance.totalIps,
      'used_ips': instance.usedIps,
      'available_ips': instance.availableIps,
      'utilization_percentage': instance.utilizationPercentage,
      'status': instance.status,
      'active_leases': instance.activeLeases,
      'last_monitored': instance.lastMonitored,
    };

MonitoringDashboardData _$MonitoringDashboardDataFromJson(
  Map<String, dynamic> json,
) => MonitoringDashboardData(
  overview: MonitoringOverview.fromJson(
    json['overview'] as Map<String, dynamic>,
  ),
  rooms: (json['rooms'] as List<dynamic>)
      .map((e) => RoomMonitoring.fromJson(e as Map<String, dynamic>))
      .toList(),
  lastUpdated: json['last_updated'] as String,
);

Map<String, dynamic> _$MonitoringDashboardDataToJson(
  MonitoringDashboardData instance,
) => <String, dynamic>{
  'overview': instance.overview,
  'rooms': instance.rooms,
  'last_updated': instance.lastUpdated,
};

MonitoringDashboardResponse _$MonitoringDashboardResponseFromJson(
  Map<String, dynamic> json,
) => MonitoringDashboardResponse(
  success: json['success'] as bool,
  message: json['message'] as String,
  data: MonitoringDashboardData.fromJson(json['data'] as Map<String, dynamic>),
);

Map<String, dynamic> _$MonitoringDashboardResponseToJson(
  MonitoringDashboardResponse instance,
) => <String, dynamic>{
  'success': instance.success,
  'message': instance.message,
  'data': instance.data,
};

RealtimeMonitoringData _$RealtimeMonitoringDataFromJson(
  Map<String, dynamic> json,
) => RealtimeMonitoringData(
  roomId: _parseIntId(json['room_id']),
  roomName: json['room_name'] as String,
  ipRange: json['ip_range'] as String,
  totalIps: _parseIntId(json['total_ips']),
  usedIps: _parseIntId(json['used_ips']),
  availableIps: _parseIntId(json['available_ips']),
  activeLeases: _parseIntId(json['active_leases']),
  utilizationPercentage: _parseDouble(json['utilization_percentage']),
  status: json['status'] as String,
  monitoredAt: json['monitored_at'] as String,
);

Map<String, dynamic> _$RealtimeMonitoringDataToJson(
  RealtimeMonitoringData instance,
) => <String, dynamic>{
  'room_id': instance.roomId,
  'room_name': instance.roomName,
  'ip_range': instance.ipRange,
  'total_ips': instance.totalIps,
  'used_ips': instance.usedIps,
  'available_ips': instance.availableIps,
  'active_leases': instance.activeLeases,
  'utilization_percentage': instance.utilizationPercentage,
  'status': instance.status,
  'monitored_at': instance.monitoredAt,
};

RealtimeSummary _$RealtimeSummaryFromJson(Map<String, dynamic> json) =>
    RealtimeSummary(
      totalRoomsMonitored: _parseIntId(json['total_rooms_monitored']),
      criticalRooms: _parseIntId(json['critical_rooms']),
      warningRooms: _parseIntId(json['warning_rooms']),
      normalRooms: _parseIntId(json['normal_rooms']),
      totalUsedIps: _parseIntId(json['total_used_ips']),
      totalAvailableIps: _parseIntId(json['total_available_ips']),
    );

Map<String, dynamic> _$RealtimeSummaryToJson(RealtimeSummary instance) =>
    <String, dynamic>{
      'total_rooms_monitored': instance.totalRoomsMonitored,
      'critical_rooms': instance.criticalRooms,
      'warning_rooms': instance.warningRooms,
      'normal_rooms': instance.normalRooms,
      'total_used_ips': instance.totalUsedIps,
      'total_available_ips': instance.totalAvailableIps,
    };

RealtimeMonitoringResponse _$RealtimeMonitoringResponseFromJson(
  Map<String, dynamic> json,
) => RealtimeMonitoringResponse(
  success: json['success'] as bool,
  message: json['message'] as String,
  data: RealtimeMonitoringResponseData.fromJson(
    json['data'] as Map<String, dynamic>,
  ),
);

Map<String, dynamic> _$RealtimeMonitoringResponseToJson(
  RealtimeMonitoringResponse instance,
) => <String, dynamic>{
  'success': instance.success,
  'message': instance.message,
  'data': instance.data,
};

RealtimeMonitoringResponseData _$RealtimeMonitoringResponseDataFromJson(
  Map<String, dynamic> json,
) => RealtimeMonitoringResponseData(
  monitoring: (json['monitoring'] as List<dynamic>)
      .map((e) => RealtimeMonitoringData.fromJson(e as Map<String, dynamic>))
      .toList(),
  summary: RealtimeSummary.fromJson(json['summary'] as Map<String, dynamic>),
  timestamp: json['timestamp'] as String,
);

Map<String, dynamic> _$RealtimeMonitoringResponseDataToJson(
  RealtimeMonitoringResponseData instance,
) => <String, dynamic>{
  'monitoring': instance.monitoring,
  'summary': instance.summary,
  'timestamp': instance.timestamp,
};

MonitoringAlert _$MonitoringAlertFromJson(Map<String, dynamic> json) =>
    MonitoringAlert(
      roomId: _parseIntId(json['room_id']),
      roomName: json['room_name'] as String,
      alertType: json['alert_type'] as String,
      severity: json['severity'] as String,
      message: json['message'] as String,
      utilizationPercentage: _parseDouble(json['utilization_percentage']),
      usedIps: _parseIntId(json['used_ips']),
      availableIps: _parseIntId(json['available_ips']),
      recommendations: (json['recommendations'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      detectedAt: json['detected_at'] as String,
    );

Map<String, dynamic> _$MonitoringAlertToJson(MonitoringAlert instance) =>
    <String, dynamic>{
      'room_id': instance.roomId,
      'room_name': instance.roomName,
      'alert_type': instance.alertType,
      'severity': instance.severity,
      'message': instance.message,
      'utilization_percentage': instance.utilizationPercentage,
      'used_ips': instance.usedIps,
      'available_ips': instance.availableIps,
      'recommendations': instance.recommendations,
      'detected_at': instance.detectedAt,
    };

AlertsSummary _$AlertsSummaryFromJson(Map<String, dynamic> json) =>
    AlertsSummary(
      totalAlerts: _parseIntId(json['total_alerts']),
      criticalAlerts: _parseIntId(json['critical_alerts']),
      warningAlerts: _parseIntId(json['warning_alerts']),
    );

Map<String, dynamic> _$AlertsSummaryToJson(AlertsSummary instance) =>
    <String, dynamic>{
      'total_alerts': instance.totalAlerts,
      'critical_alerts': instance.criticalAlerts,
      'warning_alerts': instance.warningAlerts,
    };

AlertsResponseData _$AlertsResponseDataFromJson(Map<String, dynamic> json) =>
    AlertsResponseData(
      alerts: (json['alerts'] as List<dynamic>)
          .map((e) => MonitoringAlert.fromJson(e as Map<String, dynamic>))
          .toList(),
      summary: AlertsSummary.fromJson(json['summary'] as Map<String, dynamic>),
      generatedAt: json['generated_at'] as String,
    );

Map<String, dynamic> _$AlertsResponseDataToJson(AlertsResponseData instance) =>
    <String, dynamic>{
      'alerts': instance.alerts,
      'summary': instance.summary,
      'generated_at': instance.generatedAt,
    };

AlertsResponse _$AlertsResponseFromJson(Map<String, dynamic> json) =>
    AlertsResponse(
      success: json['success'] as bool,
      message: json['message'] as String,
      data: AlertsResponseData.fromJson(json['data'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$AlertsResponseToJson(AlertsResponse instance) =>
    <String, dynamic>{
      'success': instance.success,
      'message': instance.message,
      'data': instance.data,
    };

RoomCurrentStatus _$RoomCurrentStatusFromJson(Map<String, dynamic> json) =>
    RoomCurrentStatus(
      totalIps: _parseIntId(json['total_ips']),
      usedIps: _parseIntId(json['used_ips']),
      availableIps: _parseIntId(json['available_ips']),
      utilizationPercentage: _parseDouble(json['utilization_percentage']),
      status: json['status'] as String,
    );

Map<String, dynamic> _$RoomCurrentStatusToJson(RoomCurrentStatus instance) =>
    <String, dynamic>{
      'total_ips': instance.totalIps,
      'used_ips': instance.usedIps,
      'available_ips': instance.availableIps,
      'utilization_percentage': instance.utilizationPercentage,
      'status': instance.status,
    };

RoomLease _$RoomLeaseFromJson(Map<String, dynamic> json) => RoomLease(
  id: _parseIntId(json['id']),
  address: json['address'] as String,
  macAddress: json['mac_address'] as String,
  comment: json['comment'] as String?,
  status: json['status'] as String,
  roomId: _parseIntId(json['room_id']),
);

Map<String, dynamic> _$RoomLeaseToJson(RoomLease instance) => <String, dynamic>{
  'id': instance.id,
  'address': instance.address,
  'mac_address': instance.macAddress,
  'comment': instance.comment,
  'status': instance.status,
  'room_id': instance.roomId,
};

RoomIpDetails _$RoomIpDetailsFromJson(
  Map<String, dynamic> json,
) => RoomIpDetails(
  usedIps: (json['used_ips'] as List<dynamic>).map((e) => e as String).toList(),
  freeIps: (json['free_ips'] as List<dynamic>).map((e) => e as String).toList(),
  ipRangeStart: json['ip_range_start'] as String,
  ipRangeEnd: json['ip_range_end'] as String,
);

Map<String, dynamic> _$RoomIpDetailsToJson(RoomIpDetails instance) =>
    <String, dynamic>{
      'used_ips': instance.usedIps,
      'free_ips': instance.freeIps,
      'ip_range_start': instance.ipRangeStart,
      'ip_range_end': instance.ipRangeEnd,
    };

HistoricalData _$HistoricalDataFromJson(Map<String, dynamic> json) =>
    HistoricalData(
      monitoredAt: json['monitored_at'] as String,
      utilizationPercentage: _parseDouble(json['utilization_percentage']),
      usedIps: _parseIntId(json['used_ips']),
      status: json['status'] as String,
    );

Map<String, dynamic> _$HistoricalDataToJson(HistoricalData instance) =>
    <String, dynamic>{
      'monitored_at': instance.monitoredAt,
      'utilization_percentage': instance.utilizationPercentage,
      'used_ips': instance.usedIps,
      'status': instance.status,
    };

RoomDetailData _$RoomDetailDataFromJson(Map<String, dynamic> json) =>
    RoomDetailData(
      room: Room.fromJson(json['room'] as Map<String, dynamic>),
      currentStatus: RoomCurrentStatus.fromJson(
        json['current_status'] as Map<String, dynamic>,
      ),
      leases: (json['leases'] as List<dynamic>)
          .map((e) => RoomLease.fromJson(e as Map<String, dynamic>))
          .toList(),
      ipDetails: RoomIpDetails.fromJson(
        json['ip_details'] as Map<String, dynamic>,
      ),
      historicalData: (json['historical_data'] as List<dynamic>)
          .map((e) => HistoricalData.fromJson(e as Map<String, dynamic>))
          .toList(),
      lastUpdated: json['last_updated'] as String,
    );

Map<String, dynamic> _$RoomDetailDataToJson(RoomDetailData instance) =>
    <String, dynamic>{
      'room': instance.room,
      'current_status': instance.currentStatus,
      'leases': instance.leases,
      'ip_details': instance.ipDetails,
      'historical_data': instance.historicalData,
      'last_updated': instance.lastUpdated,
    };

RoomDetailResponse _$RoomDetailResponseFromJson(Map<String, dynamic> json) =>
    RoomDetailResponse(
      success: json['success'] as bool,
      message: json['message'] as String,
      data: RoomDetailData.fromJson(json['data'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$RoomDetailResponseToJson(RoomDetailResponse instance) =>
    <String, dynamic>{
      'success': instance.success,
      'message': instance.message,
      'data': instance.data,
    };

AnalyticsDataPoint _$AnalyticsDataPointFromJson(Map<String, dynamic> json) =>
    AnalyticsDataPoint(
      time: json['time'] as String,
      utilization: _parseDouble(json['utilization']),
      usedIps: _parseIntId(json['used_ips']),
      status: json['status'] as String,
    );

Map<String, dynamic> _$AnalyticsDataPointToJson(AnalyticsDataPoint instance) =>
    <String, dynamic>{
      'time': instance.time,
      'utilization': instance.utilization,
      'used_ips': instance.usedIps,
      'status': instance.status,
    };

RoomTrend _$RoomTrendFromJson(Map<String, dynamic> json) => RoomTrend(
  roomId: _parseIntId(json['room_id']),
  roomName: json['room_name'] as String,
  dataPoints: (json['data_points'] as List<dynamic>)
      .map((e) => AnalyticsDataPoint.fromJson(e as Map<String, dynamic>))
      .toList(),
  averageUtilization: _parseDouble(json['average_utilization']),
  peakUtilization: _parseDouble(json['peak_utilization']),
  currentStatus: json['current_status'] as String,
);

Map<String, dynamic> _$RoomTrendToJson(RoomTrend instance) => <String, dynamic>{
  'room_id': instance.roomId,
  'room_name': instance.roomName,
  'data_points': instance.dataPoints,
  'average_utilization': instance.averageUtilization,
  'peak_utilization': instance.peakUtilization,
  'current_status': instance.currentStatus,
};

AnalyticsSummary _$AnalyticsSummaryFromJson(Map<String, dynamic> json) =>
    AnalyticsSummary(
      totalDataPoints: _parseIntId(json['total_data_points']),
      roomsMonitored: _parseIntId(json['rooms_monitored']),
      averageUtilization: _parseDouble(json['average_utilization']),
      peakUtilization: _parseDouble(json['peak_utilization']),
    );

Map<String, dynamic> _$AnalyticsSummaryToJson(AnalyticsSummary instance) =>
    <String, dynamic>{
      'total_data_points': instance.totalDataPoints,
      'rooms_monitored': instance.roomsMonitored,
      'average_utilization': instance.averageUtilization,
      'peak_utilization': instance.peakUtilization,
    };

DateRange _$DateRangeFromJson(Map<String, dynamic> json) =>
    DateRange(start: json['start'] as String, end: json['end'] as String);

Map<String, dynamic> _$DateRangeToJson(DateRange instance) => <String, dynamic>{
  'start': instance.start,
  'end': instance.end,
};

AnalyticsData _$AnalyticsDataFromJson(Map<String, dynamic> json) =>
    AnalyticsData(
      period: json['period'] as String,
      dateRange: DateRange.fromJson(json['date_range'] as Map<String, dynamic>),
      roomTrends: (json['room_trends'] as Map<String, dynamic>).map(
        (k, e) => MapEntry(k, RoomTrend.fromJson(e as Map<String, dynamic>)),
      ),
      summary: AnalyticsSummary.fromJson(
        json['summary'] as Map<String, dynamic>,
      ),
    );

Map<String, dynamic> _$AnalyticsDataToJson(AnalyticsData instance) =>
    <String, dynamic>{
      'period': instance.period,
      'date_range': instance.dateRange,
      'room_trends': instance.roomTrends,
      'summary': instance.summary,
    };

AnalyticsResponse _$AnalyticsResponseFromJson(Map<String, dynamic> json) =>
    AnalyticsResponse(
      success: json['success'] as bool,
      message: json['message'] as String,
      data: AnalyticsData.fromJson(json['data'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$AnalyticsResponseToJson(AnalyticsResponse instance) =>
    <String, dynamic>{
      'success': instance.success,
      'message': instance.message,
      'data': instance.data,
    };
