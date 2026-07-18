import 'dart:io';
import 'package:flutter/material.dart';
import '../services/api_service.dart';

enum ProcessingState { idle, uploading, processing, downloading, success, error }

class PdfProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();

  String _currentTool = '';
  List<File> _selectedFiles = [];
  ProcessingState _state = ProcessingState.idle;
  String _errorMessage = '';
  File? _resultFile;
  int _rotateAngle = 90;
  List<int> _pagesToDelete = [];

  String get currentTool => _currentTool;
  List<File> get selectedFiles => _selectedFiles;
  ProcessingState get state => _state;
  String get errorMessage => _errorMessage;
  File? get resultFile => _resultFile;
  int get rotateAngle => _rotateAngle;
  List<int> get pagesToDelete => _pagesToDelete;

  void setTool(String toolName) {
    _currentTool = toolName;
    reset();
  }

  void addFiles(List<File> files) {
    _selectedFiles.addAll(files);
    notifyListeners();
  }

  void removeFile(File file) {
    _selectedFiles.remove(file);
    notifyListeners();
  }

  void setRotateAngle(int angle) {
    _rotateAngle = angle;
    notifyListeners();
  }

  void setPagesToDelete(String pagesStr) {
    try {
      _pagesToDelete = pagesStr.split(',').map((e) => int.parse(e.trim()) - 1).toList();
    } catch (e) {
      _pagesToDelete = [];
    }
    notifyListeners();
  }

  void reset() {
    _selectedFiles = [];
    _state = ProcessingState.idle;
    _errorMessage = '';
    _resultFile = null;
    _rotateAngle = 90;
    _pagesToDelete = [];
    notifyListeners();
  }

  Future<void> processFiles() async {
    if (_selectedFiles.isEmpty) return;

    _state = ProcessingState.processing;
    _errorMessage = '';
    notifyListeners();

    try {
      File? result;
      switch (_currentTool) {
        case 'Merge PDF':
          if (_selectedFiles.length < 2) throw Exception("At least 2 files required.");
          result = await _apiService.mergePdfs(_selectedFiles);
          break;
        case 'Split PDF':
          result = await _apiService.splitPdf(_selectedFiles.first);
          break;
        case 'Image to PDF':
          result = await _apiService.imagesToPdf(_selectedFiles);
          break;
        case 'Compress PDF':
          result = await _apiService.compressPdf(_selectedFiles.first);
          break;
        case 'Rotate PDF':
          result = await _apiService.rotatePdf(_selectedFiles.first, _rotateAngle);
          break;
        case 'Delete Pages':
          if (_pagesToDelete.isEmpty) throw Exception("Please specify pages to delete (e.g. 1, 3).");
          result = await _apiService.deletePages(_selectedFiles.first, _pagesToDelete);
          break;
        default:
          throw Exception("Unknown tool.");
      }

      if (result != null) {
        _resultFile = result;
        _state = ProcessingState.success;
      } else {
        throw Exception("Failed to process file.");
      }
    } catch (e) {
      _errorMessage = e.toString();
      _state = ProcessingState.error;
    } finally {
      notifyListeners();
    }
  }
}
