class RoomModel {
  String id;
  String lastMessage;
  String name;
  String isManager;
  String fcmToken;

  DateTime lastMessageTime;

  RoomModel(
      {this.id,
      this.lastMessage,
      this.lastMessageTime,
      this.name,
      this.isManager,
      this.fcmToken});

  factory RoomModel.fromMap(Map<String, dynamic> data) => RoomModel(
      id: data['id'],
      lastMessageTime: data['lastMessageTime'].toDate(),
      lastMessage: data['lastMessage'],
      name: data['name'],
      isManager: data['isManager'],
      fcmToken: data['fcmToken']);
}

class Mmessage {
  String id;
  String name;
  String fcmToken;

  Mmessage({this.id, this.fcmToken, this.name});

  factory Mmessage.fromMap(Map<String, dynamic> data) =>
      Mmessage(id: data['id'], name: data['name'], fcmToken: data['fcmToken']);
}
