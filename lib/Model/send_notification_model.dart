class SendNotificationModel{
  String id;
  String roomId;
  String title;
  String body;
  String fcmToken;
  bool isGroup;
  List<String> fcmTokens;

  SendNotificationModel({
    this.roomId,
    this.title,
    this.body,
    this.id,
    this.fcmToken,
    this.fcmTokens,
    this.isGroup,
  });

  Map<String,dynamic> toMap() => {
    "${fcmToken == null ? "registration_ids": "to"}" : fcmToken == null ? fcmTokens : fcmToken,
    "data" : {
      "id": id,
      "roomId": roomId,
      "isGroup" : isGroup,
      "click_action": "FLUTTER_NOTIFICATION_CLICK",
      "sound": "default",
    },
    "priority" : "high",
    "notification" : {
      "title": title,
      "body" : body,
    }
  };
}