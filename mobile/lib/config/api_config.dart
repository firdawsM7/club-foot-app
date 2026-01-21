class ApiConfig {
  // IMPORTANT: Changer cette URL selon votre configuration
  // Pour Android Emulator: 'http://10.0.2.2:8082/api'
  // Pour iOS Simulator: 'http://localhost:8082/api'
  // Pour appareil physique: 'http://VOTRE_IP:8082/api'
  static const String baseUrl = 'http://192.168.1.6:8082/api';
  
  // Auth endpoints
  static const String login = '$baseUrl/auth/login';
  static const String register = '$baseUrl/auth/register';
  static const String me = '$baseUrl/auth/me';
  
  // Admin endpoints
  static const String adminUsers = '$baseUrl/admin/users';
  static const String adminJoueurs = '$baseUrl/admin/joueurs';
  static const String adminEquipes = '$baseUrl/admin/equipes';
  static const String adminEntrainements = '$baseUrl/admin/entrainements';
  static const String adminMatchs = '$baseUrl/admin/matchs';
  static const String adminCotisations = '$baseUrl/admin/cotisations';
  static const String adminDocuments = '$baseUrl/admin/documents';
  static const String adminDocumentsUpload = '$adminDocuments/upload';
  static const String adminDocumentsExpiring = '$adminDocuments/expiring-soon';
  
  // Chat endpoints
  static const String chatHistory = '$baseUrl/chat/history';
  
  // Encadrant endpoints
  static const String encadrantJoueurs = '$baseUrl/encadrant/joueurs';
  static const String encadrantEquipes = '$baseUrl/encadrant/equipes';
  static const String encadrantEntrainements = '$baseUrl/encadrant/entrainements';
  static const String encadrantMatchs = '$baseUrl/encadrant/matchs';
  
  // Adherent endpoints
  static const String adherentProfil = '$baseUrl/adherent/profil';
  static const String adherentJoueurs = '$baseUrl/adherent/joueurs';
  static const String adherentEquipes = '$baseUrl/adherent/equipes';
  static const String adherentEntrainements = '$baseUrl/adherent/entrainements';
  static const String adherentMatchs = '$baseUrl/adherent/matchs';
  static const String adherentCotisations = '$baseUrl/adherent/cotisations';
}