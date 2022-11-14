import 'dart:convert';

import 'package:eshop/Helper/String.dart';
import 'package:eshop/Model/User.dart';

class SectionModel {
  String id,
      title,
      varientId,
      qty,
      productId,
      perItemTotal,
      perItemPrice,
      style;
  List<Product> productList;
  List<Filter> filterList;
  List<String> selectedId = [];
  int offset, totalItem;

  SectionModel(
      {this.id,
      this.title,
      this.productList,
      this.varientId,
      this.qty,
      this.productId,
      this.perItemTotal,
      this.perItemPrice,
      this.style,
      this.totalItem,
      this.offset,
      this.selectedId,
      this.filterList});

  factory SectionModel.fromJson(Map<String, dynamic> parsedJson) {
    List<Product> productList = (parsedJson[PRODUCT_DETAIL] as List)
        .map((data) => new Product.fromJson(data))
        .toList();

    var flist = (parsedJson[FILTERS] as List);
    List<Filter> filterList = [];
    if (flist == null || flist.isEmpty)
      filterList = [];
    else
      filterList = flist.map((data) => new Filter.fromJson(data)).toList();
    List<String> selected = [];
    return SectionModel(
        id: parsedJson[ID],
        title: parsedJson[TITLE],
        style: parsedJson[STYLE],
        productList: productList,
        offset: 0,
        totalItem: 0,
        filterList: filterList,
        selectedId: selected);
  }

  factory SectionModel.fromCart(Map<String, dynamic> parsedJson) {
    List<Product> productList = (parsedJson[PRODUCT_DETAIL] as List)
        .map((data) => new Product.fromJson(data))
        .toList();

    return SectionModel(
        id: parsedJson[ID],
        varientId: parsedJson[PRODUCT_VARIENT_ID],
        qty: parsedJson[QTY],
        perItemTotal: "0",
        perItemPrice: "0",
        productList: productList);
  }

  factory SectionModel.fromFav(Map<String, dynamic> parsedJson) {
    List<Product> productList = (parsedJson[PRODUCT_DETAIL] as List)
        .map((data) => new Product.fromJson(data))
        .toList();

    return SectionModel(
        id: parsedJson[ID],
        productId: parsedJson[PRODUCT_ID],
        productList: productList);
  }
}

class Product {
  String id,
      name,
      desc,
      image,
      catName,
      type,
      rating,
      noOfRating,
      attrIds,
      tax,
      categoryId,
      shortDescription,
      qtyStepSize,openStoreTime,
      closeStoreTime
  ;
  List<String> itemsCounter;
  List<String> otherImage;
  List<Product_Varient> prVarientList;
  List<Attribute> attributeList;
  List<String> selectedId = [];
  List<String> tagList = [];
  int minOrderQuntity;
  String isFav,
      isReturnable,
      isCancelable,
      isPurchased,
      availability,
      madein,
      indicator,
      stockType,
      cancleTill,
      total,
      banner,
      totalAllow,
      video,
      videType,
      warranty,
      gurantee;

  String totalImg;
  List<ReviewImg> reviewList;

  bool isFavLoading = false, isFromProd = false;
  int offset, totalItem, selVarient;

  List<Product> subList;
  List<Filter> filterList;

  Product(
      {this.id,
      this.name,
      this.desc,
      this.image,
      this.catName,
      this.type,
      this.otherImage,
      this.prVarientList,
      this.attributeList,
      this.isFav,
      this.isCancelable,
      this.isReturnable,
      this.isPurchased,
      this.availability,
      this.noOfRating,
      this.attrIds,
      this.selectedId,
      this.rating,
      this.isFavLoading,
      this.indicator,
      this.madein,
      this.tax,
      this.shortDescription,
      this.total,
      this.categoryId,
      this.subList,
      this.filterList,
      this.stockType,
      this.isFromProd,
      this.cancleTill,
      this.totalItem,
      this.offset,
      this.totalAllow,
      this.banner,
      this.selVarient,
      this.video,
      this.videType,
      this.tagList,
      this.warranty,
      this.qtyStepSize,
        this.openStoreTime,
        this.closeStoreTime,
      this.minOrderQuntity,
      this.itemsCounter,
      this.reviewList,
      this.gurantee,
     });

  factory Product.fromJson(Map<String, dynamic> json) {
    List<Product_Varient> varientList = (json[PRODUCT_VARIENT] as List)
        .map((data) => new Product_Varient.fromJson(data))
        .toList();

    List<Attribute> attList = (json[ATTRIBUTES] as List)
        .map((data) => new Attribute.fromJson(data))
        .toList();

    var flist = (json[FILTERS] as List);
    List<Filter> filterList = [];
    if (flist == null || flist.isEmpty)
      filterList = [];
    else
      filterList = flist.map((data) => new Filter.fromJson(data)).toList();

    List<String> other_image = List<String>.from(json[OTHER_IMAGE]);
    List<String> selected = [];

    List<String> tags = List<String>.from(json[TAG]);

    List<String> items = new List<String>.generate(
        json[TOTALALOOW] != null ? int.parse(json[TOTALALOOW]) : 10, (i) {
      return ((i + 1) * int.parse(json[QTYSTEP])).toString();
    });

    var reviewImg = (json[REV_IMG] as List);
    List<ReviewImg> reviewList = [];
    if (reviewImg == null || reviewImg.isEmpty)
      reviewList = [];
    else
      reviewList =
          reviewImg.map((data) => new ReviewImg.fromJson(data)).toList();

    return new Product(
        id: json[ID],
        name: json[NAME],
        desc: json[DESC],
        image: json[IMAGE],
        catName: json[CAT_NAME],
        rating: json[RATING],
        noOfRating: json[NO_OF_RATE],
        type: json[TYPE],
        isFav: json[FAV].toString(),
        isCancelable: json[ISCANCLEABLE],
        availability: json[AVAILABILITY].toString(),
        isPurchased: json[ISPURCHASED].toString(),
        isReturnable: json[ISRETURNABLE],
        otherImage: other_image,
        prVarientList: varientList,
        attributeList: attList,
        filterList: filterList,
        isFavLoading: false,
        selVarient: 0,
        attrIds: json[ATTR_VALUE],
        madein: json[MADEIN],
        shortDescription: json[SHORT],
        indicator: json[INDICATOR].toString(),
        stockType: json[STOCKTYPE].toString(),
        tax: json[TAX_PER],
        total: json[TOTAL],
        categoryId: json[CATID],
        selectedId: selected,
        totalAllow: json[TOTALALOOW],
        cancleTill: json[CANCLE_TILL],
        video: json[VIDEO],
        videType: json[VIDEO_TYPE],
        tagList: tags,
        itemsCounter: items,
        warranty: json[WARRANTY],
        minOrderQuntity: int.parse(json[MINORDERQTY]),
        qtyStepSize: json[QTYSTEP],
        gurantee: json[GAURANTEE],
        openStoreTime: json[OPEN_STORE_TIME],
        closeStoreTime: json[CLOSE_STORE_TIME],
        reviewList: reviewList
        // totalImg: tImg,
        // totalReviewImg: json[REV_IMG][TOTALIMGREVIEW],
        // productRating: reviewList
        );
  }

  factory Product.fromCat(Map<String, dynamic> parsedJson) {
    print("Childs : " + parsedJson["children"].toString());
    return new Product(
      id: parsedJson[ID],
      name: parsedJson[NAME],
      image: parsedJson[IMAGE],
      banner: parsedJson[BANNER],
      isFromProd: false,
      offset: 0,
      totalItem: 0,
      tax: parsedJson[TAX],
      subList: createSubList(parsedJson["children"],
      ),
    );
  }

  static List<Product> createSubList(List parsedJson) {
    if (parsedJson == null || parsedJson.isEmpty) return null;

    return parsedJson.map((data) => new Product.fromCat(data)).toList();
  }
}

class Product_Varient {
  String id,
      productId,
      attribute_value_ids,
      price,
      disPrice,
      type,
      attr_name,
      varient_value,
      availability,
      cartCount;
  List<String> images;

  Product_Varient(
      {this.id,
      this.productId,
      this.attr_name,
      this.varient_value,
      this.price,
      this.disPrice,
      this.attribute_value_ids,
      this.availability,
      this.cartCount,
      this.images});

  String name() {
    var a1 = [];
    if (this.attr_name.toString().isNotEmpty || attr_name != null) {
      //print(attr_name + "is not null");
      a1 = this.attr_name.toString().split(",");
    }
    var a2 = [];
    if (this.varient_value.toString().isNotEmpty || varient_value != null) {
      //print(varient_value + "is not null");
      a2 = this.varient_value.toString().split(",");
    }
    var r = [];
    a1.asMap().forEach((index, value) => {
          if (value != null && a2[index] != null)
            {
              //print("varient value is not null"),
              r.add(value.toUpperCase() + " : " + a2[index].toUpperCase())
            }
          else
            {
              //print("varient value is null "),
              r.add("")
            }
        });
    return r.join(" ");
  }

  factory Product_Varient.fromJson(Map<String, dynamic> json) {
    List<String> images = List<String>.from(json[IMAGES]);

    return new Product_Varient(
        id: json[ID],
        attribute_value_ids: json[ATTRIBUTE_VALUE_ID],
        productId: json[PRODUCT_ID],
        attr_name: json[ATTR_NAME],
        varient_value: json[VARIENT_VALUE],
        disPrice: json[DIS_PRICE],
        price: json[PRICE],
        availability: json[AVAILABILITY].toString(),
        cartCount: json[CART_COUNT],
        images: images);
  }
}

class Attribute {
  String id, value, name;

  Attribute({this.id, this.value, this.name});

  factory Attribute.fromJson(Map<String, dynamic> json) {
    return new Attribute(
      id: json[IDS],
      name: json[NAME],
      value: json[VALUE],
    );
  }
}

class Filter {
  String attributeValues, attributeValId, name;

  Filter({this.attributeValues, this.attributeValId, this.name});

  factory Filter.fromJson(Map<String, dynamic> json) {
    return new Filter(
      attributeValId: json[ATT_VAL_ID],
      name: json[NAME],
      attributeValues: json[ATT_VAL],
    );
  }
}

class ReviewImg {
  String totalImg;
  List<User> productRating;

  ReviewImg({this.totalImg, this.productRating});

  factory ReviewImg.fromJson(Map<String, dynamic> json) {
    var reviewImg = (json[PRODUCTRATING] as List);
    List<User> reviewList = [];
    if (reviewImg == null || reviewImg.isEmpty)
      reviewList = [];
    else
      reviewList = reviewImg.map((data) => new User.forReview(data)).toList();

    return new ReviewImg(totalImg: json[TOTALIMG], productRating: reviewList);
  }
}
