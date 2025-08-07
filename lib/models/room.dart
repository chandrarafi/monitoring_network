import 'package:json_annotation/json_annotation.dart';

part 'room.g.dart';

@JsonSerializable()
class Room {
  final int id;
  final String name;
  final String? description;
  @JsonKey(name: 'ip_range_start')
  final String? ipRangeStart;
  @JsonKey(name: 'ip_range_end')
  final String? ipRangeEnd;
  @JsonKey(name: 'ip_range_display')
  final String? ipRangeDisplay;
  @JsonKey(name: 'total_ips')
  final int? totalIps;
  @JsonKey(name: 'subnet_mask')
  final String? subnetMask;
  final String? gateway;
  @JsonKey(name: 'dns_server')
  final String? dnsServer;
  @JsonKey(name: 'is_active')
  final bool? isActive;
  final int? capacity;
  @JsonKey(name: 'additional_info')
  final Map<String, dynamic>? additionalInfo;
  @JsonKey(name: 'created_at')
  final String? createdAt;
  @JsonKey(name: 'updated_at')
  final String? updatedAt;

  const Room({
    required this.id,
    required this.name,
    this.description,
    this.ipRangeStart,
    this.ipRangeEnd,
    this.ipRangeDisplay,
    this.totalIps,
    this.subnetMask,
    this.gateway,
    this.dnsServer,
    this.isActive,
    this.capacity,
    this.additionalInfo,
    this.createdAt,
    this.updatedAt,
  });

  factory Room.fromJson(Map<String, dynamic> json) => _$RoomFromJson(json);
  Map<String, dynamic> toJson() => _$RoomToJson(this);

  @override
  String toString() {
    return 'Room{id: $id, name: $name, ipRange: $ipRangeDisplay}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Room && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

@JsonSerializable()
class RoomListResponse {
  final bool success;
  final String message;
  final List<Room> data;
  final PaginationInfo? pagination;

  const RoomListResponse({
    required this.success,
    required this.message,
    required this.data,
    this.pagination,
  });

  factory RoomListResponse.fromJson(Map<String, dynamic> json) =>
      _$RoomListResponseFromJson(json);
  Map<String, dynamic> toJson() => _$RoomListResponseToJson(this);
}

@JsonSerializable()
class RoomResponse {
  final bool success;
  final String message;
  final Room? data;

  const RoomResponse({
    required this.success,
    required this.message,
    this.data,
  });

  factory RoomResponse.fromJson(Map<String, dynamic> json) =>
      _$RoomResponseFromJson(json);
  Map<String, dynamic> toJson() => _$RoomResponseToJson(this);
}

@JsonSerializable()
class PaginationInfo {
  @JsonKey(name: 'current_page')
  final int currentPage;
  @JsonKey(name: 'per_page')
  final int perPage;
  final int total;
  @JsonKey(name: 'last_page')
  final int lastPage;

  const PaginationInfo({
    required this.currentPage,
    required this.perPage,
    required this.total,
    required this.lastPage,
  });

  factory PaginationInfo.fromJson(Map<String, dynamic> json) =>
      _$PaginationInfoFromJson(json);
  Map<String, dynamic> toJson() => _$PaginationInfoToJson(this);
}

@JsonSerializable()
class AvailableIpsResponse {
  final bool success;
  final String message;
  final AvailableIpsData data;

  const AvailableIpsResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory AvailableIpsResponse.fromJson(Map<String, dynamic> json) =>
      _$AvailableIpsResponseFromJson(json);
  Map<String, dynamic> toJson() => _$AvailableIpsResponseToJson(this);
}

@JsonSerializable()
class AvailableIpsData {
  @JsonKey(name: 'room_name')
  final String roomName;
  @JsonKey(name: 'ip_range')
  final String ipRange;
  @JsonKey(name: 'total_ips')
  final int totalIps;
  @JsonKey(name: 'available_ips')
  final List<String> availableIps;

  const AvailableIpsData({
    required this.roomName,
    required this.ipRange,
    required this.totalIps,
    required this.availableIps,
  });

  factory AvailableIpsData.fromJson(Map<String, dynamic> json) =>
      _$AvailableIpsDataFromJson(json);
  Map<String, dynamic> toJson() => _$AvailableIpsDataToJson(this);
}

@JsonSerializable()
class FindRoomByIpResponse {
  final bool success;
  final String message;
  final FindRoomByIpData? data;

  const FindRoomByIpResponse({
    required this.success,
    required this.message,
    this.data,
  });

  factory FindRoomByIpResponse.fromJson(Map<String, dynamic> json) =>
      _$FindRoomByIpResponseFromJson(json);
  Map<String, dynamic> toJson() => _$FindRoomByIpResponseToJson(this);
}

@JsonSerializable()
class FindRoomByIpData {
  final String ip;
  final Room room;

  const FindRoomByIpData({
    required this.ip,
    required this.room,
  });

  factory FindRoomByIpData.fromJson(Map<String, dynamic> json) =>
      _$FindRoomByIpDataFromJson(json);
  Map<String, dynamic> toJson() => _$FindRoomByIpDataToJson(this);
}