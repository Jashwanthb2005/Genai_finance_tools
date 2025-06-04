
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shimmer/shimmer.dart';

class QuestionAnswer extends StatefulWidget {
  const QuestionAnswer({super.key});

  @override
  _QuestionAnswerState createState() => _QuestionAnswerState();
}

class _QuestionAnswerState extends State<QuestionAnswer> {
  final TextEditingController _questionController = TextEditingController();
  String result = "";
  String program = "";
  String goldInds = "";
  bool isLoading = false;
  final String serverUrl = "http://192.168.115.20:8001";

  Future<void> sendQuestion() async {
    final question = _questionController.text.trim();
    if (question.isEmpty) return;

    setState(() {
      isLoading = true;
      result = "";
      program = "";
      goldInds = "";
    });

    try {
      final response = await http.post(
        Uri.parse('$serverUrl/question'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"question": question}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        setState(() {
          result = data['result'] ?? "No result available";
          program = data['program'] ?? "No program available";
          goldInds = data['gold_inds'].toString() ?? "No gold_inds available";
        });
      } else {
        setState(() {
          result = "Error: ${response.statusCode}\n${response.body}";
        });
      }
    } catch (e) {
      setState(() {
        result = "Exception occurred: $e";
      });
    }

    setState(() {
      isLoading = false;
    });
  }

  @override
  void dispose() {
    _questionController.dispose();
    super.dispose();
  }

  Widget shimmerLoading(double maxWidth) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        width: maxWidth,
        height: 60,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Widget displayResult(String content, String label, double maxWidth) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      color: Colors.white.withOpacity(0.9),
      child: Container(
        width: maxWidth,
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            if (label == "Gold Indices") ...[
              // Parse goldInds and display as bullet points
              Builder(builder: (context) {
                List<String> items = [];
                try {
                  // Split by semicolon and trim each item
                  items = content.split(';').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
                } catch (e) {
                  items = [content]; // Fallback to raw content if parsing fails
                }
                if (items.isEmpty) {
                  return const SelectableText(
                    "No gold indices available",
                    style: TextStyle(fontSize: 16, color: Colors.black87),
                  );
                }
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: items.map((item) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '• ',
                            style: TextStyle(fontSize: 16, color: Colors.black87),
                          ),
                          Expanded(
                            child: SelectableText(
                              item,
                              style: const TextStyle(fontSize: 16, color: Colors.black87),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                );
              }),
            ] else ...[
              SelectableText(
                content,
                style: const TextStyle(fontSize: 16, color: Colors.black87),
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
          child: LayoutBuilder(
            builder: (context, constraints) {
              final maxWidth = constraints.maxWidth;
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text(
                          'Question and Answering',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'Ask a question and get detailed answers.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white70,
                          ),
                        ),
                        const SizedBox(height: 30),
                        Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          color: Colors.white.withOpacity(0.9),
                          child: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Column(
                              children: [
                                TextField(
                                  controller: _questionController,
                                  decoration: InputDecoration(
                                    labelText: "Enter your question",
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    filled: true,
                                    fillColor: Colors.white,
                                  ),
                                  style: const TextStyle(color: Colors.black87),
                                ),
                                const SizedBox(height: 20),
                                ElevatedButton.icon(
                                  onPressed: isLoading ? null : sendQuestion,
                                  icon: isLoading
                                      ? const SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                          ),
                                        )
                                      : const Icon(Icons.send),
                                  label: const Text('Send Question'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF4A90E2),
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 20,
                                      vertical: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 30),
                        isLoading
                            ? Column(
                                children: [
                                  shimmerLoading(maxWidth),
                                  const SizedBox(height: 16),
                                  shimmerLoading(maxWidth),
                                  const SizedBox(height: 16),
                                  shimmerLoading(maxWidth),
                                ],
                              )
                            : result.isNotEmpty
                                ? Column(
                                    children: [
                                      displayResult(result, "Result", maxWidth),
                                      const SizedBox(height: 16),
                                      displayResult(program, "Program", maxWidth),
                                      const SizedBox(height: 16),
                                      displayResult(goldInds, "Gold Indices", maxWidth),
                                    ],
                                  )
                                : const SizedBox.shrink(),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}