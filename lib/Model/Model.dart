import '../Helper/String.dart';
import 'Section_Model.dart';

class Model {
  String id, type, typeId, image, fromTime, lastTime;
  var list;
  String name, banner;

  Model(
      {this.id,
      this.type,
      this.typeId,
      this.image,
      this.name,
      this.banner,
      this.list,
      this.fromTime,
      this.lastTime});

  factory Model.fromSlider(Map<String, dynamic> parsedJson) {
    var listContent = parsedJson["data"];
    if (listContent == null || listContent.isEmpty)
      listContent = [];
    else {
      listContent = listContent[0];
      if (parsedJson[TYPE] == "categories")
        listContent = new Product.fromCat(listContent);
      else if (parsedJson[TYPE] == "products")
        listContent = new Product.fromJson(listContent);
    }

    return new Model(
        id: parsedJson[ID],
        image: parsedJson[IMAGE],
        type: parsedJson[TYPE],
        typeId: parsedJson[TYPE_ID],
        list: listContent);
  }

  factory Model.fromTimeSlot(Map<String, dynamic> parsedJson) {
    return new Model(
        id: parsedJson[ID],
        name: parsedJson[TITLE],
        fromTime: parsedJson[FROMTIME],
        lastTime: parsedJson[TOTIME]);
  }

  factory Model.setAllCat(String id, String name) {
    return new Model(
      id: id,
      name: name,
    );
  }
}
