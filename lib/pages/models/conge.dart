class Conge {
  final String id;
  final String dateDebut;
  final String dateFin;
  final String typeConge;
  final String statut; 
  final String? commentaire;
  final String? attestation;


  Conge({
    required this.id,
    required this.dateDebut,
    required this.dateFin,
    required this.typeConge,
    required this.statut,
    this.commentaire,
    this.attestation
  });

  factory Conge.fromJson(Map<String, dynamic> json) {
    return Conge(
      id: json['_id'],
      dateDebut: json['dateDebut'],
      dateFin: json['dateFin'],
      typeConge: json['typeConge'],
      statut: json['statut'],
      commentaire: json['commentaire'],
      attestation: json['attestation']
    );
  }
}
