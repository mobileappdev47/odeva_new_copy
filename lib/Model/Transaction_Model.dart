import 'package:eshop/Helper/String.dart';
import 'package:intl/intl.dart';

class TransactionModel {
  String id, amt, status, msg, date, type, txnID, orderId, orderNo;

  TransactionModel(
      {this.id,
      this.amt,
      this.status,
      this.msg,
      this.date,
      this.type,
      this.txnID,
      this.orderId,
      this.orderNo});

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    String date = json[TRN_DATE];

    date = DateFormat('dd-MM-yyyy HH:mm:ss').format(DateTime.parse(date));
    return new TransactionModel(
        orderId: json[ORDER_ID],
        amt: json[AMOUNT],
        status: json[STATUS],
        msg: json[MESSAGE],
        type: json[TYPE],
        txnID: json[TXNID],
        id: json[ID],
        date: date,
        orderNo: json["order_number"]==null?"":json["order_number"]);
  }

  factory TransactionModel.fromReqJson(Map<String, dynamic> json) {
    String date = json[DATE];

    date = DateFormat('dd-MM-yyyy').format(DateTime.parse(date));
    String st = json[STATUS];
    /*if (st == "0") {
      st = PENDING;
    } else if (st == "1") {
      st = ACCEPTED;
    } else if (st == "2") {
      st = REJECTED;
    }*/

    return new TransactionModel(
        id: json[ID],
        amt: json["amount_requested"],
        status: st,
        msg: json[MSG],
        date: date,
        orderNo:  json["order_number"]==null?"":json["order_number"]);
  }
}
