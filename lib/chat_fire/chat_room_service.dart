import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eshop/Model/message_model.dart';
import 'package:eshop/chat_fire/chat_fire_screen.dart';

class ChatRoomservice {
  CollectionReference chatRoom =
      FirebaseFirestore.instance.collection("chatroom");

  Future<DocumentSnapshot> isRoomAvailable(String roomId) async {
    return await chatRoom.doc(roomId).get();
  }

  Future<void> createChatRoom(Map<String, dynamic> data) async {
    try {
      await chatRoom.doc(data['id']).set(data);
    } catch (e) {
      print(e);
      //handleException(e);
      throw e;
    }
  }

  Future<DocumentSnapshot> getParticularRoom(String id) {
    try {
      return chatRoom.doc(id).get();
    } catch (e) {
      print(e);
      //handleException(e);
      throw e;
    }
  }

  Future<void> sendMessage(MessageModel message, String roomId) async {
    await chatRoom.doc(roomId).collection(roomId).add(message.toMap());
  }

  Query getMessages(
    String chatId,
    int limit,
  ) {
    return chatRoom
        .doc(roomId)
        .collection(roomId)
        .orderBy('sendTime', descending: true);
  }

  Stream<QuerySnapshot> streamRooms() {
    try {
      return chatRoom
          .orderBy("lastMessageTime", descending: true)
          .snapshots();
    } catch (e) {
      print(e);
      //   handleException(e);
      throw e;
    }
  }

  Stream<DocumentSnapshot> streamParticularRoom(String id) {
    try {
      return chatRoom.doc(id).snapshots();
    } catch (e) {
      print(e);
      // handleException(e);
      throw e;
    }
  }

  Future<void> updateLastMessage(
      Map<String, dynamic> data, String roomId) async {
    await chatRoom.doc(roomId).get().then((value) {
      if (value.exists) {
        value.reference.update(data);
      }
    });
  }

  Future<void> deletedoc(String roomId) async {
    await FirebaseFirestore.instance
        .collection("chatroom")
        .doc(roomId.toString())
        .collection(roomId.toString())
        .get()
        .then((value) => {
              value.docs.forEach((element) {
                element.reference.delete();
              })
            });
    await FirebaseFirestore.instance.collection('chatroom')
        .doc(roomId)
        .update({'lastMessage': "", 'lastMessageTime': ""});
  }
}
