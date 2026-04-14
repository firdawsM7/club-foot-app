import 'dart:io';
import 'package:flutter/material.dart';
import '../models/document.dart';
import '../services/document_service.dart';

class DocumentProvider with ChangeNotifier {
  List<Document> _documents = [];
  bool _isLoading = false;
  String? _error;

  List<Document> get documents => _documents;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadDocuments({int? userId, String? type, bool? expirant}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _documents = await DocumentService.getAllDocuments(
        userId: userId,
        type: type,
        expirant: expirant,
      );
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> uploadDocument({
    required File file,
    required int userId,
    required String type,
    DateTime? dateExpiration,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final newDoc = await DocumentService.uploadDocument(
        file: file,
        userId: userId,
        type: type,
        dateExpiration: dateExpiration,
      );
      _documents.insert(0, newDoc);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> validateDocument(int id) async {
    try {
      final updatedDoc = await DocumentService.validateDocument(id);
      final index = _documents.indexWhere((doc) => doc.id == id);
      if (index != -1) {
        _documents[index] = updatedDoc;
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> deleteDocument(int id) async {
    try {
      await DocumentService.deleteDocument(id);
      _documents.removeWhere((doc) => doc.id == id);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }
}
