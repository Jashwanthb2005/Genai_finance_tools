import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'services/detr_service.dart';

class DetrScreen extends HookWidget {
  const DetrScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final detrService = DetrService();
    final isLoading = useState(false);
    final maskedImage = useState<String?>(null);
    final originalImage = useState<String?>(null);

    Future<void> pickAndPredict() async {
      isLoading.value = true;
      maskedImage.value = null;
      originalImage.value = null;

      try {
        var results = await detrService.predictImage();
        if (results != null) {
          String maskedImageBase64 = results['masked_image']!;
          String imagePath = results['imagePath']!;
          final directory = await getApplicationDocumentsDirectory();
          final timestamp = DateTime.now().millisecondsSinceEpoch;
          final file = File('${directory.path}/masked_image_$timestamp.png');
          await file.writeAsBytes(
              base64Decode(maskedImageBase64.replaceFirst('data:image/png;base64,', '')));
          maskedImage.value = maskedImageBase64;
          originalImage.value = imagePath;
          isLoading.value = false;
        } else {
          isLoading.value = false;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to process image'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        isLoading.value = false;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }

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
                minHeight: MediaQuery.of(context).size.height,
              ),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20.0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20.0),
                        child: Image.asset(
                          'assets/pii.jpg',
                          height: 200,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    const Text(
                      'Create Masked Image',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Upload an image to generate a masked version.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 30),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        ElevatedButton.icon(
                          onPressed: pickAndPredict,
                          icon: const Icon(
                            Icons.upload_file,
                            color: Colors.purple,
                          ),
                          label: const Text('Upload Image for Masking'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: const Color(0xFF4A90E2),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 40,
                              vertical: 15,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                            textStyle: const TextStyle(fontSize: 16),
                          ),
                        ),
                        const SizedBox(height: 24),
                        if (isLoading.value)
                          const SpinKitCircle(color: Colors.blue, size: 50.0),
                        if (originalImage.value != null || maskedImage.value != null)
                          Column(
                            children: [
                              if (originalImage.value != null)
                                Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    children: [
                                      const Text(
                                        'Original Image',
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(12.0),
                                        child: Image.file(
                                          File(originalImage.value!),
                                          fit: BoxFit.contain,
                                          height: 200,
                                          errorBuilder: (context, error, stackTrace) =>
                                              const Icon(
                                            Icons.error,
                                            color: Colors.red,
                                            size: 48,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              if (maskedImage.value != null)
                                Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    children: [
                                      const Text(
                                        'Masked Image',
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(12.0),
                                        child: Image.memory(
                                          base64Decode(
                                            maskedImage.value!.replaceFirst(
                                              'data:image/png;base64,',
                                              '',
                                            ),
                                          ),
                                          fit: BoxFit.contain,
                                          height: 200,
                                          errorBuilder: (context, error, stackTrace) =>
                                              const Icon(
                                            Icons.error,
                                            color: Colors.red,
                                            size: 48,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                      ],
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