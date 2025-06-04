
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as p;

class Summarization extends StatefulWidget {
  const Summarization({super.key});

  @override
  _SummarizationState createState() => _SummarizationState();
}

class _SummarizationState extends State<Summarization> {
  File? _selectedFile;
  Uint8List? _fileBytes;
  String? _fileName;
  String? _summary;
  bool _loading = false;
  final String baseUrl = 'http://192.168.115.20:8000';

  Future<void> pickDocument() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'docx', 'txt', 'jpg', 'jpeg', 'png', 'bmp'],
      withData: kIsWeb,
    );

    if (result != null) {
      _fileName = result.files.first.name;

      if (kIsWeb) {
        _fileBytes = result.files.first.bytes;
        _selectedFile = null;
      } else {
        _selectedFile = File(result.files.single.path!);
        _fileBytes = null;
      }

      setState(() {});
    }
  }

  Future<void> uploadDocument() async {
    if (_selectedFile == null && _fileBytes == null) return;

    setState(() => _loading = true);

    var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/summarize'));

    try {
      if (_selectedFile != null) {
        request.files.add(await http.MultipartFile.fromPath('file', _selectedFile!.path));
      } else if (_fileBytes != null) {
        request.files.add(http.MultipartFile.fromBytes('file', _fileBytes!, filename: _fileName ?? 'upload.pdf'));
      }

      var response = await request.send();

      if (response.statusCode == 200) {
        var responseData = await response.stream.bytesToString();
        var decoded = jsonDecode(responseData);
        setState(() {
          _summary = decoded['summary'];
        });
      } else {
        setState(() => _summary = "Error in summarization");
      }
    } catch (e) {
      setState(() => _summary = "Failed to connect to server.");
    }

    setState(() => _loading = false);
  }

  bool _isImageFile(String pathOrName) {
    final ext = p.extension(pathOrName).toLowerCase();
    return ['.jpg', '.jpeg', '.png', '.bmp'].contains(ext);
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
                      'Document Summarization',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Upload a document to generate a concise summary.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      color: Colors.white.withOpacity(0.9),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            if (_selectedFile != null && _isImageFile(_selectedFile!.path))
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.file(
                                  _selectedFile!,
                                  height: 200,
                                  fit: BoxFit.cover,
                                ),
                              )
                            else if (_fileBytes != null && _fileName != null && _isImageFile(_fileName!))
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.memory(
                                  _fileBytes!,
                                  height: 200,
                                  fit: BoxFit.cover,
                                ),
                              )
                            else if (_selectedFile != null || _fileBytes != null)
                              Column(
                                children: [
                                  const Icon(Icons.insert_drive_file, size: 50, color: Color(0xFF4A90E2)),
                                  const SizedBox(height: 8),
                                  Text(
                                    _fileName ?? _selectedFile!.path.split('/').last,
                                    style: const TextStyle(fontSize: 14, color: Colors.black87),
                                  ),
                                ],
                              )
                            else
                              const Text(
                                'No document selected',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                            const SizedBox(height: 16),
                            ElevatedButton.icon(
                              onPressed: pickDocument,
                              icon: const Icon(Icons.folder_open, size: 20),
                              label: const Text('Pick Document'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF4A90E2),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 10,
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton.icon(
                              onPressed: uploadDocument,
                              icon: const Icon(Icons.upload_file, size: 20),
                              label: const Text('Summarize Document'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF4A90E2),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 10,
                                ),
                              ),
                            ),
                          ],
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
                    if (_summary != null)
                      Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        color: Colors.white.withOpacity(0.9),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Summary',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                _summary!,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
