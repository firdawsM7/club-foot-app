import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/api_service.dart';

class TrainingProvider with ChangeNotifier {
  List<Entrainement> _trainings = [];
  bool _isLoading = false;
  String? _error;

  List<Entrainement> get trainings => _trainings;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchTrainings(String role) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _trainings = await ApiService.getAllEntrainements(role);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addTraining(Entrainement entrainement) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final newTraining = await ApiService.createEntrainement(entrainement);
      _trainings.insert(0, newTraining);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateTraining(Entrainement entrainement) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final updatedTraining = await ApiService.updateEntrainement(entrainement);
      final index = _trainings.indexWhere((t) => t.id == updatedTraining.id);
      if (index != -1) {
        _trainings[index] = updatedTraining;
      }
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteTraining(int id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await ApiService.deleteEntrainement(id);
      _trainings.removeWhere((t) => t.id == id);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
