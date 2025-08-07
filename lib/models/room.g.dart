// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'room.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Room _$RoomFromJson(Map<String, dynamic> json) => Room(
  id: (json['id'] as num).toInt(),
  name: json['name'] as String,
  description: json['description'] as String?,
  ipRangeStart: json['ip_range_start'] as String?,
  ipRangeEnd: json['ip_range_end'] as String?,
  ipRangeDisplay: json['ip_range_display'] as String?,
  totalIps: (json['total_ips'] as num?)?.toInt(),
  subnetMask: json['subnet_mask'] as String?,
  gateway: json['gateway'] as String?,
  dnsServer: json['dns_server'] as String?,
  isActive: json['is_active'] as bool?,
  capacity: (json['capacity'] as num?)?.toInt(),
  additionalInfo: json['additional_info'] as Map<String, dynamic>?,
  createdAt: json['created_at'] as String?,
  updatedAt: json['updated_at'] as String?,
);

Map<String, dynamic> _$RoomToJson(Room instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'description': instance.description,
  'ip_range_start': instance.ipRangeStart,
  'ip_range_end': instance.ipRangeEnd,
  'ip_range_display': instance.ipRangeDisplay,
  'total_ips': instance.totalIps,
  'subnet_mask': instance.subnetMask,
  'gateway': instance.gateway,
  'dns_server': instance.dnsServer,
  'is_active': instance.isActive,
  'capacity': instance.capacity,
  'additional_info': instance.additionalInfo,
  'created_at': instance.createdAt,
  'updated_at': instance.updatedAt,
};

RoomListResponse _$RoomListResponseFromJson(Map<String, dynamic> json) =>
    RoomListResponse(
      success: json['success'] as bool,
      message: json['message'] as String,
      data: (json['data'] as List<dynamic>)
          .map((e) => Room.fromJson(e as Map<String, dynamic>))
          .toList(),
      pagination: json['pagination'] == null
          ? null
          : PaginationInfo.fromJson(json['pagination'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$RoomListResponseToJson(RoomListResponse instance) =>
    <String, dynamic>{
      'success': instance.success,
      'message': instance.message,
      'data': instance.data,
      'pagination': instance.pagination,
    };

RoomResponse _$RoomResponseFromJson(Map<String, dynamic> json) => RoomResponse(
  success: json['success'] as bool,
  message: json['message'] as String,
  data: json['data'] == null
      ? null
      : Room.fromJson(json['data'] as Map<String, dynamic>),
);

Map<String, dynamic> _$RoomResponseToJson(RoomResponse instance) =>
    <String, dynamic>{
      'success': instance.success,
      'message': instance.message,
      'data': instance.data,
    };

PaginationInfo _$PaginationInfoFromJson(Map<String, dynamic> json) =>
    PaginationInfo(
      currentPage: (json['current_page'] as num).toInt(),
      perPage: (json['per_page'] as num).toInt(),
      total: (json['total'] as num).toInt(),
      lastPage: (json['last_page'] as num).toInt(),
    );

Map<String, dynamic> _$PaginationInfoToJson(PaginationInfo instance) =>
    <String, dynamic>{
      'current_page': instance.currentPage,
      'per_page': instance.perPage,
      'total': instance.total,
      'last_page': instance.lastPage,
    };

AvailableIpsResponse _$AvailableIpsResponseFromJson(
  Map<String, dynamic> json,
) => AvailableIpsResponse(
  success: json['success'] as bool,
  message: json['message'] as String,
  data: AvailableIpsData.fromJson(json['data'] as Map<String, dynamic>),
);

Map<String, dynamic> _$AvailableIpsResponseToJson(
  AvailableIpsResponse instance,
) => <String, dynamic>{
  'success': instance.success,
  'message': instance.message,
  'data': instance.data,
};

AvailableIpsData _$AvailableIpsDataFromJson(Map<String, dynamic> json) =>
    AvailableIpsData(
      roomName: json['room_name'] as String,
      ipRange: json['ip_range'] as String,
      totalIps: (json['total_ips'] as num).toInt(),
      availableIps: (json['available_ips'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$AvailableIpsDataToJson(AvailableIpsData instance) =>
    <String, dynamic>{
      'room_name': instance.roomName,
      'ip_range': instance.ipRange,
      'total_ips': instance.totalIps,
      'available_ips': instance.availableIps,
    };

FindRoomByIpResponse _$FindRoomByIpResponseFromJson(
  Map<String, dynamic> json,
) => FindRoomByIpResponse(
  success: json['success'] as bool,
  message: json['message'] as String,
  data: json['data'] == null
      ? null
      : FindRoomByIpData.fromJson(json['data'] as Map<String, dynamic>),
);

Map<String, dynamic> _$FindRoomByIpResponseToJson(
  FindRoomByIpResponse instance,
) => <String, dynamic>{
  'success': instance.success,
  'message': instance.message,
  'data': instance.data,
};

FindRoomByIpData _$FindRoomByIpDataFromJson(Map<String, dynamic> json) =>
    FindRoomByIpData(
      ip: json['ip'] as String,
      room: Room.fromJson(json['room'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$FindRoomByIpDataToJson(FindRoomByIpData instance) =>
    <String, dynamic>{'ip': instance.ip, 'room': instance.room};
