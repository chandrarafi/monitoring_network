// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dhcp_lease.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DhcpLease _$DhcpLeaseFromJson(Map<String, dynamic> json) => DhcpLease(
  id: _parseIntIdNullable(json['id']),
  address: json['address'] as String,
  macAddress: json['mac_address'] as String,
  roomId: _parseIntIdNullable(json['room_id']),
  server: json['server'] as String?,
  clientId: json['client_id'] as String?,
  comment: json['comment'] as String?,
  disabled: json['disabled'] as bool? ?? false,
  status: json['status'] as String?,
  isDynamic: json['dynamic'] as bool?,
  active: json['active'] as bool?,
  syncedAt: json['synced_at'] as String?,
  createdAt: json['created_at'] as String?,
  updatedAt: json['updated_at'] as String?,
  room: json['room'] == null
      ? null
      : Room.fromJson(json['room'] as Map<String, dynamic>),
);

Map<String, dynamic> _$DhcpLeaseToJson(DhcpLease instance) => <String, dynamic>{
  'id': instance.id,
  'address': instance.address,
  'mac_address': instance.macAddress,
  'room_id': instance.roomId,
  'server': instance.server,
  'client_id': instance.clientId,
  'comment': instance.comment,
  'disabled': instance.disabled,
  'status': instance.status,
  'dynamic': instance.isDynamic,
  'active': instance.active,
  'synced_at': instance.syncedAt,
  'created_at': instance.createdAt,
  'updated_at': instance.updatedAt,
  'room': instance.room,
};

DhcpLeaseResponse _$DhcpLeaseResponseFromJson(Map<String, dynamic> json) =>
    DhcpLeaseResponse(
      success: json['success'] as bool,
      message: json['message'] as String,
      data: json['data'] == null
          ? null
          : DhcpLease.fromJson(json['data'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$DhcpLeaseResponseToJson(DhcpLeaseResponse instance) =>
    <String, dynamic>{
      'success': instance.success,
      'message': instance.message,
      'data': instance.data,
    };

DhcpLeaseListResponse _$DhcpLeaseListResponseFromJson(
  Map<String, dynamic> json,
) => DhcpLeaseListResponse(
  success: json['success'] as bool,
  message: json['message'] as String,
  data: (json['data'] as List<dynamic>)
      .map((e) => DhcpLease.fromJson(e as Map<String, dynamic>))
      .toList(),
  pagination: json['pagination'] == null
      ? null
      : PaginationInfo.fromJson(json['pagination'] as Map<String, dynamic>),
);

Map<String, dynamic> _$DhcpLeaseListResponseToJson(
  DhcpLeaseListResponse instance,
) => <String, dynamic>{
  'success': instance.success,
  'message': instance.message,
  'data': instance.data,
  'pagination': instance.pagination,
};

SyncResult _$SyncResultFromJson(Map<String, dynamic> json) => SyncResult(
  totalSynced: _parseIntId(json['total_synced']),
  newLeases: _parseIntId(json['new_leases']),
  updatedLeases: _parseIntId(json['updated_leases']),
  inactiveLeases: _parseIntId(json['inactive_leases']),
  syncTime: json['sync_time'] as String,
);

Map<String, dynamic> _$SyncResultToJson(SyncResult instance) =>
    <String, dynamic>{
      'total_synced': instance.totalSynced,
      'new_leases': instance.newLeases,
      'updated_leases': instance.updatedLeases,
      'inactive_leases': instance.inactiveLeases,
      'sync_time': instance.syncTime,
    };

SyncResponse _$SyncResponseFromJson(Map<String, dynamic> json) => SyncResponse(
  success: json['success'] as bool,
  message: json['message'] as String,
  data: SyncResult.fromJson(json['data'] as Map<String, dynamic>),
);

Map<String, dynamic> _$SyncResponseToJson(SyncResponse instance) =>
    <String, dynamic>{
      'success': instance.success,
      'message': instance.message,
      'data': instance.data,
    };

MikrotikStatus _$MikrotikStatusFromJson(Map<String, dynamic> json) =>
    MikrotikStatus(
      host: json['host'] as String,
      port: _parseIntIdNullable(json['port']),
      username: json['username'] as String,
    );

Map<String, dynamic> _$MikrotikStatusToJson(MikrotikStatus instance) =>
    <String, dynamic>{
      'host': instance.host,
      'port': instance.port,
      'username': instance.username,
    };

MikrotikStatusResponse _$MikrotikStatusResponseFromJson(
  Map<String, dynamic> json,
) => MikrotikStatusResponse(
  success: json['success'] as bool,
  message: json['message'] as String,
  routerInfo: json['router_info'] == null
      ? null
      : MikrotikStatus.fromJson(json['router_info'] as Map<String, dynamic>),
);

Map<String, dynamic> _$MikrotikStatusResponseToJson(
  MikrotikStatusResponse instance,
) => <String, dynamic>{
  'success': instance.success,
  'message': instance.message,
  'router_info': instance.routerInfo,
};

DhcpUpdateData _$DhcpUpdateDataFromJson(Map<String, dynamic> json) =>
    DhcpUpdateData(
      id: _parseIntId(json['id']),
      mikrotikId: json['mikrotik_id'] as String?,
      address: json['address'] as String,
      macAddress: json['mac_address'] as String,
      updatedFields: (json['updated_fields'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      updatedLocation: json['updated_location'] as String,
      reason: json['reason'] as String?,
      mikrotikError: json['mikrotik_error'] as String?,
    );

Map<String, dynamic> _$DhcpUpdateDataToJson(DhcpUpdateData instance) =>
    <String, dynamic>{
      'id': instance.id,
      'mikrotik_id': instance.mikrotikId,
      'address': instance.address,
      'mac_address': instance.macAddress,
      'updated_fields': instance.updatedFields,
      'updated_location': instance.updatedLocation,
      'reason': instance.reason,
      'mikrotik_error': instance.mikrotikError,
    };

DhcpUpdateResponse _$DhcpUpdateResponseFromJson(Map<String, dynamic> json) =>
    DhcpUpdateResponse(
      success: json['success'] as bool,
      message: json['message'] as String,
      data: DhcpUpdateData.fromJson(json['data'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$DhcpUpdateResponseToJson(DhcpUpdateResponse instance) =>
    <String, dynamic>{
      'success': instance.success,
      'message': instance.message,
      'data': instance.data,
    };

DhcpDeletedLease _$DhcpDeletedLeaseFromJson(Map<String, dynamic> json) =>
    DhcpDeletedLease(
      address: json['address'] as String,
      macAddress: json['mac_address'] as String,
      comment: json['comment'] as String?,
    );

Map<String, dynamic> _$DhcpDeletedLeaseToJson(DhcpDeletedLease instance) =>
    <String, dynamic>{
      'address': instance.address,
      'mac_address': instance.macAddress,
      'comment': instance.comment,
    };

DhcpDeleteData _$DhcpDeleteDataFromJson(Map<String, dynamic> json) =>
    DhcpDeleteData(
      id: _parseIntId(json['id']),
      mikrotikId: json['mikrotik_id'] as String?,
      deletedLease: DhcpDeletedLease.fromJson(
        json['deleted_lease'] as Map<String, dynamic>,
      ),
      deletedFrom: (json['deleted_from'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      databaseUpdated: json['database_updated'] as bool?,
      reason: json['reason'] as String?,
      mikrotikError: json['mikrotik_error'] as String?,
    );

Map<String, dynamic> _$DhcpDeleteDataToJson(DhcpDeleteData instance) =>
    <String, dynamic>{
      'id': instance.id,
      'mikrotik_id': instance.mikrotikId,
      'deleted_lease': instance.deletedLease,
      'deleted_from': instance.deletedFrom,
      'database_updated': instance.databaseUpdated,
      'reason': instance.reason,
      'mikrotik_error': instance.mikrotikError,
    };

DhcpDeleteResponse _$DhcpDeleteResponseFromJson(Map<String, dynamic> json) =>
    DhcpDeleteResponse(
      success: json['success'] as bool,
      message: json['message'] as String,
      data: DhcpDeleteData.fromJson(json['data'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$DhcpDeleteResponseToJson(DhcpDeleteResponse instance) =>
    <String, dynamic>{
      'success': instance.success,
      'message': instance.message,
      'data': instance.data,
    };
