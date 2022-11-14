import 'package:eshop/Helper/String.dart';
import 'package:intl/intl.dart';

class NotificationModel {
  String id, title, desc, img, typeId, date;

  NotificationModel(
      {this.id, this.title, this.desc, this.img, this.typeId, this.date});

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    String date = json[DATE];

    date = DateFormat('dd-MM-yyyy').format(DateTime.parse(date));
    return new NotificationModel(
        id: json[ID],
        title: json[TITLE],
        desc: json[MESSAGE],
        img: json[IMAGE],
        typeId: json[TYPE_ID],
        date: date);
  }
}
