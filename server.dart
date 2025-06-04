import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'dart:convert';

class DetrService {
  final String apiUrl = "http://localhost:8000/predict"; // Replace with your API URL

  Future<Map<String, dynamic>?> predictImage() async {
    try {
      // Pick image
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);
      if (pickedFile == null) return null;

      // Create multipart request
      var request = http.MultipartRequest('POST', Uri.parse(apiUrl));
      request.files.add(await http.MultipartFile.fromPath('file', pickedFile.path));

      // Send request
      var response = await request.send();
      if (response.statusCode == 200) {
        var responseData = await response.stream.bytesToString();
        final result = jsonDecode(responseData);
        result['imagePath'] = pickedFile.path; // Store local image path
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