import '../models/room.dart';
import '../services/auth_service.dart';
import '../utils/constants.dart';
import 'api_service.dart';

class RoomService {
  // Get list of rooms with optional filters
  static Future<RoomListResponse> getRooms({
    bool? active,
    String? search,
    String sortBy = 'name',
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

      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }

      final uri = Uri.parse('${ApiConstants.baseUrl}/api/rooms')
          .replace(queryParameters: queryParams);

      final response = await ApiService.get(
        endpoint: '${uri.path}?${uri.query}',
        token: token,
      );

      return RoomListResponse.fromJson(response);
    } catch (e) {
      throw Exception('Gagal mengambil data ruangan: ${e.toString()}');
    }
  }

  // Get room detail by ID
  static Future<RoomResponse> getRoomById(int id) async {
    try {
      final token = await AuthService.getAccessToken();
      if (token == null) {
        throw Exception('Token tidak ditemukan');
      }

      final response = await ApiService.get(
        endpoint: '/api/rooms/$id',
        token: token,
      );

      return RoomResponse.fromJson(response);
    } catch (e) {
      throw Exception('Gagal mengambil detail ruangan: ${e.toString()}');
    }
  }

  // Create new room
  static Future<RoomResponse> createRoom({
    required String name,
    String? description,
    required String ipRangeStart,
    required String ipRangeEnd,
    String? subnetMask,
    String? gateway,
    String? dnsServer,
    bool isActive = true,
    int? capacity,
    Map<String, dynamic>? additionalInfo,
  }) async {
    try {
      final token = await AuthService.getAccessToken();
      if (token == null) {
        throw Exception('Token tidak ditemukan');
      }

      final requestBody = <String, dynamic>{
        'name': name,
        'ip_range_start': ipRangeStart,
        'ip_range_end': ipRangeEnd,
        'is_active': isActive,
      };

      if (description != null) requestBody['description'] = description;
      if (subnetMask != null) requestBody['subnet_mask'] = subnetMask;
      if (gateway != null) requestBody['gateway'] = gateway;
      if (dnsServer != null) requestBody['dns_server'] = dnsServer;
      if (capacity != null) requestBody['capacity'] = capacity;
      if (additionalInfo != null) requestBody['additional_info'] = additionalInfo;

      final response = await ApiService.post(
        endpoint: '/api/rooms',
        body: requestBody,
        token: token,
      );

      return RoomResponse.fromJson(response);
    } catch (e) {
      throw Exception('Gagal membuat ruangan: ${e.toString()}');
    }
  }

  // Update room
  static Future<RoomResponse> updateRoom({
    required int id,
    String? name,
    String? description,
    String? ipRangeStart,
    String? ipRangeEnd,
    String? subnetMask,
    String? gateway,
    String? dnsServer,
    bool? isActive,
    int? capacity,
    Map<String, dynamic>? additionalInfo,
  }) async {
    try {
      final token = await AuthService.getAccessToken();
      if (token == null) {
        throw Exception('Token tidak ditemukan');
      }

      final requestBody = <String, dynamic>{};

      if (name != null) requestBody['name'] = name;
      if (description != null) requestBody['description'] = description;
      if (ipRangeStart != null) requestBody['ip_range_start'] = ipRangeStart;
      if (ipRangeEnd != null) requestBody['ip_range_end'] = ipRangeEnd;
      if (subnetMask != null) requestBody['subnet_mask'] = subnetMask;
      if (gateway != null) requestBody['gateway'] = gateway;
      if (dnsServer != null) requestBody['dns_server'] = dnsServer;
      if (isActive != null) requestBody['is_active'] = isActive;
      if (capacity != null) requestBody['capacity'] = capacity;
      if (additionalInfo != null) requestBody['additional_info'] = additionalInfo;

      final response = await ApiService.put(
        endpoint: '/api/rooms/$id',
        body: requestBody,
        token: token,
      );

      return RoomResponse.fromJson(response);
    } catch (e) {
      throw Exception('Gagal mengupdate ruangan: ${e.toString()}');
    }
  }

  // Delete room
  static Future<Map<String, dynamic>> deleteRoom(int id) async {
    try {
      final token = await AuthService.getAccessToken();
      if (token == null) {
        throw Exception('Token tidak ditemukan');
      }

      final response = await ApiService.delete(
        endpoint: '/api/rooms/$id',
        token: token,
      );

      return response;
    } catch (e) {
      throw Exception('Gagal menghapus ruangan: ${e.toString()}');
    }
  }

  // Get available IPs in room
  static Future<AvailableIpsResponse> getAvailableIps(int roomId) async {
    try {
      final token = await AuthService.getAccessToken();
      if (token == null) {
        throw Exception('Token tidak ditemukan');
      }

      final response = await ApiService.get(
        endpoint: '/api/rooms/$roomId/available-ips',
        token: token,
      );

      return AvailableIpsResponse.fromJson(response);
    } catch (e) {
      throw Exception('Gagal mengambil daftar IP tersedia: ${e.toString()}');
    }
  }

  // Find room by IP address
  static Future<FindRoomByIpResponse> findRoomByIp(String ip) async {
    try {
      final token = await AuthService.getAccessToken();
      if (token == null) {
        throw Exception('Token tidak ditemukan');
      }

      final response = await ApiService.post(
        endpoint: '/api/rooms/find-by-ip',
        body: {'ip': ip},
        token: token,
      );

      return FindRoomByIpResponse.fromJson(response);
    } catch (e) {
      throw Exception('Gagal mencari ruangan berdasarkan IP: ${e.toString()}');
    }
  }
}