import 'package:eshop/Model/message_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:intl/intl.dart';

import 'package:url_launcher/url_launcher.dart';

class TextMessage extends StatelessWidget {
  final MessageModel message;
  final bool sender;

  TextMessage(this.message, this.sender);

  @override
  Widget build(BuildContext context) {
    return message.mMessage != null && message.mMessage.mType == Type.reply
        ? Container(
            decoration: BoxDecoration(
              color: Colors.grey,
              borderRadius: BorderRadius.circular(8),
            ),
            margin: EdgeInsets.only(
              left: sender ? 10 : 0,
              right: sender ? 0 : 10,
              bottom: 10,
            ),
            child: Column(
              crossAxisAlignment:
                  sender ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: <Widget>[
    /*            Container(
                  width: 220,
                  constraints: BoxConstraints(
                    maxHeight: 200,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(8),
                      topLeft: Radius.circular(8),
                    ),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: ReplyMessage(message.mMessage),
                ),*/
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 10.0,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  width: 220,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Flexible(
                        child: Linkify(
                          onOpen: (link) async {
                            // ignore: deprecated_member_use
                            if (await canLaunch(link.url)) {
                              // ignore: deprecated_member_use
                              await launch(link.url);
                            }
                          },
                          text: message.content,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                          linkStyle: TextStyle(
                              color: Colors.blue,
                              decoration: TextDecoration.underline,
                              fontSize: 14),
                        ),
                      ),
                      SizedBox(width: 8.0),
                      Text(
                        hFormat(DateTime.fromMillisecondsSinceEpoch(
                            message.sendTime)),
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 12,
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width / 1.3,
            ),
          )
        : Container(
            padding: EdgeInsets.symmetric(
              horizontal: 10.0,
              vertical: 6,
            ),
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width / 1.3,
            ),
            decoration: BoxDecoration(
              color: Colors.grey,
              borderRadius: BorderRadius.circular(12),
            ),
            margin: EdgeInsets.only(
              left: sender ? 10 : 0,
              right: sender ? 0 : 10,
              bottom: 10,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                Flexible(
                  child: Linkify(
                    onOpen: (link) async {
                      // ignore: deprecated_member_use
                      if (await canLaunch(link.url)) {
                        // ignore: deprecated_member_use
                        await launch(link.url);
                      }
                    },
                    text: message.content,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                    linkStyle: TextStyle(
                        color: Colors.blue,
                        decoration: TextDecoration.underline,
                        fontSize: 14),
                  ),
                ),
                SizedBox(width: 8.0),
                Container(
                  child: Text(
                    hFormat(
                        DateTime.fromMillisecondsSinceEpoch(message.sendTime)),
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 12,
                    ),
                  ),
                  margin: EdgeInsets.only(left: 10.0),
                )
              ],
            ),
          );
  }
}
String hFormat(DateTime date) {
  if (DateTime.now().difference(date).inDays == 1) {
    return "yesterday";
  } else if (DateTime.now().difference(date).inDays > 364) {
    return DateFormat('dd-MM-yyyy').format(date);
  } else if (DateTime.now().difference(date).inDays > 1) {
    return DateFormat('dd-MM').format(date);
  } else {
    return DateFormat('hh:mm a').format(date);
  }
}