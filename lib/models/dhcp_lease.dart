import 'package:json_annotation/json_annotation.dart';
import 'room.dart';

part 'dhcp_lease.g.dart';

// Helper functions to safely parse ID from String or num
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

@JsonSerializable()
class DhcpLease {
  @JsonKey(fromJson: _parseIntIdNullable)
  final int? id;
  final String address;
  @JsonKey(name: 'mac_address')
  final String macAddress;
  @JsonKey(name: 'room_id', fromJson: _parseIntIdNullable)
  final int? roomId;
  final String? server;
  @JsonKey(name: 'client_id')
  final String? clientId;
  final String? comment;
  final bool disabled;
  final String? status;
  @JsonKey(name: 'dynamic')
  final bool? isDynamic;
  final bool? active;
  @JsonKey(name: 'synced_at')
  final String? syncedAt;
  @JsonKey(name: 'created_at')
  final String? createdAt;
  @JsonKey(name: 'updated_at')
  final String? updatedAt;
  
  // Related room data
  final Room? room;

  const DhcpLease({
    this.id,
    required this.address,
    required this.macAddress,
    this.roomId,
    this.server,
    this.clientId,
    this.comment,
    this.disabled = false,
    this.status,
    this.isDynamic,
    this.active,
    this.syncedAt,
    this.createdAt,
    this.updatedAt,
    this.room,
  });

  factory DhcpLease.fromJson(Map<String, dynamic> json) => _$DhcpLeaseFromJson(json);
  Map<String, dynamic> toJson() => _$DhcpLeaseToJson(this);

  @override
  String toString() {
    return 'DhcpLease{id: $id, address: $address, macAddress: $macAddress, room: ${room?.name}}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DhcpLease && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  // Helper getters
  String get statusDisplay {
    // Prioritize MikroTik status (bound, waiting, etc) over database active status
    if (status != null && status!.isNotEmpty) {
      return status!.toUpperCase();
    }
    // Fallback to active field for status display
    if (active != null) {
      return active! ? 'AKTIF' : 'TIDAK AKTIF';
    }
    return 'UNKNOWN';
  }
  
  String get roomName => room?.name ?? 'No Room';
  bool get isActive => active ?? false;
  bool get isDisabled => disabled;
  bool get dynamicLease => isDynamic ?? false;
  bool get hasRoom => roomId != null && room != null;
}

@JsonSerializable()
class DhcpLeaseResponse {
  final bool success;
  final String message;
  final DhcpLease? data;

  const DhcpLeaseResponse({
    required this.success,
    required this.message,
    this.data,
  });

  factory DhcpLeaseResponse.fromJson(Map<String, dynamic> json) =>
      _$DhcpLeaseResponseFromJson(json);
  Map<String, dynamic> toJson() => _$DhcpLeaseResponseToJson(this);
}

@JsonSerializable()
class DhcpLeaseListResponse {
  final bool success;
  final String message;
  final List<DhcpLease> data;
  final PaginationInfo? pagination;

  const DhcpLeaseListResponse({
    required this.success,
    required this.message,
    required this.data,
    this.pagination,
  });

  factory DhcpLeaseListResponse.fromJson(Map<String, dynamic> json) =>
      _$DhcpLeaseListResponseFromJson(json);
  Map<String, dynamic> toJson() => _$DhcpLeaseListResponseToJson(this);
}

@JsonSerializable()
class SyncResult {
  @JsonKey(name: 'total_synced', fromJson: _parseIntId)
  final int totalSynced;
  @JsonKey(name: 'new_leases', fromJson: _parseIntId)
  final int newLeases;
  @JsonKey(name: 'updated_leases', fromJson: _parseIntId)
  final int updatedLeases;
  @JsonKey(name: 'inactive_leases', fromJson: _parseIntId)
  final int inactiveLeases;
  @JsonKey(name: 'sync_time')
  final String syncTime;

  const SyncResult({
    required this.totalSynced,
    required this.newLeases,
    required this.updatedLeases,
    required this.inactiveLeases,
    required this.syncTime,
  });

  factory SyncResult.fromJson(Map<String, dynamic> json) => _$SyncResultFromJson(json);
  Map<String, dynamic> toJson() => _$SyncResultToJson(this);
}

@JsonSerializable()
class SyncResponse {
  final bool success;
  final String message;
  final SyncResult data;

  const SyncResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory SyncResponse.fromJson(Map<String, dynamic> json) =>
      _$SyncResponseFromJson(json);
  Map<String, dynamic> toJson() => _$SyncResponseToJson(this);
}

@JsonSerializable()
class MikrotikStatus {
  final String host;
  @JsonKey(fromJson: _parseIntIdNullable)
  final int? port;
  final String username;

  const MikrotikStatus({
    required this.host,
    this.port,
    required this.username,
  });

  factory MikrotikStatus.fromJson(Map<String, dynamic> json) =>
      _$MikrotikStatusFromJson(json);
  Map<String, dynamic> toJson() => _$MikrotikStatusToJson(this);
}

@JsonSerializable()
class MikrotikStatusResponse {
  final bool success;
  final String message;
  @JsonKey(name: 'router_info')
  final MikrotikStatus? routerInfo;

  const MikrotikStatusResponse({
    required this.success,
    required this.message,
    this.routerInfo,
  });

  factory MikrotikStatusResponse.fromJson(Map<String, dynamic> json) =>
      _$MikrotikStatusResponseFromJson(json);
  Map<String, dynamic> toJson() => _$MikrotikStatusResponseToJson(this);
}

@JsonSerializable()
class DhcpUpdateData {
  @JsonKey(fromJson: _parseIntId)
  final int id;
  @JsonKey(name: 'mikrotik_id')
  final String? mikrotikId;
  final String address;
  @JsonKey(name: 'mac_address')
  final String macAddress;
  @JsonKey(name: 'updated_fields')
  final List<String>? updatedFields;
  @JsonKey(name: 'updated_location')
  final String updatedLocation;
  final String? reason;
  @JsonKey(name: 'mikrotik_error')
  final String? mikrotikError;

  const DhcpUpdateData({
    required this.id,
    this.mikrotikId,
    required this.address,
    required this.macAddress,
    this.updatedFields,
    required this.updatedLocation,
    this.reason,
    this.mikrotikError,
  });

  factory DhcpUpdateData.fromJson(Map<String, dynamic> json) =>
      _$DhcpUpdateDataFromJson(json);
  Map<String, dynamic> toJson() => _$DhcpUpdateDataToJson(this);

  // Helper getters
  bool get isMikrotikUpdated => updatedLocation == 'mikrotik_and_database';
  bool get isDatabaseOnly => updatedLocation == 'database_only';
  String get statusMessage => isMikrotikUpdated 
      ? 'Updated in both systems'
      : 'Updated in database only${reason != null ? ': $reason' : ''}';
}



@JsonSerializable()
class DhcpUpdateResponse {
  final bool success;
  final String message;
  final DhcpUpdateData data;

  const DhcpUpdateResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory DhcpUpdateResponse.fromJson(Map<String, dynamic> json) =>
      _$DhcpUpdateResponseFromJson(json);
  Map<String, dynamic> toJson() => _$DhcpUpdateResponseToJson(this);
}

@JsonSerializable()
class DhcpDeletedLease {
  final String address;
  @JsonKey(name: 'mac_address')
  final String macAddress;
  final String? comment;

  const DhcpDeletedLease({
    required this.address,
    required this.macAddress,
    this.comment,
  });

  factory DhcpDeletedLease.fromJson(Map<String, dynamic> json) =>
      _$DhcpDeletedLeaseFromJson(json);
  Map<String, dynamic> toJson() => _$DhcpDeletedLeaseToJson(this);
}

@JsonSerializable()
class DhcpDeleteData {
  @JsonKey(fromJson: _parseIntId)
  final int id;
  @JsonKey(name: 'mikrotik_id')
  final String? mikrotikId;
  @JsonKey(name: 'deleted_lease')
  final DhcpDeletedLease deletedLease;
  @JsonKey(name: 'deleted_from')
  final List<String> deletedFrom;
  @JsonKey(name: 'database_updated')
  final bool? databaseUpdated;
  final String? reason;
  @JsonKey(name: 'mikrotik_error')
  final String? mikrotikError;

  const DhcpDeleteData({
    required this.id,
    this.mikrotikId,
    required this.deletedLease,
    required this.deletedFrom,
    this.databaseUpdated,
    this.reason,
    this.mikrotikError,
  });

  factory DhcpDeleteData.fromJson(Map<String, dynamic> json) =>
      _$DhcpDeleteDataFromJson(json);
  Map<String, dynamic> toJson() => _$DhcpDeleteDataToJson(this);

  // Helper getters
  bool get isDeletedFromMikrotik => deletedFrom.contains('mikrotik');
  bool get isDeletedFromDatabase => deletedFrom.contains('database');
  bool get isFullyDeleted => isDeletedFromMikrotik && isDeletedFromDatabase;
  String get statusMessage => isFullyDeleted 
      ? 'Deleted from both systems'
      : 'Deleted from database only${reason != null ? ': $reason' : ''}';
}

@JsonSerializable()
class DhcpDeleteResponse {
  final bool success;
  final String message;
  final DhcpDeleteData data;

  const DhcpDeleteResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory DhcpDeleteResponse.fromJson(Map<String, dynamic> json) =>
      _$DhcpDeleteResponseFromJson(json);
  Map<String, dynamic> toJson() => _$DhcpDeleteResponseToJson(this);
}