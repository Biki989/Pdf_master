import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/pdf_provider.dart';
import 'result_screen.dart';

class ProcessingScreen extends StatefulWidget {
  const ProcessingScreen({super.key});

  @override
  State<ProcessingScreen> createState() => _ProcessingScreenState();
}

class _ProcessingScreenState extends State<ProcessingScreen> {
  @override
  void initState() {
    super.initState();
    // Start listening to provider state for completion
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<PdfProvider>(context, listen: false);
      provider.addListener(_onStateChange);
    });
  }

  void _onStateChange() {
    final provider = Provider.of<PdfProvider>(context, listen: false);
    if (!mounted) return;

    if (provider.state == ProcessingState.success || provider.state == ProcessingState.error) {
      provider.removeListener(_onStateChange);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const ResultScreen()),
      );
    }
  }

  @override
  void dispose() {
    // If popped early, try to remove listener
    // Provider unregistration handles this generally, but it's good practice.
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(strokeWidth: 6),
            const SizedBox(height: 40),
            Text(
              "Processing PDF...",
              style: TextStyle(
                fontSize: 24, 
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              "Please wait while we generate your output.",
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
