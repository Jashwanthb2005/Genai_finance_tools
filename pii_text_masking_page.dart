
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

class PiiTextMaskingPage extends StatefulWidget {
  const PiiTextMaskingPage({super.key});

  @override
  _PiiTextMaskingPageState createState() => _PiiTextMaskingPageState();
}

class _PiiTextMaskingPageState extends State<PiiTextMaskingPage> {
  final TextEditingController _textController = TextEditingController();
  String _result = '';
  bool _isLoading = false;

  Future<void> _maskText() async {
    print('Input text: ${_textController.text}');
    if (_textController.text.isEmpty) {
      setState(() {
        _result = 'Please enter text to mask';
      });
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      print('Attempting to call http://192.168.115.20:8000/mask');
      var response = await http.post(
        Uri.parse('http://192.168.115.20:8000/mask'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'text': _textController.text}),
      ).timeout(const Duration(seconds: 10), onTimeout: () {
        throw TimeoutException('Request to server timed out');
      });
      print('Mask response status: ${response.statusCode}');
      print('Mask response body: ${response.body}');

      if (response.statusCode == 200) {
        setState(() {
          _result = 'Masked text: ${jsonDecode(response.body)['masked_text']}';
          _isLoading = false;
        });
      } else {
        setState(() {
          _result = 'Server error: ${response.statusCode} - ${response.body}';
          _isLoading = false;
        });
      }
    } catch (e, stackTrace) {
      print('Mask error: $e');
      print('Stack trace: $stackTrace');
      setState(() {
        _result = 'Error masking text: $e';
        _isLoading = false;
      });
    }
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
              constraints: BoxConstraints(
                minHeight: screenHeight, // Ensure content fills the screen height
              ),
              child: Padding(
                padding: EdgeInsets.all(isSmallScreen ? 16.0 : 24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center, // Center content vertically
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Text PII Masking',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Enter text to mask sensitive information.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 20),
                    ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: screenWidth * 0.9,
                      ),
                      child: Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        color: Colors.white.withOpacity(0.9),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: TextField(
                            controller: _textController,
                            decoration: InputDecoration(
                              labelText: 'Enter text to mask',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              labelStyle: const TextStyle(color: Colors.black54),
                              prefixIcon: const Icon(
                                Icons.text_fields,
                                color: Color(0xFF4A90E2),
                              ),
                            ),
                            maxLines: 4,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: screenWidth * 0.9,
                      ),
                      child: Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        color: Colors.white.withOpacity(0.9),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: ElevatedButton.icon(
                            onPressed: _isLoading ? null : _maskText,
                            icon: const Icon(Icons.security, size: 20),
                            label: const Text('Mask Text'),
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
                              textStyle: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: screenWidth * 0.9,
                      ),
                      child: Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        color: Colors.white.withOpacity(0.9),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: _isLoading
                              ? const Center(
                                  child: CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white),
                                  ),
                                )
                              : Text(
                                  _result.isEmpty
                                      ? 'Result will appear here'
                                      : _result,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.black87,
                                  ),
                                ),
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
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pop(context),
        backgroundColor: Colors.blue.shade600,
        child: const Icon(Icons.arrow_back),
      ),
    );
  }
}     