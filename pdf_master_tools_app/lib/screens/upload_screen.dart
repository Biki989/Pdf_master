import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/pdf_provider.dart';
import 'processing_screen.dart';

class UploadScreen extends StatelessWidget {
  const UploadScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<PdfProvider>(context);
    final files = provider.selectedFiles;

    return Scaffold(
      appBar: AppBar(title: Text(provider.currentTool)),
      body: Column(
        children: [
          Expanded(
            child: files.isEmpty
                ? const Center(child: Text("No files selected"))
                : ListView.builder(
                    itemCount: files.length,
                    itemBuilder: (context, index) {
                      final file = files[index];
                      final fileSize = (file.lengthSync() / 1024 / 1024).toStringAsFixed(2);
                      final fileName = file.path.split(Platform.pathSeparator).last;
                      return ListTile(
                        leading: const Icon(Icons.insert_drive_file),
                        title: Text(fileName),
                        subtitle: Text('$fileSize MB'),
                        trailing: IconButton(
                          icon: const Icon(Icons.remove_circle, color: Colors.red),
                          onPressed: () {
                            provider.removeFile(file);
                            if (provider.selectedFiles.isEmpty) {
                              Navigator.pop(context); // Go back if empty
                            }
                          },
                        ),
                      );
                    },
                  ),
          ),
          if (provider.currentTool == 'Rotate PDF')
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: DropdownButtonFormField<int>(
                value: provider.rotateAngle,
                decoration: const InputDecoration(labelText: 'Rotation Angle', border: OutlineInputBorder()),
                items: [90, 180, 270].map((angle) => DropdownMenuItem(value: angle, child: Text('$angle degrees'))).toList(),
                onChanged: (val) {
                  if (val != null) provider.setRotateAngle(val);
                },
              ),
            ),
          if (provider.currentTool == 'Delete Pages')
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: TextField(
                decoration: const InputDecoration(
                  labelText: 'Pages to Delete (e.g. 1, 3)',
                  border: OutlineInputBorder(),
                  hintText: 'Comma separated list of page numbers',
                ),
                keyboardType: TextInputType.number,
                onChanged: (val) => provider.setPagesToDelete(val),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: SizedBox(
              width: double.infinity,
              height: 55,
              child: FilledButton(
                onPressed: files.isEmpty
                    ? null
                    : () {
                        provider.processFiles();
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => const ProcessingScreen()),
                        );
                      },
                child: const Text("Process File", style: TextStyle(fontSize: 18)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
