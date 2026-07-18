import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:convert';

class ApiService {
  final Dio _dio = Dio();
  // Using 10.0.2.2 for Android emulator to access host localhost.
  // For iOS emulator or real devices, this should be your machine's IP address.
  final String baseUrl = "http://10.0.2.2:8000"; 

  Future<File?> _processRequest(String endpoint, FormData formData) async {
    try {
      final response = await _dio.post('$baseUrl$endpoint', data: formData);
      if (response.statusCode == 200 && response.data['status'] == 'success') {
        final downloadUrl = response.data['download_url'];
        return await _downloadFile('$baseUrl$downloadUrl');
      }
    } catch (e) {
      print('API Error on $endpoint: $e');
      rethrow;
    }
    return null;
  }

  Future<File> _downloadFile(String url) async {
    final dir = await getApplicationDocumentsDirectory();
    final fileName = url.split('/').last;
    final savePath = '${dir.path}/$fileName';
    
    await _dio.download(url, savePath);
    return File(savePath);
  }

  Future<File?> mergePdfs(List<File> files) async {
    final formData = FormData();
    for (var file in files) {
      formData.files.add(MapEntry(
        "files",
        await MultipartFile.fromFile(file.path, filename: file.path.split(Platform.pathSeparator).last),
      ));
    }
    return _processRequest('/merge-pdf', formData);
  }

  Future<File?> splitPdf(File file) async {
    final formData = FormData.fromMap({
      "file": await MultipartFile.fromFile(file.path, filename: file.path.split(Platform.pathSeparator).last),
    });
    return _processRequest('/split-pdf', formData);
  }

  Future<File?> imagesToPdf(List<File> files) async {
    final formData = FormData();
    for (var file in files) {
      formData.files.add(MapEntry(
        "files",
        await MultipartFile.fromFile(file.path, filename: file.path.split(Platform.pathSeparator).last),
      ));
    }
    return _processRequest('/image-to-pdf', formData);
  }

  Future<File?> compressPdf(File file) async {
    final formData = FormData.fromMap({
      "file": await MultipartFile.fromFile(file.path, filename: file.path.split(Platform.pathSeparator).last),
    });
    return _processRequest('/compress-pdf', formData);
  }

  Future<File?> rotatePdf(File file, int angle) async {
    final formData = FormData.fromMap({
      "angle": angle,
      "file": await MultipartFile.fromFile(file.path, filename: file.path.split(Platform.pathSeparator).last),
    });
    return _processRequest('/rotate-pdf', formData);
  }

  Future<File?> deletePages(File file, List<int> pagesDelete) async {
    final formData = FormData.fromMap({
      "pages": jsonEncode(pagesDelete),
      "file": await MultipartFile.fromFile(file.path, filename: file.path.split(Platform.pathSeparator).last),
    });
    return _processRequest('/delete-pages', formData);
  }
}
