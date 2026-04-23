import '../../../core/network/api_client.dart';

class CatalogService {
  final ApiClient _apiClient = ApiClient();

  /// Fetch districts for a specific city.
  Future<List<Map<String, dynamic>>> getDistricts(int cityId) async {
    try {
      final response = await _apiClient.dio.get(
        '/users/districts/',
        queryParameters: {'city_id': cityId},
      );
      
      if (response.data is List) {
        return List<Map<String, dynamic>>.from(response.data);
      }
      return [];
    } catch (e) {
      return [];
    }
  }
}
