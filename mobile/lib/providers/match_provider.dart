import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/api_service.dart';

class MatchProvider with ChangeNotifier {
  List<Match> _matchs = [];
  bool _isLoading = false;
  String? _error;

  List<Match> get matchs => _matchs;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchMatchs(String role) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _matchs = await ApiService.getAllMatchs(role);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addMatch(String role, Match match) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final newMatch = await ApiService.createMatch(role, match);
      _matchs.insert(0, newMatch);
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

  Future<bool> updateMatch(String role, Match match) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final updatedMatch = await ApiService.updateMatch(role, match);
      final index = _matchs.indexWhere((m) => m.id == updatedMatch.id);
      if (index != -1) {
        _matchs[index] = updatedMatch;
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

  Future<bool> deleteMatch(String role, int id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await ApiService.deleteMatch(role, id);
      _matchs.removeWhere((m) => m.id == id);
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
