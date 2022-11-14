import 'package:eshop/Model/room_model.dart';
import 'package:eshop/chat_fire/chat_fire_screen.dart';
import 'package:eshop/chat_fire/text_message.dart';
import 'package:flutter/material.dart';

class UserCard extends StatelessWidget {
  final RoomModel user;
  final Mmessage mmessage;
  final bool isAllow;

  //final Function(UserModel, String) onTap;
  final bool typing;
  final int newBadge;

  UserCard( {this.user ,this.typing = false, this.newBadge = 0,this.mmessage,this.isAllow});

  @override
  Widget build(BuildContext context) {

    return GestureDetector(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => ChatFireScreen(
                      isManager: true,
                      roomId:isAllow?mmessage.id :user.id,
                      fcmToken:isAllow?mmessage.fcmToken: user.fcmToken,
                      name:isAllow?(mmessage.name==null?mmessage.id:mmessage.name): (user.name == null ? user.id : user.name),
                    )));
        // onTap.call(user.userModel, user.id);
      },
      child: Card(
        margin: EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /* Container(
                height: 40,
                width: 40,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(60),
                  child: FadeInImage(
                    image: NetworkImage(user.userModel.profilePicture),
                    height: 40,
                    width: 40,
                    fit: BoxFit.cover,
                    placeholder: AssetImage(AssetsRes.profileImage),
                  ),
                ),
              ),*/
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                       isAllow?(mmessage.name==null?mmessage.id:mmessage.name): (user.name == null ? user.id : user.name),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      typing
                          ? Text(
                              "typing...",
                              style: TextStyle(
                                color: Colors.green,
                                fontSize: 14,
                              ),
                            )
                          : Text(
                             isAllow?"": user.lastMessage,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Colors.grey.withOpacity(0.5),
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ],
                  ),
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(isAllow?"": hFormat(user.lastMessageTime)),
                  newBadge == 0
                      ? Container()
                      : Container(
                          height: 20,
                          width: 20,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: Color(0xFF200738),
                            borderRadius: BorderRadius.circular(60),
                          ),
                          child: Text(
                            newBadge.toString(),
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
