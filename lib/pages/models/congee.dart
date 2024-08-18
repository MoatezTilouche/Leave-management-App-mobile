class Congee {
  final String typeConge;
  final String dateDebut;
  final String dateFin;
  final String employeeId;
  final String? employeeName;

  Congee({
    required this.typeConge,
    required this.dateDebut,
    required this.dateFin,
    required this.employeeId,
    this.employeeName = 'Unknown',
  });

  factory Congee.fromJson(Map<String, dynamic> json) {
    final conge = json['conge'];
    final employe = conge['employe'];

    return Congee(
      typeConge: conge['typeConge'] ?? 'Unknown',
      dateDebut: conge['dateDebut'] ?? '',
      dateFin: conge['dateFin'] ?? '',
      employeeId: employe['_id'] ?? 'Unknown',
      employeeName: employe['name'] ?? 'Unknown',
    );
  }

  Congee copyWith({String? employeeName}) {
    return Congee(
      typeConge: this.typeConge,
      dateDebut: this.dateDebut,
      dateFin: this.dateFin,
      employeeId: this.employeeId,
      employeeName: employeeName ?? this.employeeName,
    );
  }
}
