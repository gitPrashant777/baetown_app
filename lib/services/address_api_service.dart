import 'package:shop/services/api_config.dart';
import 'package:shop/services/api_service.dart';

import '../models/AddressModel.dart';

class AddressApiService {
  final ApiService _apiService = ApiService();

  // Fetch all addresses
  Future<List<AddressModel>> getAddresses() async {
    try {
      final response = await _apiService.get<Map<String, dynamic>>(
        ApiConfig.addressEndpoint,
        requiresAuth: true,
      );

      if (response.success && response.data != null) {
        final List<dynamic> list = response.data!['addresses'] ?? [];
        return list.map((e) => AddressModel.fromJson(e)).toList();
      }
      return [];
    } catch (e) {
      print('Error fetching addresses: $e');
      return [];
    }
  }

  // Add a new address
  Future<bool> addAddress(AddressModel address) async {
    try {
      final response = await _apiService.post<Map<String, dynamic>>(
        ApiConfig.newAddressEndpoint,
        body: address.toJson(),
        requiresAuth: true,
      );
      return response.success;
    } catch (e) {
      return false;
    }
  }

  // Update an address
  Future<bool> updateAddress(String id, AddressModel address) async {
    try {
      final endpoint = ApiConfig.updateAddressEndpoint.replaceAll('{id}', id);
      final response = await _apiService.put<Map<String, dynamic>>(
        endpoint,
        body: address.toJson(),
        requiresAuth: true,
      );
      return response.success;
    } catch (e) {
      return false;
    }
  }

  // Delete an address
  Future<bool> deleteAddress(String id) async {
    try {
      final endpoint = ApiConfig.deleteAddressEndpoint.replaceAll('{id}', id);
      final response = await _apiService.delete<Map<String, dynamic>>(
        endpoint,
        requiresAuth: true,
      );
      return response.success;
    } catch (e) {
      return false;
    }
  }
}