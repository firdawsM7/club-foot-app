import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';
import '../models/models.dart';

class ApiService {
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
  }

  static Future<void> removeToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
  }

  static Future<Map<String, String>> getHeaders() async {
    final token = await getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // ==================== AUTH ====================
  
  static Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await http.post(
      Uri.parse(ApiConfig.login),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      await saveToken(data['token']);
      return data;
    } else {
      throw Exception('Échec de connexion');
    }
  }

  static Future<Map<String, dynamic>> register(User user, String password) async {
    final userData = user.toJson();
    userData['password'] = password;
    
    final response = await http.post(
      Uri.parse(ApiConfig.register),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(userData),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Échec d\'inscription');
    }
  }

  static Future<void> logout() async {
    await removeToken();
  }

  // ==================== USERS ====================
  
  static Future<List<User>> getAllUsers() async {
    final response = await http.get(
      Uri.parse(ApiConfig.adminUsers),
      headers: await getHeaders(),
    );

    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => User.fromJson(json)).toList();
    } else {
      throw Exception('Erreur de chargement des utilisateurs');
    }
  }

  static Future<User> createUser(User user) async {
    final userData = user.toJson();
    userData['password'] = 'password'; // Default password required by backend
    
    final response = await http.post(
      Uri.parse(ApiConfig.adminUsers),
      headers: await getHeaders(),
      body: jsonEncode(userData),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return User.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Erreur de création de l\'utilisateur (Status: ${response.statusCode})');
    }
  }

  static Future<User> updateUser(User user) async {
    final response = await http.put(
      Uri.parse('${ApiConfig.adminUsers}/${user.id}'),
      headers: await getHeaders(),
      body: jsonEncode(user.toJson()),
    );

    if (response.statusCode == 200) {
      return User.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Erreur de modification de l\'utilisateur');
    }
  }

  static Future<void> deleteUser(int id) async {
    final response = await http.delete(
      Uri.parse('${ApiConfig.adminUsers}/$id'),
      headers: await getHeaders(),
    );

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Erreur de suppression de l\'utilisateur');
    }
  }

  // ==================== JOUEURS ====================
  
  static Future<List<Joueur>> getAllJoueurs(String role) async {
    String url;
    if (role == 'ADMIN') {
      url = ApiConfig.adminJoueurs;
    } else if (role == 'ENCADRANT') {
      url = ApiConfig.encadrantJoueurs;
    } else {
      url = ApiConfig.adherentJoueurs;
    }

    final response = await http.get(
      Uri.parse(url),
      headers: await getHeaders(),
    );

    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Joueur.fromJson(json)).toList();
    } else {
      throw Exception('Erreur de chargement des joueurs');
    }
  }

  static Future<Joueur> createJoueur(String role, Joueur joueur) async {
    String url = role == 'ADMIN' ? ApiConfig.adminJoueurs : ApiConfig.encadrantJoueurs;
    final response = await http.post(
      Uri.parse(url),
      headers: await getHeaders(),
      body: jsonEncode(joueur.toJson()),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return Joueur.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Erreur de création du joueur');
    }
  }

  static Future<Joueur> updateJoueur(String role, Joueur joueur) async {
    String url = role == 'ADMIN' ? ApiConfig.adminJoueurs : ApiConfig.encadrantJoueurs;
    final response = await http.put(
      Uri.parse('$url/${joueur.id}'),
      headers: await getHeaders(),
      body: jsonEncode(joueur.toJson()),
    );

    if (response.statusCode == 200) {
      return Joueur.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Erreur de modification du joueur');
    }
  }

  static Future<void> deleteJoueur(String role, int id) async {
    String url = role == 'ADMIN' ? ApiConfig.adminJoueurs : ApiConfig.encadrantJoueurs;
    // Note: If encadrant doesn't have delete player in backend, it might fail.
    final response = await http.delete(
      Uri.parse('$url/$id'),
      headers: await getHeaders(),
    );

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Erreur de suppression du joueur');
    }
  }

  // ==================== ÉQUIPES ====================
  
  static Future<List<Equipe>> getAllEquipes(String role) async {
    String url;
    if (role == 'ADMIN') {
      url = ApiConfig.adminEquipes;
    } else if (role == 'ENCADRANT') {
      url = ApiConfig.encadrantEquipes;
    } else {
      url = ApiConfig.adherentEquipes;
    }

    final response = await http.get(
      Uri.parse(url),
      headers: await getHeaders(),
    );

    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Equipe.fromJson(json)).toList();
    } else {
      throw Exception('Erreur de chargement des équipes');
    }
  }

  static Future<Equipe> createEquipe(String role, Equipe equipe) async {
    String url = role == 'ADMIN' ? ApiConfig.adminEquipes : ApiConfig.encadrantEquipes;
    final response = await http.post(
      Uri.parse(url),
      headers: await getHeaders(),
      body: jsonEncode(equipe.toJson()),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return Equipe.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Erreur de création de l\'équipe');
    }
  }

  static Future<Equipe> updateEquipe(String role, Equipe equipe) async {
    String url = role == 'ADMIN' ? ApiConfig.adminEquipes : ApiConfig.encadrantEquipes;
    final response = await http.put(
      Uri.parse('$url/${equipe.id}'),
      headers: await getHeaders(),
      body: jsonEncode(equipe.toJson()),
    );

    if (response.statusCode == 200) {
      return Equipe.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Erreur de modification de l\'équipe');
    }
  }

  static Future<void> deleteEquipe(String role, int id) async {
    // Note: Admin only typically
    final response = await http.delete(
      Uri.parse('${ApiConfig.adminEquipes}/$id'),
      headers: await getHeaders(),
    );

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Erreur de suppression de l\'équipe');
    }
  }

  // ==================== ENTRAÎNEMENTS ====================
  
  static Future<List<Entrainement>> getAllEntrainements(String role) async {
    String url;
    if (role == 'ADMIN') {
      url = ApiConfig.adminEntrainements;
    } else if (role == 'ENCADRANT') {
      url = ApiConfig.encadrantEntrainements;
    } else {
      url = ApiConfig.adherentEntrainements;
    }

    final response = await http.get(
      Uri.parse(url),
      headers: await getHeaders(),
    );

    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Entrainement.fromJson(json)).toList();
    } else {
      throw Exception('Erreur de chargement des entraînements');
    }
  }

  static Future<Entrainement> createEntrainement(Entrainement entrainement) async {
    final response = await http.post(
      Uri.parse(ApiConfig.adminEntrainements),
      headers: await getHeaders(),
      body: jsonEncode({
        'equipe': {'id': entrainement.equipeId},
        'dateHeure': entrainement.dateHeure,
        'lieu': entrainement.lieu,
        'duree': entrainement.duree,
        'objectif': entrainement.objectif,
        'exercices': entrainement.exercices,
        'statut': entrainement.statut,
        'notes': entrainement.notes,
        if (entrainement.encadrantId != null) 'encadrant': {'id': entrainement.encadrantId},
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return Entrainement.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Erreur de création de l\'entraînement');
    }
  }

  static Future<Entrainement> updateEntrainement(Entrainement entrainement) async {
    final response = await http.put(
      Uri.parse('${ApiConfig.adminEntrainements}/${entrainement.id}'),
      headers: await getHeaders(),
      body: jsonEncode({
        'equipe': {'id': entrainement.equipeId},
        'dateHeure': entrainement.dateHeure,
        'lieu': entrainement.lieu,
        'duree': entrainement.duree,
        'objectif': entrainement.objectif,
        'exercices': entrainement.exercices,
        'statut': entrainement.statut,
        'notes': entrainement.notes,
        if (entrainement.encadrantId != null) 'encadrant': {'id': entrainement.encadrantId},
      }),
    );

    if (response.statusCode == 200) {
      return Entrainement.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Erreur de modification de l\'entraînement');
    }
  }

  static Future<void> deleteEntrainement(int id) async {
    final response = await http.delete(
      Uri.parse('${ApiConfig.adminEntrainements}/$id'),
      headers: await getHeaders(),
    );

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Erreur de suppression de l\'entraînement');
    }
  }

  // ==================== MATCHS ====================
  
  static Future<List<Match>> getAllMatchs(String role) async {
    String url;
    if (role == 'ADMIN') {
      url = ApiConfig.adminMatchs;
    } else if (role == 'ENCADRANT') {
      url = ApiConfig.encadrantMatchs;
    } else {
      url = ApiConfig.adherentMatchs;
    }

    final response = await http.get(
      Uri.parse(url),
      headers: await getHeaders(),
    );

    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Match.fromJson(json)).toList();
    } else {
      throw Exception('Erreur de chargement des matchs');
    }
  }

  static Future<Match> createMatch(String role, Match match) async {
    String url = role == 'ADMIN' ? ApiConfig.adminMatchs : ApiConfig.encadrantMatchs;
    final response = await http.post(
      Uri.parse(url),
      headers: await getHeaders(),
      body: jsonEncode(match.toJson()),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return Match.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Erreur de création du match');
    }
  }

  static Future<Match> updateMatch(String role, Match match) async {
    String url = role == 'ADMIN' ? ApiConfig.adminMatchs : ApiConfig.encadrantMatchs;
    final response = await http.put(
      Uri.parse('$url/${match.id}'),
      headers: await getHeaders(),
      body: jsonEncode(match.toJson()),
    );

    if (response.statusCode == 200) {
      return Match.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Erreur de modification du match');
    }
  }

  static Future<void> deleteMatch(String role, int id) async {
    String url = role == 'ADMIN' ? ApiConfig.adminMatchs : ApiConfig.encadrantMatchs;
    final response = await http.delete(
      Uri.parse('$url/$id'),
      headers: await getHeaders(),
    );

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Erreur de suppression du match');
    }
  }
}