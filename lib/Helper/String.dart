import 'package:eshop/Helper/Constant.dart';
import 'package:eshop/Model/Section_Model.dart';

final Uri getSliderApi = Uri.parse(baseUrl + 'get_slider_images');
final Uri getCatApi = Uri.parse(baseUrl + 'get_categories');
final Uri getSectionApi = Uri.parse(baseUrl + 'get_sections');
final Uri getSettingApi = Uri.parse(baseUrl + 'get_settings');
final Uri getSubcatApi =
    Uri.parse(baseUrl + 'get_subcategories_by_category_id');
final Uri getProductApi = Uri.parse(baseUrl + 'get_products');
final Uri manageCartApi = Uri.parse(baseUrl + 'manage_cart');
final Uri getUserLoginApi = Uri.parse(baseUrl + 'login');
final Uri getUserSignUpApi = Uri.parse(baseUrl + 'register_user');
final Uri getVerifyUserApi = Uri.parse(baseUrl + 'verify_user');
final Uri setFavoriteApi = Uri.parse(baseUrl + 'add_to_favorites');
final Uri removeFavApi = Uri.parse(baseUrl + 'remove_from_favorites');
final Uri getRatingApi = Uri.parse(baseUrl + 'get_product_rating');
final Uri getReviewImgApi= Uri.parse(baseUrl+ 'get_product_review_images');
final Uri getCartApi = Uri.parse(baseUrl + 'get_user_cart');
final Uri getFavApi = Uri.parse(baseUrl + 'get_favorites');
final Uri setRatingApi = Uri.parse(baseUrl + 'set_product_rating');
final Uri getNotificationApi = Uri.parse(baseUrl + 'get_notifications');
final Uri checkLocationApi = Uri.parse(baseUrl + 'check_location');
final Uri getAddressApi = Uri.parse(baseUrl + 'get_address');
final Uri deleteAddressApi = Uri.parse(baseUrl + "delete_address");
final Uri getResetPassApi = Uri.parse(baseUrl + 'reset_password');
final Uri getCitiesApi = Uri.parse(baseUrl + 'get_cities');
final Uri getAreaByCityApi = Uri.parse(baseUrl + 'get_areas_by_city_id');
final Uri getUpdateUserApi = Uri.parse(baseUrl + 'update_user');
final Uri getAddAddressApi = Uri.parse(baseUrl + 'add_address');
final Uri updateAddressApi = Uri.parse(baseUrl + 'update_address');
final Uri placeOrderApi = Uri.parse(baseUrl + 'place_order');
final Uri validatePromoApi = Uri.parse(baseUrl + 'validate_promo_code');
final Uri getOrderApi = Uri.parse(baseUrl + 'get_orders');
final Uri updateOrderApi = Uri.parse(baseUrl + 'update_order_status');
final Uri updateOrderItemApi = Uri.parse(baseUrl + 'update_order_item_status');
final Uri paypalTransactionApi = Uri.parse(baseUrl + 'get_paypal_link');
final Uri addTransactionApi = Uri.parse(baseUrl + 'add_transaction');
final Uri getJwtKeyApi = Uri.parse(baseUrl + 'get_jwt_key');
final Uri getOfferImageApi = Uri.parse(baseUrl + 'get_offer_images');
final Uri getFaqsApi = Uri.parse(baseUrl + 'get_faqs');
final Uri updateFcmApi = Uri.parse(baseUrl + 'update_fcm');
final Uri getWalTranApi = Uri.parse(baseUrl + 'transactions');
final Uri getPytmChecsumkApi = Uri.parse(baseUrl + 'generate_paytm_txn_token');
final Uri deleteOrderApi = Uri.parse(baseUrl + 'delete_order');

final Uri validateReferalApi = Uri.parse(baseUrl + 'validate_refer_code');
final Uri flutterwaveApi = Uri.parse(baseUrl + 'flutterwave_webview');

final Uri deleteAccount = Uri.parse(baseUrl + "delete_account");

final String ISFIRSTTIME = 'isfirst$appName';

const String ID = 'id';
const String TYPE = 'type';
const String TYPE_ID = 'type_id';
const String IMAGE = 'image';
const String IMGS = 'images[]';
const String NAME = 'name';
const String DEFAULT_ORDER = 'default_order';
const String MINIMUM_ORDER_QUANTITY = 'minimum_order_quantity';
const String SUBTITLE = 'subtitle';
const String TAX = 'tax';
const String SLUG = 'slug';
const String TITLE = 'title';
const String PRODUCT_DETAIL = 'product_details';
const String DESC = 'description';
const String CATID = 'category_id';
const String CAT_NAME = 'category_name';
const String OTHER_IMAGE = 'other_images_md';
const String PRODUCT_VARIENT = 'variants';
const String PRODUCT_ID = 'product_id';
const String PRICE = 'price';
const String MEASUREMENT = 'measurement';
const String MEAS_UNIT_ID = 'measurement_unit_id';
const String SERVE_FOR = 'serve_for';
const String SHORT_CODE = 'short_code';
const String STOCK = 'stock';
const String STOCK_UNIT_ID = 'stock_unit_id';
const String DIS_PRICE = 'special_price';
const String CURRENCY = 'currency';
const String SUB_ID = 'subcategory_id';
const String SORT = 'sort';
const String PSORT = 'p_sort';
const String ORDER = 'order';
const String PORDER = 'p_order';
const String DEL_CHARGES = 'delivery_charges';
const String FREE_AMT = 'minimum_free_delivery_order_amount';
final String ISFROMBACK = "isfrombackground$appName";




const String LIMIT = 'limit';
const String OFFSET = 'offset';
const String PRIVACY_POLLICY = 'privacy_policy';
const String TERM_COND = 'terms_conditions';
const String CONTACT_US = 'contact_us';
const String ABOUT_US = 'about_us';
const String BANNER = 'banner';
const String CAT_FILTER = 'has_child_or_item';
const String PRODUCT_FILTER = 'has_empty_products';
const String RATING = 'rating';
const String IDS = 'ids';
const String VALUE = 'value';
const String ATTRIBUTES = 'attributes';
const String ATTRIBUTE_VALUE_ID = 'attribute_value_ids';
const String IMAGES = 'images';
const String NO_OF_RATE = 'no_of_ratings';
const String ATTR_NAME = 'attr_name';
const String VARIENT_VALUE = 'variant_values';
const String COMMENT = 'comment';
const String MESSAGE = 'message';
const String DATE = 'date_sent';
const String TRN_DATE = 'transaction_date';
const String SEARCH = 'search';
const String PAYMENT_METHOD = 'payment_method';
const String ISWALLETBALUSED = "is_wallet_used";
const String WALLET_BAL_USED = 'wallet_balance_used';
const String NOTE = 'note';
const String USERDATA = 'user_data';
const String DATE_ADDED = 'date_added';
const String ORDER_ITEMS = 'order_items';
const String TOP_RETAED = 'top_rated_product';
const String WALLET = 'wallet';
const String CREDIT = 'credit';
const String REV_IMG='review_images';



const String USER_NAME = 'user_name';
const String USERNAME = 'username';
const String ADDRESS = 'address';
const String EMAIL = 'email';
const String MOBILE = 'mobile';
const String CITY = 'city';
const String DOB = 'dob';
const String AREA = 'area';
const String PASSWORD = 'password';
const String STREET = 'street';
const String PINCODE = 'pincode';
const String FCM_ID = 'fcm_id';
const String LATITUDE = 'latitude';
const String LONGITUDE = 'longitude';
const String USER_ID = 'user_id';
const String FAV = 'is_favorite';
const String ISRETURNABLE = 'is_returnable';
const String ISCANCLEABLE = 'is_cancelable';
const String ISPURCHASED = 'is_purchased';
const String ISOUTOFSTOCK = 'out_of_stock';
const String PRODUCT_VARIENT_ID = 'product_variant_id';
const String GRAM = "gram";
const String QTY = 'qty';
const String CART_COUNT = 'cart_count';
const String DEL_CHARGE = 'delivery_charge';
const String SUB_TOTAL = 'sub_total';
const String TAX_AMT = 'tax_amount';
const String TAX_PER = 'tax_percentage';
const String CANCLE_TILL = 'cancelable_till';
const String ALT_MOBNO = 'alternate_mobile';
const String STATE = 'state';
const String COUNTRY = 'country';
const String ISDEFAULT = 'is_default';
const String LANDMARK = 'landmark';
const String CITY_ID = 'city_id';
const String AREA_ID = 'area_id';
const String HOME = 'Home';
const String OFFICE = 'Office';
const String OTHER = 'Other';
const String FINAL_TOTAL = 'final_total';
const String PROMOCODE = 'promo_code';
const String NEWPASS = 'new';
const String OLDPASS = 'old';
const String MOBILENO = 'mobile_no';
const String DELIVERY_TIME = 'delivery_time';
const String DELIVERY_DATE = 'delivery_date';
const String QUANTITY = "quantity";
const String PROMO_DIS = 'promo_discount';
const String WAL_BAL = 'wallet_balance';
const String TOTAL = 'total';
const String TOTAL_PAYABLE = 'total_payable';
const String STATUS = 'status';
const String TOTAL_TAX_PER = 'total_tax_percent';
const String TOTAL_TAX_AMT = 'total_tax_amount';
const String PRODUCT_LIMIT = "p_limit";
const String PRODUCT_OFFSET = "p_offset";
const String SEC_ID = 'section_id';
const String COUNTRY_CODE = 'country_code';
const String ATTR_VALUE = 'attr_value_ids';
const String MSG = 'message';
const String ORDER_ID = 'order_id';
const String IS_SIMILAR = 'is_similar_products';
const String PLACED = 'received';
const String SHIPED = 'shipped';
const String PROCESSED = 'processed';
const String DELIVERD = 'delivered';
const String CANCLED = 'cancelled';
const String RETURNED = 'returned';
const String ITEM_RETURN = 'Item Return';
const String ITEM_CANCEL = 'Item Cancel';
const String ADD_ID = 'address_id';
const String STYLE = 'style';
const String SHORT_DESC = 'short_description';
const String DEFAULT = 'default';
const String STYLE1 = 'style_1';
const String STYLE2 = 'style_2';
const String STYLE3 = 'style_3';
const String STYLE4 = 'style_4';
const String ORDERID = 'order_id';
const String OTP = "otp";
const String DELIVERY_BOY_ID = 'delivery_boy_id';
const String ISALRCANCLE = 'is_already_cancelled';
const String ISALRRETURN = 'is_already_returned';
const String ISRTNREQSUBMITTED = 'return_request_submitted';
const String OVERALL = 'overall_amount';
const String AVAILABILITY = 'availability';
const String MADEIN = 'made_in';
const String INDICATOR = 'indicator';
const String STOCKTYPE = 'stock_type';
const String SAVE_LATER = 'is_saved_for_later';
const String ATT_VAL = 'attribute_values';
const String ATT_VAL_ID = 'attribute_values_id';
const String FILTERS = 'filters';
const String TOTALALOOW = 'total_allowed_quantity';
const String KEY = 'key';
const String AMOUNT = 'amount';
const String CONTACT = 'contact';
const String TXNID = 'txn_id';
const String SUCCESS = 'Success';
const String ACTIVE_STATUS = 'active_status';
const String WAITING = 'awaiting';
const String TRANS_TYPE = 'transaction_type';
const String QUESTION = "question";
const String ANSWER = "answer";
const String INVOICE = "invoice_html";
const String APP_THEME = "App Theme";
const String SHORT = "short_description";
const String FROMTIME = 'from_time';
const String TOTIME = 'last_order_time';
const String REFERCODE = 'referral_code';
const String FRNDCODE = 'friends_code';
const String VIDEO = 'video';
const String VIDEO_TYPE = 'video_type';
const String WARRANTY = 'warranty_period';
const String GAURANTEE = "guarantee_period";
const String OPEN_STORE_TIME = "open_store_time";
const String CLOSE_STORE_TIME = "close_store_time";
const String TAG = 'tags';
const String CITYNAME = "cityName";
const String AREANAME = "areaName";
const String LAGUAGE_CODE = 'languageCode';
const String MINORDERQTY = 'minimum_order_quantity';
const String QTYSTEP = 'quantity_step_size';
const String DEL_DATE='delivery_date';
const String DEL_TIME='delivery_time';
const String TOTALIMG='total_images';
const String TOTALIMGREVIEW='total_reviews_with_images';
const String PRODUCTRATING='product_rating';



const String DEFAULT_SYSTEM = "System default";
const String LIGHT = "Light";
const String DARK = "Dark";
String ISDARK = "";
final String PAYPAL_RESPONSE_URL = "$baseUrl" + "app_payment_status";
final String FLUTTERWAVE_RES_URL = baseUrl + "flutterwave-payment-response";

String CUR_CURRENCY = '';
String CUR_USERID = '';
String CUR_USERNAME = '';
String CUR_CART_COUNT = "0";
String CUR_BALANCE = '';
String RETURN_DAYS = '';
String MAX_ITEMS = '';
String REFER_CODE = '';
String MIN_AMT = '';
String MIN_CART_AMT = '';
String CUR_DEL_CHR = '';
String SCROLLING_TEXT = '';
bool payWarn = false;

bool ISFLAT_DEL = true;
bool extendImg = true;
bool cartBtnList = true;

double deviceHeight;
double deviceWidth;


List<SectionModel> cartList = [];

String getQty(Product model){
    print("getQty init " + model.name);
    String t = model.prVarientList[model.selVarient].cartCount;
    if(cartList.isNotEmpty){
        cartList.forEach((element) {
            print("getQty Comparing " + element.productList[0].prVarientList[0].name() + " with " + model.prVarientList[model.selVarient].name());
            if(element.varientId == model.prVarientList[model.selVarient].id){
                print("getQty Item " + element.productList[0].prVarientList[0].name() + " Found In Cart with " + element.qty.toString());
                t = element.qty;
            }
        });
    }
    //updateCartCounter();
    return model.prVarientList[model.selVarient].cartCount = t;
}

void setQty(SectionModel model, {String qty:"0"}){
    print("setQty init " + model.productList[0].name);
    if(cartList.isNotEmpty){
        cartList.forEach((element) {
            if(element.varientId == model.varientId){
                print("setQty Comparing " + element.productList[0].prVarientList[0].name() + " with " + model.productList[0].prVarientList[model.productList[0].selVarient].name());
                //model.qty = qty;
                updateQty(model.productList[0], qty);
            }
        });
    }
    return ;
    // cartList.removeWhere((item) => item.varientId == cartList[index].varientId);
}

void updateQty(Product model, String qty){
    model.prVarientList[model.selVarient].cartCount = qty;
    if(cartList.isNotEmpty){
        cartList.asMap().forEach((index, element) {
            if(element.varientId == model.prVarientList[model.selVarient].id){
                cartList[index].qty = qty;
                model.prVarientList[model.selVarient].cartCount = qty;
            }
        });
    }
    //updateCartCounter();
}
void updateCartCounter(){
    int total = 0;
    print("updateCartCounter : " + total.toString() + " Cart Length : " + cartList.length.toString());
    if(cartList.isNotEmpty){
        cartList.forEach((element) {
            total += int.parse(element.qty);
            print("updateCartCounter : " + element.productList[0].name + " " + element.productList[0].prVarientList[0].name() + total.toString());
        });
    }
    CUR_CART_COUNT = total.toString();
    print("updateCartCounter : CUR_CART_COUNT : " + total.toString());
}

String getTotalQty(){
    int total = 0;
    if(cartList.isNotEmpty){
        cartList.forEach((element) {
            total += int.parse(element.qty);
        });
    }
    return total.toString();
}