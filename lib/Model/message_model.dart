class MessageModel {
  String id;
  String content;
  String type;
  int sendTime;
  String sender;
  String senderName;
  bool isDownloading;
  String receiver;
  MMessage mMessage;

  MessageModel({
    this.id,
    this.content,
    this.type,
    this.sendTime,
    this.isDownloading = false,
    this.sender,
    this.receiver,
    this.mMessage,
    this.senderName,
  });

  factory MessageModel.fromMap(Map<String, dynamic> data, String id) =>
      MessageModel(
        content: data['content'],
        type: data['type'],
        id: id,
        sendTime: data['sendTime'],
        sender: data['sender'],
        receiver: data['receiver'],
        senderName: data['senderName'],
        mMessage: data["mMessage"] == null
            ? null
            : MMessage.fromMap(data["mMessage"]),
      );

  Map<String, dynamic> toMap() => {
        "content": content,
        "type": type,
        "sendTime": sendTime,
        "sender": sender,
        "senderName": senderName,
        "receiver": receiver,
        "mMessage": mMessage?.toMap(),
      };
}

class MMessage {
  Type mType;
  String mContent;
  String mDataType;
  String mSender;

  MMessage({
    this.mType,
    this.mContent,
    this.mDataType,
    this.mSender,
  });

  factory MMessage.fromMap(Map<String, dynamic> data) => MMessage(
        mContent: data['mContent'],
        mSender: data['mSender'],
        mDataType: data['mDataType'],
        mType: mTypeValues.map[data["mType"]],
      );

  Map<String, dynamic> toMap() => {
        "mContent": mContent,
        "mDataType": mDataType,
        "mSender": mSender,
        "mType": mTypeValues.reverse[mType],
      };
}

enum Type { forward, reply }

final mTypeValues = EnumValues({
  "forward": Type.forward,
  "reply": Type.reply,
});

class EnumValues<T> {
  Map<String, T> map;
  Map<T, String> reverseMap;

  EnumValues(this.map);

  Map<T, String> get reverse {
    if (reverseMap == null) {
      reverseMap = map.map((k, v) => new MapEntry(v, k));
    }
    return reverseMap;
  }
}
