import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'detr_screen.dart';
import 'document_classification_page.dart';
import 'summarization.dart';
import 'pii_text_masking_page.dart';
import 'question_answer.dart'; // New import for Question and Answer page

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  final user = FirebaseAuth.instance.currentUser;

  signout() async {
    await GoogleSignIn().signOut();
    await FirebaseAuth.instance.signOut();
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  void _showProfileDialog() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Profile Details',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundImage: user!.photoURL != null
                      ? NetworkImage(user!.photoURL!)
                      : null,
                  child: user!.photoURL == null
                      ? const Icon(Icons.person, size: 40)
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user!.displayName ?? 'User',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user!.email ?? 'No email',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.setString('displayName', user!.displayName ?? '');
              await prefs.setString('email', user!.email ?? '');
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _navigateToTask(String taskName) {
    switch (taskName) {
      case 'Image Masking':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const DetrScreen()),
        );
        break;
      case 'Document Classification':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => DocumentClassificationPage()),
        );
        break;
      case 'Document Summarization':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const Summarization()),
        );
        break;
      case 'Text PII Masking':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const PiiTextMaskingPage()),
        );
        break;
      case 'Question and Answering':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const QuestionAnswer()),
        );
        break;
    }
  }

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey('email') && prefs.containsKey('displayName')) {
      // Data is already loaded
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> tasks = [
      {'title': 'Image Masking', 'icon': Icons.image_search_rounded},
      {'title': 'Document Classification', 'icon': Icons.description},
      {'title': 'Document Summarization', 'icon': Icons.summarize},
      {'title': 'Text PII Masking', 'icon': Icons.security},
      {'title': 'Question and Answering', 'icon': Icons.question_answer},
    ];

    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color.fromARGB(255, 106, 111, 117), Color.fromARGB(255, 174, 197, 208)],
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
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(20.0),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20.0),
                            child: Image.asset(
                              'assets/home.jpg',
                              height: 200,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        const SizedBox(height: 30),
                        const Text(
                          'Welcome to FIN-GPT',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'Explore our powerful AI tools below.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white70,
                          ),
                        ),
                        const SizedBox(height: 30),
                        Text(
                          'jashwanthbandi400@gmail.com',
                          textAlign: TextAlign.center,
        
      
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[700],
                          ),
                        ),
                        const SizedBox(height: 30),
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 16.0,
                            mainAxisSpacing: 16.0,
                            childAspectRatio: 1.2,
                          ),
                          itemCount: tasks.length,
                          itemBuilder: (context, index) {
                            return GestureDetector(
                              onTap: () => _navigateToTask(tasks[index]['title']),
                              child: Card(
                                elevation: 4,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                color: Colors.white.withOpacity(0.9),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      tasks[index]['icon'],
                                      size: 40,
                                      color: const Color.fromARGB(255, 23, 24, 25),
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      tasks[index]['title'],
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: 16.0,
            right: 16.0,
            child: IconButton(
              icon: const Icon(Icons.person_rounded, size: 30),
              onPressed: _showProfileDialog,
              tooltip: 'Profile',
              color: Colors.white,
              padding: const EdgeInsets.all(12.0),
              style: IconButton.styleFrom(
                backgroundColor: Colors.blue.shade700.withOpacity(0.8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50),
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: signout,
        backgroundColor: Colors.red.shade600,
        child: const Icon(Icons.logout_rounded),
      ),
    );
  }
}