export 'document.dart';

// User Model
class User {
  final int? id;
  final String email;
  final String nom;
  final String prenom;
  final String? telephone;
  final String? adresse;
  final String? dateNaissance;
  final String? photoUrl;
  final String role;
  final bool actif;
  final String? dateInscription;
  final String? derniereConnexion;

  User({
    this.id,
    required this.email,
    required this.nom,
    required this.prenom,
    this.telephone,
    this.adresse,
    this.dateNaissance,
    this.photoUrl,
    required this.role,
    this.actif = true,
    this.dateInscription,
    this.derniereConnexion,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      email: json['email'] ?? '',
      nom: json['nom'] ?? '',
      prenom: json['prenom'] ?? '',
      telephone: json['telephone'],
      adresse: json['adresse'],
      dateNaissance: json['dateNaissance'],
      photoUrl: json['photo'],
      role: json['role'] ?? 'INSCRIT',
      actif: json['actif'] ?? true,
      dateInscription: json['dateInscription'],
      derniereConnexion: json['derniereConnexion'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'nom': nom,
      'prenom': prenom,
      'telephone': telephone,
      'adresse': adresse,
      'dateNaissance': dateNaissance,
      'photo': photoUrl,
      'role': role,
      'actif': actif,
    };
  }
}

// Joueur Model
class Joueur {
  final int? id;
  final String nom;
  final String prenom;
  final String? dateNaissance;
  final String? nationalite;
  final String poste;
  final int? numeroMaillot;
  final double? poids;
  final double? taille;
  final String? photoUrl;
  final int? equipeId;
  final bool actif;
  final String? notes;

  final String? numLicence;

  Joueur({
    this.id,
    required this.nom,
    required this.prenom,
    this.dateNaissance,
    this.nationalite,
    required this.poste,
    this.numeroMaillot,
    this.poids,
    this.taille,
    this.photoUrl,
    this.equipeId,
    this.actif = true,
    this.notes,
    this.numLicence,
  });

  factory Joueur.fromJson(Map<String, dynamic> json) {
    return Joueur(
      id: json['id'],
      nom: json['nom'] ?? '',
      prenom: json['prenom'] ?? '',
      dateNaissance: json['dateNaissance'],
      nationalite: json['nationalite'],
      poste: json['poste'] ?? '',
      numeroMaillot: json['numeroMaillot'],
      poids: json['poids']?.toDouble(),
      taille: json['taille']?.toDouble(),
      photoUrl: json['photo'],
      equipeId: json['equipe']?['id'],
      actif: json['actif'] ?? true,
      notes: json['notes'],
      numLicence: json['numLicence'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nom': nom,
      'prenom': prenom,
      'dateNaissance': dateNaissance,
      'nationalite': nationalite,
      'poste': poste,
      'numeroMaillot': numeroMaillot,
      'poids': poids,
      'taille': taille,
      'photo': photoUrl,
      'actif': actif,
      'notes': notes,
      'numLicence': numLicence,
    };
  }
}

// Equipe Model
class Equipe {
  final int? id;
  final String nom;
  final String? categorie;
  final int? encadrantId;
  final bool active;
  final String? description;

  Equipe({
    this.id,
    required this.nom,
    this.categorie,
    this.encadrantId,
    this.active = true,
    this.description,
  });

  factory Equipe.fromJson(Map<String, dynamic> json) {
    return Equipe(
      id: json['id'],
      nom: json['nom'] ?? '',
      categorie: json['categorie'],
      encadrantId: json['encadrant']?['id'],
      active: json['active'] ?? true,
      description: json['description'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nom': nom,
      'categorie': categorie,
      'active': active,
      'description': description,
    };
  }
}

// Entrainement Model
class Entrainement {
  final int? id;
  final int equipeId;
  final String dateHeure;
  final String lieu;
  final int? duree;
  final String? objectif;
  final String? exercices;
  final int? encadrantId;
  final String statut;
  final String? notes;

  Entrainement({
    this.id,
    required this.equipeId,
    required this.dateHeure,
    required this.lieu,
    this.duree,
    this.objectif,
    this.exercices,
    this.encadrantId,
    this.statut = 'PLANIFIE',
    this.notes,
  });

  factory Entrainement.fromJson(Map<String, dynamic> json) {
    return Entrainement(
      id: json['id'],
      equipeId: json['equipe']?['id'] ?? 0,
      dateHeure: json['dateHeure'] ?? '',
      lieu: json['lieu'] ?? '',
      duree: json['duree'],
      objectif: json['objectif'],
      exercices: json['exercices'],
      encadrantId: json['encadrant']?['id'],
      statut: json['statut'] ?? 'PLANIFIE',
      notes: json['notes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'dateHeure': dateHeure,
      'lieu': lieu,
      'duree': duree,
      'objectif': objectif,
      'exercices': exercices,
      'statut': statut,
      'notes': notes,
    };
  }
}

// Match Model
class Match {
  final int? id;
  final int equipeId;
  final String adversaire;
  final String dateHeure;
  final String lieu;
  final String type;
  final int? scoreEquipe;
  final int? scoreAdversaire;
  final String statut;
  final String? notes;
  final String? composition;
  final String? competition;

  Match({
    this.id,
    required this.equipeId,
    required this.adversaire,
    required this.dateHeure,
    required this.lieu,
    this.type = 'AMICAL',
    this.scoreEquipe,
    this.scoreAdversaire,
    this.statut = 'PLANIFIE',
    this.notes,
    this.composition,
    this.competition,
  });

  factory Match.fromJson(Map<String, dynamic> json) {
    return Match(
      id: json['id'],
      equipeId: json['equipe']?['id'] ?? 0,
      adversaire: json['adversaire'] ?? '',
      dateHeure: json['dateHeure'] ?? '',
      lieu: json['lieu'] ?? '',
      type: json['type'] ?? 'AMICAL',
      scoreEquipe: json['scoreEquipe'],
      scoreAdversaire: json['scoreAdversaire'],
      statut: json['statut'] ?? 'PLANIFIE',
      notes: json['notes'],
      composition: json['composition'],
      competition: json['competition'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'adversaire': adversaire,
      'dateHeure': dateHeure,
      'lieu': lieu,
      'type': type,
      'scoreEquipe': scoreEquipe,
      'scoreAdversaire': scoreAdversaire,
      'statut': statut,
      'notes': notes,
      'composition': composition,
      'competition': competition,
    };
  }
}