import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';

import '../providers/pdf_provider.dart';
import 'upload_screen.dart';

class ToolScreen extends StatelessWidget {
  final String toolName;
  final String toolDesc;

  const ToolScreen({super.key, required this.toolName, required this.toolDesc});

  Future<void> _pickFiles(BuildContext context) async {
    final provider = Provider.of<PdfProvider>(context, listen: false);
    provider.setTool(toolName);
    
    FileType fileType = FileType.custom;
    List<String> allowedExtensions = ['pdf'];
    bool allowMultiple = false;

    if (toolName == 'Image to PDF') {
      allowedExtensions = ['jpg', 'jpeg', 'png'];
      allowMultiple = true;
    } else if (toolName == 'Merge PDF') {
      allowMultiple = true;
    }

    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: fileType,
      allowedExtensions: allowedExtensions,
      allowMultiple: allowMultiple,
    );

    if (result != null) {
      if (!context.mounted) return;
      List<File> files = result.paths.map((path) => File(path!)).toList();
      provider.addFiles(files);
      
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const UploadScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(toolName)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.upload_file, size: 100, color: Theme.of(context).colorScheme.primary),
              const SizedBox(height: 24),
              Text(toolName, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              Text(toolDesc, textAlign: TextAlign.center, style: const TextStyle(fontSize: 16)),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: FilledButton.icon(
                  onPressed: () => _pickFiles(context),
                  icon: const Icon(Icons.add),
                  label: const Text("Upload Files", style: TextStyle(fontSize: 18)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
