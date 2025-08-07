import '../models/dhcp_lease.dart';
import '../services/auth_service.dart';
import '../utils/constants.dart';
import 'api_service.dart';

class DhcpService {
  // Get MikroTik connection status
  static Future<MikrotikStatusResponse> getMikrotikStatus() async {
    try {
      final token = await AuthService.getAccessToken();
      if (token == null) {
        throw Exception('Token tidak ditemukan');
      }

      final response = await ApiService.get(
        endpoint: '/api/mikrotik/status',
        token: token,
      );

      return MikrotikStatusResponse.fromJson(response);
    } catch (e) {
      throw Exception('Gagal mengecek status MikroTik: ${e.toString()}');
    }
  }

  // Get DHCP leases from database with filters
  static Future<DhcpLeaseListResponse> getDhcpLeasesFromDatabase({
    bool? active,
    int? roomId,
    String? status,
    String? search,
    String sortBy = 'address',
    String sortOrder = 'asc',
    int perPage = 15,
    int page = 1,
  }) async {
    try {
      final token = await AuthService.getAccessToken();
      if (token == null) {
        throw Exception('Token tidak ditemukan');
      }

      // Build query parameters
      final queryParams = <String, String>{
        'sort_by': sortBy,
        'sort_order': sortOrder,
        'per_page': perPage.toString(),
        'page': page.toString(),
      };

      if (active != null) {
        queryParams['active'] = active.toString();
      }

      if (roomId != null) {
        queryParams['room_id'] = roomId.toString();
      }

      if (status != null && status.isNotEmpty) {
        queryParams['status'] = status;
      }

      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }

      final uri = Uri.parse('${ApiConstants.baseUrl}/api/mikrotik/dhcp/leases/database')
          .replace(queryParameters: queryParams);

      final response = await ApiService.get(
        endpoint: '${uri.path}?${uri.query}',
        token: token,
      );

      return DhcpLeaseListResponse.fromJson(response);
    } catch (e) {
      throw Exception('Gagal mengambil DHCP leases dari database: ${e.toString()}');
    }
  }

  // Get DHCP leases from MikroTik directly
  static Future<DhcpLeaseListResponse> getDhcpLeasesFromMikrotik() async {
    try {
      final token = await AuthService.getAccessToken();
      if (token == null) {
        throw Exception('Token tidak ditemukan');
      }

      final response = await ApiService.get(
        endpoint: '/api/mikrotik/dhcp/leases',
        token: token,
      );

      return DhcpLeaseListResponse.fromJson(response);
    } catch (e) {
      throw Exception('Gagal mengambil DHCP leases dari MikroTik: ${e.toString()}');
    }
  }

  // Get DHCP leases by room
  static Future<DhcpLeaseListResponse> getDhcpLeasesByRoom(int roomId) async {
    try {
      final token = await AuthService.getAccessToken();
      if (token == null) {
        throw Exception('Token tidak ditemukan');
      }

      final response = await ApiService.get(
        endpoint: '/api/mikrotik/dhcp/leases/room/$roomId',
        token: token,
      );

      return DhcpLeaseListResponse.fromJson(response);
    } catch (e) {
      throw Exception('Gagal mengambil DHCP leases untuk ruangan: ${e.toString()}');
    }
  }

  // Get active DHCP leases
  static Future<DhcpLeaseListResponse> getActiveDhcpLeases() async {
    try {
      final token = await AuthService.getAccessToken();
      if (token == null) {
        throw Exception('Token tidak ditemukan');
      }

      final response = await ApiService.get(
        endpoint: '/api/mikrotik/dhcp/leases/active',
        token: token,
      );

      return DhcpLeaseListResponse.fromJson(response);
    } catch (e) {
      throw Exception('Gagal mengambil DHCP leases aktif: ${e.toString()}');
    }
  }

  // Get DHCP lease by IP
  static Future<DhcpLeaseResponse> getDhcpLeaseByIp(String ip) async {
    try {
      final token = await AuthService.getAccessToken();
      if (token == null) {
        throw Exception('Token tidak ditemukan');
      }

      final response = await ApiService.get(
        endpoint: '/api/mikrotik/dhcp/leases/ip/$ip',
        token: token,
      );

      return DhcpLeaseResponse.fromJson(response);
    } catch (e) {
      throw Exception('Gagal mengambil DHCP lease berdasarkan IP: ${e.toString()}');
    }
  }

  // Get DHCP lease by MAC address
  static Future<DhcpLeaseResponse> getDhcpLeaseByMac(String mac) async {
    try {
      final token = await AuthService.getAccessToken();
      if (token == null) {
        throw Exception('Token tidak ditemukan');
      }

      final response = await ApiService.get(
        endpoint: '/api/mikrotik/dhcp/leases/mac/$mac',
        token: token,
      );

      return DhcpLeaseResponse.fromJson(response);
    } catch (e) {
      throw Exception('Gagal mengambil DHCP lease berdasarkan MAC: ${e.toString()}');
    }
  }

  // Get DHCP lease by ID
  static Future<DhcpLeaseResponse> getDhcpLeaseById(String id) async {
    try {
      final token = await AuthService.getAccessToken();
      if (token == null) {
        throw Exception('Token tidak ditemukan');
      }

      final response = await ApiService.get(
        endpoint: '/api/mikrotik/dhcp/leases/id/$id',
        token: token,
      );

      return DhcpLeaseResponse.fromJson(response);
    } catch (e) {
      throw Exception('Gagal mengambil DHCP lease berdasarkan ID: ${e.toString()}');
    }
  }

  // Add DHCP lease with room integration
  static Future<DhcpLeaseResponse> addDhcpLease({
    required String address,
    required String macAddress,
    int? roomId,
    String? server,
    String? clientId,
    String? comment,
    bool disabled = false,
  }) async {
    try {
      final token = await AuthService.getAccessToken();
      if (token == null) {
        throw Exception('Token tidak ditemukan');
      }

      final requestBody = <String, dynamic>{
        'address': address,
        'mac_address': macAddress,
        'disabled': disabled,
      };

      if (roomId != null) requestBody['room_id'] = roomId;
      if (server != null) requestBody['server'] = server;
      if (clientId != null) requestBody['client_id'] = clientId;
      if (comment != null) requestBody['comment'] = comment;

      final response = await ApiService.post(
        endpoint: '/api/mikrotik/dhcp/leases',
        body: requestBody,
        token: token,
      );

      return DhcpLeaseResponse.fromJson(response);
    } catch (e) {
      throw Exception('Gagal menambahkan DHCP lease: ${e.toString()}');
    }
  }

  // Update DHCP lease
  static Future<DhcpUpdateResponse> updateDhcpLease({
    required String id,
    String? address,
    String? macAddress,
    int? roomId,
    String? server,
    String? clientId,
    String? comment,
    bool? disabled,
  }) async {
    try {
      final token = await AuthService.getAccessToken();
      if (token == null) {
        throw Exception('Token tidak ditemukan');
      }

      final requestBody = <String, dynamic>{};

      if (address != null) requestBody['address'] = address;
      if (macAddress != null) requestBody['mac_address'] = macAddress;
      if (roomId != null) requestBody['room_id'] = roomId;
      if (server != null) requestBody['server'] = server;
      if (clientId != null) requestBody['client_id'] = clientId;
      if (comment != null) requestBody['comment'] = comment;
      if (disabled != null) requestBody['disabled'] = disabled;

      final response = await ApiService.put(
        endpoint: '/api/mikrotik/dhcp/leases/$id',
        body: requestBody,
        token: token,
      );

      return DhcpUpdateResponse.fromJson(response);
    } catch (e) {
      // Extract more meaningful error message
      String errorMessage = e.toString();
      if (errorMessage.contains('Exception: ')) {
        errorMessage = errorMessage.replaceFirst('Exception: ', '');
      }
      if (errorMessage.contains('Gagal mengupdate DHCP lease: ')) {
        errorMessage = errorMessage.replaceFirst('Gagal mengupdate DHCP lease: ', '');
      }
      throw Exception('Gagal mengupdate DHCP lease: $errorMessage');
    }
  }

  // Delete DHCP lease
  static Future<DhcpDeleteResponse> deleteDhcpLease(String id) async {
    try {
      final token = await AuthService.getAccessToken();
      if (token == null) {
        throw Exception('Token tidak ditemukan');
      }

      final response = await ApiService.delete(
        endpoint: '/api/mikrotik/dhcp/leases/$id',
        token: token,
      );

      return DhcpDeleteResponse.fromJson(response);
    } catch (e) {
      // Extract more meaningful error message
      String errorMessage = e.toString();
      if (errorMessage.contains('Exception: ')) {
        errorMessage = errorMessage.replaceFirst('Exception: ', '');
      }
      if (errorMessage.contains('Gagal menghapus DHCP lease: ')) {
        errorMessage = errorMessage.replaceFirst('Gagal menghapus DHCP lease: ', '');
      }
      throw Exception('Gagal menghapus DHCP lease: $errorMessage');
    }
  }

  // Sync DHCP leases from MikroTik to database
  static Future<SyncResponse> syncDhcpLeases() async {
    try {
      final token = await AuthService.getAccessToken();
      if (token == null) {
        throw Exception('Token tidak ditemukan');
      }

      final response = await ApiService.post(
        endpoint: '/api/mikrotik/dhcp/leases/sync',
        body: {},
        token: token,
      );

      return SyncResponse.fromJson(response);
    } catch (e) {
      throw Exception('Gagal sinkronisasi DHCP leases: ${e.toString()}');
    }
  }
}