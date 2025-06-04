import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import 'package:crypto/crypto.dart';

class DetrService {
  final String apiUrl = "http://192.168.115.20:8000/predict";

  // Compute MD5 hash of file content for cache key
  Future<String> _getFileHash(String filePath) async {
    final file = File(filePath);
    final bytes = await file.readAsBytes();
    return md5.convert(bytes).toString();
  }

  // Get cache file path for a given image hash
  Future<File> _getCacheFile(String hash) async {
    final directory = await getTemporaryDirectory();
    return File('${directory.path}/detr_cache_$hash.json');
  }

  Future<Map<String, dynamic>?> predictImage() async {
    try {
      // Pick image from gallery
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);
      if (pickedFile == null) return null;

      // Compute hash of the image for cache key
      final imageHash = await _getFileHash(pickedFile.path);
      final cacheFile = await _getCacheFile(imageHash);

      // Check if cached response exists
      if (await cacheFile.exists()) {
        print('Received from cache');
        final cachedData = await cacheFile.readAsString();
        final result = jsonDecode(cachedData) as Map<String, dynamic>;
        result['imagePath'] = pickedFile.path; // Update imagePath
        return result;
      }

      // Create multipart request for API
      var request = http.MultipartRequest('POST', Uri.parse(apiUrl));
      request.files.add(await http.MultipartFile.fromPath('file', pickedFile.path));

      // Send request to API
      print('Sending POST request to $apiUrl');
      var response = await request.send();
      print('Response status: ${response.statusCode}');
      if (response.statusCode == 200) {
        var responseData = await response.stream.bytesToString();
        final result = jsonDecode(responseData) as Map<String, dynamic>;
        print('Received from API');
        result['imagePath'] = pickedFile.path; // Add original image path

        // Cache the response
        await cacheFile.writeAsString(jsonEncode(result));
        print('API response: $result'); // Debug log
        return result;
      } else {
        throw Exception('API call failed with status ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
      return null;
    }
  }
}