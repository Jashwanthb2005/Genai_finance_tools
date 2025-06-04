

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';

class DocumentClassificationPage extends StatefulWidget {
  const DocumentClassificationPage({super.key});

  @override
  State<DocumentClassificationPage> createState() => _DocumentClassificationPageState();
}

class _DocumentClassificationPageState extends State<DocumentClassificationPage> {
  File? _selectedFile;
  Uint8List? _fileBytes;
  String? _fileName;
  String? _prediction;
  String? _confidence;
  String? _error;
  bool _loading = false;

  final String baseUrl = 'http://192.168.115.20:8000';

  Future<void> pickDocument() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'docx', 'txt', 'jpg', 'jpeg', 'png'],
    );

    if (result != null) {
      setState(() {
        _fileName = result.files.single.name;
        if (kIsWeb) {
          _fileBytes = result.files.single.bytes;
          _selectedFile = null;
        } else {
          _selectedFile = File(result.files.single.path!);
          _fileBytes = null;
        }
        _prediction = null;
        _confidence = null;
        _error = null;
      });
    }
  }

  Future<void> classifyDocument() async {
    if (_selectedFile == null && _fileBytes == null) return;

    setState(() {
      _loading = true;
      _prediction = null;
      _confidence = null;
      _error = null;
    });

    var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/classification/predict'));

    try {
      if (_selectedFile != null) {
        request.files.add(await http.MultipartFile.fromPath('file', _selectedFile!.path));
      } else if (_fileBytes != null) {
        request.files.add(http.MultipartFile.fromBytes('file', _fileBytes!, filename: _fileName ?? 'upload.file'));
      }

      var response = await request.send();

      if (response.statusCode == 200) {
        var responseData = await response.stream.bytesToString();
        var decoded = jsonDecode(responseData);
        setState(() {
          _prediction = decoded['prediction'];
          _confidence = decoded['confidence'].toString();
        });
      } else {
        var responseData = await response.stream.bytesToString();
        var decoded = jsonDecode(responseData);
        setState(() {
          _error = decoded['error'] ?? 'Classification failed';
        });
      }
    } catch (e) {
      setState(() => _error = "Failed to connect to server.");
    }

    setState(() => _loading = false);
  }

  Widget _buildFilePreview() {
    if (_selectedFile != null && _isImage(_selectedFile!.path)) {
      return Image.file(_selectedFile!, height: 150, fit: BoxFit.cover);
    } else if (_fileBytes != null && _isImage(_fileName ?? '')) {
      return Image.memory(_fileBytes!, height: 150, fit: BoxFit.cover);
    } else {
      return const Icon(Icons.insert_drive_file, size: 50, color: Color(0xFF4A90E2));
    }
  }

  bool _isImage(String path) {
    final ext = path.toLowerCase();
    return ext.endsWith('.png') || ext.endsWith('.jpg') || ext.endsWith('.jpeg');
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenHeight < 600;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color.fromARGB(255, 106, 111, 117), Color(0xFFD3E0EA)],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: screenHeight),
              child: Padding(
                padding: EdgeInsets.all(isSmallScreen ? 16.0 : 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Document Classification',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Upload a document to detect its category.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 14, color: Colors.white70),
                    ),
                    const SizedBox(height: 20),
                    ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: screenWidth * 0.9),
                      child: Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        color: Colors.white.withOpacity(0.9),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              if (_selectedFile != null || _fileBytes != null) _buildFilePreview()
                              else const Text(
                                'No document selected',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
                              ),
                              if (_fileName != null) ...[
                                const SizedBox(height: 8),
                                Text(_fileName!, style: const TextStyle(color: Colors.black54)),
                              ],
                              const SizedBox(height: 16),
                              ElevatedButton.icon(
                                onPressed: pickDocument,
                                icon: const Icon(Icons.folder_open, size: 20),
                                label: const Text('Pick Document'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF4A90E2),
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                  textStyle: const TextStyle(fontSize: 14),
                                ),
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton.icon(
                                onPressed: classifyDocument,
                                icon: const Icon(Icons.analytics_outlined, size: 20),
                                label: const Text('Classify Document'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF4A90E2),
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                  textStyle: const TextStyle(fontSize: 14),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    if (_loading)
                      const Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      ),
                    if (_prediction != null)
                      _buildResultCard('Prediction', _prediction!),
                    if (_confidence != null)
                      _buildResultCard('Confidence', _confidence!),
                    if (_error != null)
                      _buildResultCard('Error', _error!, isError: true),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildResultCard(String title, String value, {bool isError = false}) {
    return Padding(
      padding: const EdgeInsets.only(top: 12.0),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        color: Colors.white.withOpacity(0.9),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isError ? Colors.red : Colors.black87,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  color: isError ? Colors.red : Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
