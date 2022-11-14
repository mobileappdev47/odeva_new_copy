import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eshop/Helper/Session.dart';
import 'package:eshop/Helper/String.dart';
import 'package:eshop/Home3.dart';
import 'package:eshop/Model/room_model.dart';
import 'package:eshop/chat_fire/chat_room_service.dart';
import 'package:eshop/chat_manager/user_card.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ChatManager extends StatefulWidget {
  const ChatManager({Key key}) : super(key: key);

  @override
  State<ChatManager> createState() => _ChatManagerState();
}

class _ChatManagerState extends State<ChatManager> {
  String mobileNo;
  @override
  void initState() {
    checkVersion(context);
    getMobile();
    super.initState();
  }
  @override
  void didChangeDependencies() {
    checkVersion(context);
    super.didChangeDependencies();
  }
  getMobile()async{
    mobileNo = await getPrefrence(MOBILE);
    setState(() {

    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: InkWell(
          onTap: () {
            Navigator.pop(context);
          },
          child: Icon(Icons.arrow_back,color: Colors.white,),
        ),
        backgroundColor: Color(0xFF200738),
        title: Text(
          "Chat List",
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: ChatRoomservice().streamRooms(),
        builder: (context, roomSnapshot) {
          if (roomSnapshot.hasData) {
            if (roomSnapshot.data.docs.isEmpty) {
              return Center(
                child: Text("No users found"),
              );
            } else {
              return Container(
                padding: EdgeInsets.only(top: 10),
                child: ListView.builder(
                    itemCount: roomSnapshot.data.docs.length,
                    itemBuilder: (BuildContext context, int index) {
                      Map map = roomSnapshot.data.docs[index].data() as Map;
                      if(map['lastMessage']==""){
                        Mmessage mmessage = Mmessage.fromMap(roomSnapshot.data.docs[index].data());
                       return UserCard(
                          mmessage: mmessage,
                          typing: false,
                          newBadge: map['${map['id']+"_newMessage"}'],
                          isAllow: true,
                        );

                      }else{
                        RoomModel roomModel = RoomModel.fromMap(
                            roomSnapshot.data.docs[index].data());
                        Map map = roomSnapshot.data.docs[index].data() as Map;
                      //  int messageCount = int.parse(map['${map['id']+"_newMessage"}'].toString());
                        print(map['${map['id']+"_newMessage"}']);
                        //var newMessageCount = roomSnapshot.data.docs[index].data()['name'].toString();
                        if (roomModel.isManager=="true") {
                          return SizedBox();
                        } else {
                          return Dismissible(
                            key: ValueKey<int>(index),
                            secondaryBackground: slideLeftBackground(),
                            background:Container(),
                            direction: DismissDirection.endToStart,
                            // ignore: missing_return
                            confirmDismiss: (direction)async{
                              if(direction == DismissDirection.endToStart){
                                showDialog(context: context, builder: (
                                    BuildContext context
                                    ){
                                  return AlertDialog(
                                    content: Text("Are you sure you want to delete?"),
                                    actions: <
                                        Widget>[
                                      FlatButton(
                                        onPressed:
                                            () {
                                          Navigator.pop(
                                              context);
                                        },
                                        child: Text(
                                            "No"),
                                      ),
                                      FlatButton(
                                        onPressed:
                                            () {
                                          ChatRoomservice().deletedoc(roomModel.id.toString());


                                          /*        ChatRoomService().deleteDoc(
                                          usrname,
                                          title,
                                          snapshot.data!.docs[index]['id']);*/
                                          Navigator.pop(
                                              context);
                                        },
                                        child: Text(
                                            "Yes"),
                                      ),
                                    ],
                                  );
                                }
                                );
                              }

                            },
                            child: UserCard(
                              user: roomModel,
                              typing: false,
                              newBadge: map['${map['id']+"_newMessage"}'],
                              isAllow: false,
                            ),
                          );
                        }
                      }


                    }),
              );
            }
          } else {
            return Center(
              child: Platform.isIOS
                  ? CupertinoActivityIndicator()
                  : CircularProgressIndicator(),
            );
          }
        },
      ),
    );
  }
  Widget slideLeftBackground() {
    return Container(
      color: Colors.red,
      child: Align(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            Icon(
              Icons.delete,
              color: Colors.white,
            ),
            Text(
              " Delete",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.right,
            ),
            SizedBox(
              width: 20,
            ),
          ],
        ),
        alignment: Alignment.centerRight,
      ),
    );
  }
}
