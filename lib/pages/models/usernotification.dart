class UserNotification {
  final String id;
  final String nameNotif;
  final DateTime dateNotif;
  final String contenuNotif;
  final String? photo;

  UserNotification({
    required this.id,
    required this.nameNotif,
    required this.dateNotif,
    required this.contenuNotif,
    this.photo,
  });

  factory UserNotification.fromJson(Map<String, dynamic> json) {
    return UserNotification(
      id: json['_id'],
      nameNotif: json['nameNotif'],
      dateNotif: DateTime.parse(json['dateNotif']),
      contenuNotif: json['contenuNotif'],
      photo: json['photo'],
    );
  }
}
