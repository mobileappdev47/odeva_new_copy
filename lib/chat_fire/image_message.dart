import 'package:eshop/Model/message_model.dart';
import 'package:eshop/chat_fire/text_message.dart';
import 'package:flutter/material.dart';

import 'package:cached_network_image/cached_network_image.dart';

class ImageMessage extends StatelessWidget {
  final MessageModel message;
  final bool selectionMode;
  final bool sender;

  ImageMessage(this.message, this.selectionMode, this.sender);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Stack(
        children: <Widget>[
          InkWell(
            child: ClipRRect(
              borderRadius: BorderRadius.all(Radius.circular(8.0)),
              child: CachedNetworkImage(
                imageUrl: message.content,
                width: 200.0,
                height: 200.0,
                fit: BoxFit.cover,
                progressIndicatorBuilder: (context, url, downloadProgress) {
                  return Padding(
                    padding: EdgeInsets.all(80),
                    child: CircularProgressIndicator(
                        value: downloadProgress.progress),
                  );
                },
                errorWidget: (context, url, error) => Icon(Icons.error),
              ),
            ),
            onTap: selectionMode
                ? null
                : () async {
                 /*   await Get.dialog(
                      Dialog(
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            CachedNetworkImage(
                              imageUrl: message.content,
                              progressIndicatorBuilder:
                                  (context, url, downloadProgress) =>
                                      CircularProgressIndicator(
                                          value: downloadProgress.progress),
                              errorWidget: (context, url, error) =>
                                  Icon(Icons.error),
                            ),
                          ],
                        ),
                      ),
                    );*/
                  },
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: Container(
              child: Text(
                hFormat(DateTime.fromMillisecondsSinceEpoch(message.sendTime)),
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 12,
                ),
              ),
              margin: EdgeInsets.only(right: 10, bottom: 5),
            ),
          )
        ],
      ),
      margin: EdgeInsets.only(
        left: sender ? 10 : 0,
        right: sender ? 0 : 10,
        bottom: 10,
      ),
      height: 200,
      width: 200,
    );
  }
}
