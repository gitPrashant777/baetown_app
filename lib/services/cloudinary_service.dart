import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:crypto/crypto.dart';
import 'package:mime/mime.dart';
import 'cloudinary_config.dart';

class CloudinaryService {
  static final Dio _dio = Dio();
  
  // Upload single image to Cloudinary using direct HTTP API
  static Future<CloudinaryResponse> uploadImage(
    File imageFile, {
    String? folder,
    String? publicId,
    Map<String, dynamic>? tags,
    String imageType = 'product',
  }) async {
    try {
      print('☁️ Starting Cloudinary upload...');
      
      if (!CloudinaryConfig.isConfigured) {
        throw CloudinaryException('Cloudinary not configured. Please update CloudinaryConfig with your credentials.');
      }
      
      // Generate timestamp for signed upload
      final timestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      
      // Prepare upload parameters
      final uploadParams = <String, dynamic>{
        'timestamp': timestamp.toString(),
        'folder': folder ?? CloudinaryConfig.getFolderPath(imageType),
      };
      
      if (publicId != null) {
        uploadParams['public_id'] = publicId;
      }
      
      if (tags != null) {
        uploadParams['tags'] = tags.keys.join(',');
      }
      
      // Generate signature for secure upload
      final signature = _generateSignature(uploadParams, CloudinaryConfig.apiSecret);
      uploadParams['signature'] = signature;
      uploadParams['api_key'] = CloudinaryConfig.apiKey;
      
      // Prepare form data with file
      final fileName = imageFile.path.split('/').last;
      final mimeType = lookupMimeType(imageFile.path) ?? 'image/jpeg';
      
      final formData = FormData.fromMap({
        ...uploadParams,
        'file': await MultipartFile.fromFile(
          imageFile.path,
          filename: fileName,
          contentType: DioMediaType.parse(mimeType),
        ),
      });
      
      print('📤 Uploading to: ${CloudinaryConfig.uploadUrl}');
      print('📁 Folder: ${uploadParams['folder']}');
      print('📝 File: $fileName ($mimeType)');
      
      // Upload to Cloudinary
      final response = await _dio.post(
        CloudinaryConfig.uploadUrl,
        data: formData,
        options: Options(
          headers: {'Content-Type': 'multipart/form-data'},
          receiveTimeout: const Duration(seconds: 60),
          sendTimeout: const Duration(seconds: 60),
        ),
      );
      
      if (response.statusCode == 200) {
        final responseData = response.data;
        print('✅ Upload successful!');
        print('🔗 Image URL: ${responseData['secure_url']}');
        print('📊 Size: ${responseData['bytes']} bytes');
        
        return CloudinaryResponse.fromJson(responseData);
      } else {
        throw CloudinaryException('Upload failed with status: ${response.statusCode}');
      }
    } on DioException catch (e) {
      print('❌ Dio error during upload: ${e.message}');
      if (e.response != null) {
        print('❌ Response status: ${e.response?.statusCode}');
        print('❌ Response data: ${e.response?.data}');
      }
      throw CloudinaryException('Network error: ${e.message}');
    } catch (e) {
      print('❌ Unexpected error during upload: $e');
      throw CloudinaryException('Upload failed: $e');
    }
  }
  
  // Upload multiple images
  static Future<List<CloudinaryResponse>> uploadMultipleImages(
    List<File> imageFiles, {
    String? folder,
    String imageType = 'product',
    Function(int completed, int total)? onProgress,
  }) async {
    final results = <CloudinaryResponse>[];
    
    for (int i = 0; i < imageFiles.length; i++) {
      try {
        print('📤 Uploading image ${i + 1}/${imageFiles.length}');
        
        final result = await uploadImage(
          imageFiles[i],
          folder: folder,
          imageType: imageType,
        );
        
        results.add(result);
        onProgress?.call(i + 1, imageFiles.length);
        
        // Small delay to avoid rate limiting
        if (i < imageFiles.length - 1) {
          await Future.delayed(const Duration(milliseconds: 500));
        }
      } catch (e) {
        print('❌ Failed to upload image ${i + 1}: $e');
        // Continue with other uploads even if one fails
      }
    }
    
    return results;
  }
  
  // Upload image from bytes (useful for web)
  static Future<CloudinaryResponse> uploadImageFromBytes(
    Uint8List imageBytes,
    String fileName, {
    String? folder,
    String? publicId,
    String imageType = 'product',
  }) async {
    try {
      if (!CloudinaryConfig.isConfigured) {
        throw CloudinaryException('Cloudinary not configured');
      }
      
      final timestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      
      final uploadParams = <String, dynamic>{
        'timestamp': timestamp.toString(),
        'upload_preset': CloudinaryConfig.uploadPreset,
        'folder': folder ?? CloudinaryConfig.getFolderPath(imageType),
      };
      
      if (publicId != null) {
        uploadParams['public_id'] = publicId;
      }
      
      final signature = _generateSignature(uploadParams, CloudinaryConfig.apiSecret);
      uploadParams['signature'] = signature;
      uploadParams['api_key'] = CloudinaryConfig.apiKey;
      
      final formData = FormData.fromMap({
        ...uploadParams,
        'file': MultipartFile.fromBytes(
          imageBytes,
          filename: fileName,
          contentType: DioMediaType.parse(lookupMimeType(fileName) ?? 'image/jpeg'),
        ),
      });
      
      final response = await _dio.post(
        CloudinaryConfig.uploadUrl,
        data: formData,
        options: Options(
          headers: {'Content-Type': 'multipart/form-data'},
          receiveTimeout: const Duration(seconds: 30),
          sendTimeout: const Duration(seconds: 30),
        ),
      );
      
      if (response.statusCode == 200) {
        return CloudinaryResponse.fromJson(response.data);
      } else {
        throw CloudinaryException('Upload failed with status: ${response.statusCode}');
      }
    } catch (e) {
      throw CloudinaryException('Upload from bytes failed: $e');
    }
  }
  
  // Delete image from Cloudinary
  static Future<bool> deleteImage(String publicId) async {
    try {
      if (!CloudinaryConfig.isConfigured) {
        throw CloudinaryException('Cloudinary not configured');
      }
      
      final timestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      
      final deleteParams = <String, dynamic>{
        'public_id': publicId,
        'timestamp': timestamp.toString(),
      };
      
      final signature = _generateSignature(deleteParams, CloudinaryConfig.apiSecret);
      deleteParams['signature'] = signature;
      deleteParams['api_key'] = CloudinaryConfig.apiKey;
      
      final deleteUrl = 'https://api.cloudinary.com/v1_1/${CloudinaryConfig.cloudName}/image/destroy';
      
      final response = await _dio.post(
        deleteUrl,
        data: deleteParams,
        options: Options(
          headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        ),
      );
      
      return response.statusCode == 200 && response.data['result'] == 'ok';
    } catch (e) {
      print('❌ Failed to delete image: $e');
      return false;
    }
  }
  
  // Generate signed URL with transformations
  static String getOptimizedImageUrl(
    String publicId, {
    String transformation = 'medium',
    Map<String, String>? customTransformations,
  }) {
    if (customTransformations != null) {
      final transformString = customTransformations.entries
          .map((e) => '${e.key}_${e.value}')
          .join(',');
      return 'https://res.cloudinary.com/${CloudinaryConfig.cloudName}/image/upload/$transformString/$publicId';
    }
    
    return CloudinaryConfig.getImageUrl(publicId, transformation: transformation);
  }
  
  // Generate signature for secure uploads
  static String _generateSignature(Map<String, dynamic> params, String apiSecret) {
    // Sort parameters alphabetically
    final sortedParams = Map.fromEntries(
      params.entries.toList()..sort((a, b) => a.key.compareTo(b.key)),
    );
    
    // Create parameter string
    final paramString = sortedParams.entries
        .map((e) => '${e.key}=${e.value}')
        .join('&');
    
    // Add API secret
    final stringToSign = paramString + apiSecret;
    
    // Generate SHA1 hash
    final bytes = utf8.encode(stringToSign);
    final digest = sha1.convert(bytes);
    
    return digest.toString();
  }
  
  // Test Cloudinary connection
  static Future<bool> testConnection() async {
    try {
      if (!CloudinaryConfig.isConfigured) {
        print('❌ Cloudinary not configured');
        return false;
      }
      
      // Test with a simple ping to the API
      final response = await _dio.get(
        'https://api.cloudinary.com/v1_1/${CloudinaryConfig.cloudName}/image/list',
        queryParameters: {'max_results': 1},
        options: Options(
          headers: {
            'Authorization': 'Basic ${base64Encode(utf8.encode('${CloudinaryConfig.apiKey}:${CloudinaryConfig.apiSecret}'))}',
          },
        ),
      );
      
      return response.statusCode == 200;
    } catch (e) {
      print('❌ Cloudinary connection test failed: $e');
      return false;
    }
  }
}

// Response model for Cloudinary uploads
class CloudinaryResponse {
  final String publicId;
  final String secureUrl;
  final String url;
  final int width;
  final int height;
  final String format;
  final String resourceType;
  final int bytes;
  final String? folder;
  final List<String>? tags;
  
  CloudinaryResponse({
    required this.publicId,
    required this.secureUrl,
    required this.url,
    required this.width,
    required this.height,
    required this.format,
    required this.resourceType,
    required this.bytes,
    this.folder,
    this.tags,
  });
  
  factory CloudinaryResponse.fromJson(Map<String, dynamic> json) {
    return CloudinaryResponse(
      publicId: json['public_id'] ?? '',
      secureUrl: json['secure_url'] ?? '',
      url: json['url'] ?? '',
      width: json['width'] ?? 0,
      height: json['height'] ?? 0,
      format: json['format'] ?? '',
      resourceType: json['resource_type'] ?? '',
      bytes: json['bytes'] ?? 0,
      folder: json['folder'],
      tags: json['tags'] != null ? List<String>.from(json['tags']) : null,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'public_id': publicId,
      'secure_url': secureUrl,
      'url': url,
      'width': width,
      'height': height,
      'format': format,
      'resource_type': resourceType,
      'bytes': bytes,
      'folder': folder,
      'tags': tags,
    };
  }
}

// Custom exception for Cloudinary errors
class CloudinaryException implements Exception {
  final String message;
  
  CloudinaryException(this.message);
  
  @override
  String toString() => 'CloudinaryException: $message';
}
