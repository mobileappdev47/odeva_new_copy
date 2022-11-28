import 'package:eshop/Helper/Color.dart';
import 'package:eshop/Model/message_model.dart';
import 'package:flutter/material.dart';

class InputBottomBar extends StatelessWidget {
  InputBottomBar(
      {this.message,
      this.msgController,
      this.isTyping,
      this.clearReply,
      this.onAttachment,
      this.onCameraTap,
        this.onSend,
        this.onTextFieldChange,
        this.focusNode
      });

  final MMessage message;
  final TextEditingController msgController;
  final bool isTyping;
  final Function clearReply;
  final VoidCallback onAttachment;
  final VoidCallback onCameraTap;
  final Function(MMessage) onSend;
  final VoidCallback onTextFieldChange;
  final FocusNode focusNode;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: message == null
            ? Container(
                padding: EdgeInsets.only(left: 5),
                margin: EdgeInsets.only(left: 5, bottom: 5, right: 5),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        margin: EdgeInsets.only(right: 5),
                        padding: EdgeInsets.only(left: 5),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color:  colors.darkColor,
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                                child: TextField(
                                    style: TextStyle(color: Colors.white),
                                    maxLines: 5,
                                    textCapitalization:
                                        TextCapitalization.sentences,
                                    minLines: 1,
                                    controller: msgController,
                                    keyboardType: TextInputType.multiline,
                                    decoration: InputDecoration(
                                      border: InputBorder.none,
                                      hintText: "Type Message",
                                      counterText: '',
                                      hintStyle: TextStyle(
                                        fontSize: 15,
                                        color: Colors.white,
                                      ),
                                      contentPadding:
                                          EdgeInsets.only(left: 10, bottom: 5),
                                    ))),
            /*                isTyping
                                ? Container()
                                : Container(
                              padding: EdgeInsets.only(left: 13, right: 5),
                              child: RotationTransition(
                                turns: AlwaysStoppedAnimation(135 / 360),
                                child: InkWell(
                                  onTap: () {
                                 //   onAttachment.call();
                                  },
                                  child: Icon(
                                    Icons.attachment,
                                    size: 28,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                            isTyping
                                ? Container()
                                : Container(
                              padding: EdgeInsets.only(left: 5, right: 11),
                              child: InkWell(
                              //  onTap: onCameraTap,
                                child: Icon(
                                  Icons.camera_alt,
                                  color: Colors.white,
                                ),
                              ),
                            ),*/
                            GestureDetector(
                              onTap: () {
                                onSend.call(message);
                              },
                              child: Container(
                                height: 50,
                                padding: EdgeInsets.only(left: 13, right: 11),
                                decoration: BoxDecoration(
                                  color: Color(0xFF200738),
                                  borderRadius: BorderRadius.circular(50),
                                ),
                                child: Icon(
                                  Icons.send,
                                  color: Colors.white,
                                ),
                              ),
                            ),

                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              )
            : Container(
                padding: EdgeInsets.only(
                  left: 5,
                ),
                margin: EdgeInsets.only(left: 5, bottom: 5, right: 5),
                child: Column(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: message.mDataType == "photo" ? 7 : 16,
                          vertical: 6),
                      margin: EdgeInsets.only(bottom: 5),
                      decoration: BoxDecoration(
                          border: Border.all(
                            color: Color(0xFF200738),
                          ),
                          borderRadius: BorderRadius.circular(25),
                          color: Color(0xFF200738).withOpacity(0.1)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          //ReplyMessage(message),
                          InkWell(
                            onTap: () {
                              clearReply.call();
                            },
                            child: Icon(
                              Icons.close_rounded,
                              color: Color(0xFF200738),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        Container(
                          margin: EdgeInsets.only(right: 5),
                          padding: EdgeInsets.only(left: 5),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: Color(0xFF200738),
                            borderRadius: BorderRadius.circular(25),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              TextField(
                                style: TextStyle(color: Colors.white),
                                maxLines: 5,
                                focusNode: focusNode,
                                textCapitalization:
                                    TextCapitalization.sentences,
                                minLines: 1,
                                onChanged: (_) {
                                     onTextFieldChange();
                                },
                                controller: msgController,
                                keyboardType: TextInputType.multiline,
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  hintText: "Type message",
                                  counterText: '',
                                  hintStyle: TextStyle(
                                    fontSize: 15,
                                    color: Colors.white,
                                  ),
                                  contentPadding:
                                      EdgeInsets.only(left: 10, bottom: 5),
                                ),
                              ),
                      /*        isTyping
                                  ? Container()
                                  : Container(
                                      padding:
                                          EdgeInsets.only(left: 13, right: 5),
                                      child: RotationTransition(
                                        turns:
                                            AlwaysStoppedAnimation(135 / 360),
                                        child: InkWell(
                                          onTap: () {
                                            if (message != null)
                                              clearReply.call();
                                            else
                                              onAttachment.call();
                                          },
                                          child: Icon(
                                            Icons.attachment,
                                            size: 28,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                              isTyping
                                  ? Container()
                                  : Container(
                                      padding:
                                          EdgeInsets.only(left: 5, right: 11),
                                      child: InkWell(
                                        onTap: () {
                                          if (message != null)
                                            clearReply.call();
                                          else
                                            onCameraTap.call();
                                        },
                                        child: Icon(
                                          Icons.camera_alt,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),*/
                            ],
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            if (msgController.text.trim().isNotEmpty) {
                              clearReply.call();
                              onSend.call(message);
                            }
                          },
                          child: Container(
                            height: 50,
                            padding: EdgeInsets.only(left: 13, right: 11),
                            decoration: BoxDecoration(
                              color: Color(0xFF200738),
                              borderRadius: BorderRadius.circular(50),
                            ),
                            child: Icon(
                              Icons.send,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ));
  }
}
