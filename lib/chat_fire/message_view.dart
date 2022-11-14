import 'package:eshop/Model/message_model.dart';
import 'package:eshop/chat_fire/chat_fire_screen.dart';
import 'package:eshop/chat_fire/image_message.dart';
import 'package:eshop/chat_fire/text_message.dart';
import 'package:flutter/material.dart';


class MessageView extends StatelessWidget {
  final int index;
  final MessageModel message;
  //final Function(String, String) downloadDocument;
  final Function(MessageModel, bool) onLongPress;
  final Function(MessageModel) onTapPress;
  final List<MessageModel> selectedMessages;
  final bool forwardMode;
  final bool deleteMode;
  final String mobile;

  MessageView(
    this.index,
    this.message,
    //this.downloadDocument,
    this.selectedMessages,
    this.onTapPress,
    this.onLongPress,
    this.deleteMode,
    this.forwardMode,
      this.mobile
  );

  @override
  Widget build(BuildContext context) {
    final bool contains = selectedMessages
        .where((element) => element.id == message.id)
        .isNotEmpty;
    final bool sender = message.sender == mobile;
    return GestureDetector(
      onLongPress: forwardMode || deleteMode
          ? null
          : () {
              onLongPress.call(message, sender);
            },
      onTap: () {
        if (forwardMode) {
          onTapPress.call(message);
        } else if (deleteMode) {
          if (sender) {
            onTapPress.call(message);
          }
        }
      },
      child: Stack(
        alignment: sender ? Alignment.centerRight : Alignment.centerLeft,
        children: [
          message.type == "text"
              ? TextMessage(message, sender)
              : message.type == "photo"
                  ? ImageMessage(message, forwardMode || deleteMode, sender)
                  : Container()/*DocumentMessage(
                      message,
                      downloadDocument,
                      sender,
                      forwardMode || deleteMode,
                    )*/,
          contains
              ? Positioned.fill(
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    constraints: BoxConstraints(
                      minHeight: 30,
                    ),
                    margin: EdgeInsets.only(bottom: 10),
                    decoration: BoxDecoration(
                      borderRadius: sender
                          ? BorderRadius.only(
                              topRight: Radius.circular(12),
                              bottomRight: Radius.circular(12))
                          : BorderRadius.only(
                              topLeft: Radius.circular(12),
                              bottomLeft: Radius.circular(12)),
                      color: Colors.green.withOpacity(0.3),
                    ),
                  ),
                )
              : Container()
        ],
      ),
    );
  }
}
