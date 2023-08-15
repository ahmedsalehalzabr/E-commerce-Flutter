// ignore_for_file: non_constant_identifier_names, constant_identifier_names

import 'package:numo/Helper/Constant.dart';

//#region NUMO API Calls ==================================================

final Uri postNumoMerchantAddApi = Uri.parse('${numoUrl}merchants/register/');
final Uri postNumoMerchantLoginApi = Uri.parse('${numoUrl}merchantusers/login/');
final Uri postNumoMerchantTypeApi = Uri.parse('${numoUrl}merchanttypes/');
final Uri postNumoMerchantAddressApi = Uri.parse('${numoUrl}merchantaddresses/');
final Uri postNumoMerchantSessionApi = Uri.parse('${numoUrl}merchantsessions/');

final Uri postNumoOrderApi = Uri.parse('${numoUrl}orders/');
final Uri postNumoFavoriteApi = Uri.parse('${numoUrl}favorites/');

final Uri getNumoSettingApi = Uri.parse('${numoUrl}stores/');
final Uri getNumoTermsApi = Uri.parse('${numoUrl}termsandpolicy/');
final Uri getNumoSectionApi = Uri.parse('${numoUrl}sections/');
final Uri getNumoCitiesApi = Uri.parse('${numoUrl}cities/');
final Uri getNumoRegionByCityApi = Uri.parse('${numoUrl}regions/city/');

final Uri getNumoCatApi = Uri.parse('${numoUrl}categories');
final Uri getNumoParentCatApi = Uri.parse('${numoUrl}categories?allparents=1');
final Uri getNumoSubcatApi = Uri.parse('${numoUrl}categories?allchild=1');

final Uri getNumoProductByCategoryApi = Uri.parse('${numoUrl}products/category/');
final Uri getNumoProductsApi = Uri.parse('${numoUrl}products/');
final Uri getNumoCartsApi = Uri.parse('${numoUrl}carts/');
final Uri postNumoCartItemsApi = Uri.parse('${numoUrl}carts/cartitems/');
final Uri getNumoFavsApi = Uri.parse('${numoUrl}favorites/');

final Uri getNumoRelatedByIDApi = Uri.parse('${numoUrl}products/related/');

final Uri getNumoSliderApi = Uri.parse('${numoUrl}sliders/');

//#endregion ===============================================================

//#endregion ===============================================================
//#endregion ===============================================================

final Uri getSliderApi = Uri.parse('${baseUrl}get_slider_images');
final Uri getCatApi = Uri.parse('${baseUrl}get_categories');

final Uri getSectionApi = Uri.parse('${baseUrl}get_sections');
final Uri getSettingApi = Uri.parse('${baseUrl}get_settings');

final Uri getSubcatApi = Uri.parse('${baseUrl}get_subcategories_by_category_id');
final Uri getProductApi = Uri.parse('${baseUrl}get_products');
final Uri manageCartApi = Uri.parse('${baseUrl}manage_cart');
final Uri getUserLoginApi = Uri.parse('${baseUrl}login');
final Uri getUserSignUpApi = Uri.parse('${baseUrl}register_user');
final Uri getVerifyUserApi = Uri.parse('${baseUrl}verify_user');

final Uri setFavoriteApi = Uri.parse('${baseUrl}add_to_favorites');
final Uri removeFavApi = Uri.parse('${baseUrl}remove_from_favorites');
final Uri getRatingApi = Uri.parse('${baseUrl}get_product_rating');
final Uri getReviewImgApi = Uri.parse('${baseUrl}get_product_review_images');
final Uri getCartApi = Uri.parse('${baseUrl}get_user_cart');
final Uri getFavApi = Uri.parse('${baseUrl}get_favorites');
final Uri setRatingApi = Uri.parse('${baseUrl}set_product_rating');
final Uri getNotificationApi = Uri.parse('${baseUrl}get_notifications');
final Uri getAddressApi = Uri.parse('${baseUrl}get_address');
final Uri deleteAddressApi = Uri.parse("${baseUrl}delete_address");
final Uri getResetPassApi = Uri.parse('${baseUrl}reset_password');
final Uri getCitiesApi = Uri.parse('${baseUrl}get_cities');
final Uri getAreaByCityApi = Uri.parse('${baseUrl}get_areas_by_city_id');
final Uri getUpdateUserApi = Uri.parse('${baseUrl}update_user');
final Uri getAddAddressApi = Uri.parse('${baseUrl}add_address');
final Uri updateAddressApi = Uri.parse('${baseUrl}update_address');
final Uri placeOrderApi = Uri.parse('${baseUrl}place_order');
final Uri validatePromoApi = Uri.parse('${baseUrl}validate_promo_code');
final Uri getOrderApi = Uri.parse('${baseUrl}get_orders');
final Uri updateOrderApi = Uri.parse('${baseUrl}update_order_status');
final Uri updateOrderItemApi = Uri.parse('${baseUrl}update_order_item_status');
final Uri paypalTransactionApi = Uri.parse('${baseUrl}get_paypal_link');
final Uri addTransactionApi = Uri.parse('${baseUrl}add_transaction');
final Uri getJwtKeyApi = Uri.parse('${baseUrl}get_jwt_key');
final Uri getOfferImageApi = Uri.parse('${baseUrl}get_offer_images');
final Uri getFaqsApi = Uri.parse('${baseUrl}get_faqs');
final Uri updateFcmApi = Uri.parse('${baseUrl}update_fcm');
final Uri getWalTranApi = Uri.parse('${baseUrl}transactions');
final Uri getPytmChecsumkApi = Uri.parse('${baseUrl}generate_paytm_txn_token');
final Uri deleteOrderApi = Uri.parse('${baseUrl}delete_order');
final Uri getTicketTypeApi = Uri.parse('${baseUrl}get_ticket_types');
final Uri addTicketApi = Uri.parse('${baseUrl}add_ticket');
final Uri editTicketApi = Uri.parse('${baseUrl}edit_ticket');
final Uri sendMsgApi = Uri.parse('${baseUrl}send_message');
final Uri getTicketApi = Uri.parse('${baseUrl}get_tickets');
final Uri validateReferalApi = Uri.parse('${baseUrl}validate_refer_code');
final Uri flutterwaveApi = Uri.parse('${baseUrl}flutterwave_webview');
final Uri getMsgApi = Uri.parse('${baseUrl}get_messages');
final Uri setBankProofApi = Uri.parse('${baseUrl}send_bank_transfer_proof');
final Uri checkDeliverableApi = Uri.parse("${baseUrl}is_product_delivarable");
final Uri checkCartDelApi = Uri.parse('${baseUrl}check_cart_products_delivarable');
final Uri getPromoCodeApi = Uri.parse('${baseUrl}get_promo_codes');
final Uri setProductFaqsApi = Uri.parse('${baseUrl}add_product_faqs');
final Uri getProductFaqsApi = Uri.parse('${baseUrl}get_product_faqs');
final Uri setDeleteAccApi = Uri.parse('${baseUrl}delete_user');
final Uri setSendWithdrawReqApi = Uri.parse('${baseUrl}send_withdrawal_request');
final Uri getWithdrawReqApi = Uri.parse('${baseUrl}get_withdrawal_request');

const String ISFIRSTTIME = 'isfirst$appName';
const String HISTORYLIST = '$appName+historyList';

//?=============NUMO PARAMETERS=====================

//*         GLOBAL
//*         GLOBAL
const String IS_ON_MAINTENANCE = 'isOnMaintenance';
const String MINPRICE = 'min_price';
const String MAXPRICE = 'max_price';
const String CURRENCY = 'Currency';
const String CURRENCY_CODE = 'currency_code';
const String PRODUCTSETTING = 'ProductSetting';
const String MAXRETURNDAYS = 'maxReturnDays';
const String MAX_ITEMS_CART = 'max_items_cart';
const String MINORDERAMOUNT = 'minOrderAmount';
const String MAXORDERAMOUNT = 'maxOrderAmount';
const String ACCESS_TOKEN = 'accessToken';
const String SORT = 'sort';
const String ORDER = 'order';
const String COUNT = 'count';
const String FAVORIATE_ID = 'favorite_id';
const String FAVORIATES = 'Favorites';
const String SHIPPING_POLICY = 'shipping_policy';
const String RETURN_POLICY = 'return_policy';
const String PRIVACY_POLLICY = 'privacy_policy';
const String TERM_COND = 'terms_conditions';
const String PAYMENT_TERMS = 'payment_terms';
const String CONTACT_US = 'contact_us';
const String ABOUT_US = 'about_us';

//*         CITY
//*         COUNTRY-----
const String COUNTRY = 'Country';
const String CITY = 'City';
const String REGION = 'Region';
const String COUNTRY_ID = 'country_id';
const String COUNTRY_NAME = 'country_name';
const String COUNTRY_CALL = 'country_call';
const String COUNTRY_CODE = 'country_code';
const String CITY_ID = 'city_id';
const String CITY_NAME = 'city_name';
const String CITY_CODE = 'city_code';
const String REGION_ID = 'region_id';
const String REGION_NAME = 'region_name';
const String REGION_CODE = 'region_code';

//*         ATRRIBUTE
const String ATTRIBUTES = 'Attributes';
const String ATTRIBUTE_ID = 'attribute_id';
const String ATTRIBUTE_NAME = 'attribute_name';

//*         ATRRIBUTETYPE
const String ATTRIBUTETYPE_ID = 'attributeType_id';
const String ATTRIBUTETYPE_NAME = 'attributeType_name';
const String ATTRIBUTETYPE_ACTION = 'attributeType_action';

//*         ATRRIBUTEVALUE
const String ATTRIBUTEVALUES = 'AttributeValues';
const String ATTRIBUTEVALUE_ID = 'attributeValue_id';
// const String ATTRIBUTEVALUE_IDS = 'attributeValue_ids';
const String ATTRIBUTEVALUE_NAME = 'attributeValue_name';
const String ATTRIBUTEVALUE_VALUE = 'attributeValue_value';

//*         PRODUCTVALUEID
const String PRODUCTVALUEIDS = 'AttributeValues';
const String PRODUCTVALUEID_ID = 'productValueID_id';

//*         UNIT
const String UNIT = 'Unit';
const String UNIT_ID = 'unit_id';
const String UNIT_NAME = 'unit_name';


//*         UNIT
const String WEIGHTUNIT = 'WeightUnit';
const String WEIGHTUNIT_ID = 'weightUnit_id';
const String WEIGHTUNIT_VALUE = 'weightUnit_value';
const String WEIGHTUNIT_NAME = 'weightUnit_name';


//*         PRODUCTTYPE
const String PRODUCTTYPE = 'ProductType';
const String PRODUCTTYPE_ID = 'productType_id';
const String PRODUCTTYPE_NAME = 'productType_name';
const String PRODUCTTYPE_DESC = 'productType_desc';
const String IS_DELIVERABLE = 'is_deliverable';

//*         PRODUCTIMAGE
const String PRODUCTIMAGES = 'ProductImages';
const String IMAGE_ID = 'image_id';
const String IMAGE_URL = 'image_url';
const String POSITION = 'position';

//*         BRAND
const String BRAND = 'Brand';
const String BRAND_ID = 'brand_id';
const String BRAND_NAME = 'brand_name';
const String BRAND_DESC = 'brand_desc';
const String BRAND_IMAGE = 'brand_image';
const String BRAND_COMPANY = 'brand_company';

//*         PRODUCT
const String PRODUCT = 'Product';
const String PRODUCTS = 'Products';
const String PRODUCT_ID = 'product_id';
// const String BRAND_ID = 'brand_id';
const String PRODUCT_NAME = 'product_name';
const String PRODUCT_DESC = 'product_desc';
const String PRODUCT_IMAGE = 'product_image';
const String PRODUCT_FULLDESC = 'product_fullDesc';
const String PRODUCT_CANSHIP = 'product_canShip';
// const String PRODUCTTYPE_ID = 'productType_id';
const String PRODUCT_ISFEATURED = 'product_isFeatured';
const String PRODUCT_TAXABLE = 'product_taxable';
const String PRODUCT_TAGS = 'product_tags';
const String PRODUCT_SKU = 'SKU';
const String BARCODE = 'barcode';
const String MAXORDERQTY = 'maxOrderQty';
const String MINORDERQTY = 'minOrderQty';
const String PRICE1 = 'price1';
const String PRICE2 = 'price2';
const String PRICE3 = 'price3';
const String PRICE4 = 'price4';
const String OLD_PRICE = 'old_price';
const String RETAIL_PRICE = 'retail_price';
const String CONTAINS = 'contains';
const String WEIGHT = 'weight';
const String ACTIVE = 'active';
const String COMPANY_ID = 'active';
const String CREATEDBY = 'createdBy';
const String MODIFIEDBY = 'modifiedBy';

//*         PRODUCTATTRIBUTEVALUE

const String PRODUCTATTRIBUTEVALUES = 'ProductAttributeValues';
const String PRODUCTATTRIBUTEVALUE = 'ProductAttributeValue';
const String PRODATTVALUE_ID = 'prodAttValue_id';
// const String BRAND_ID = 'brand_id';
const String TITLE = 'title';

//*         CATEGORY
const String CATEGORIES = 'Categories';
const String CATEGORY_ID = 'category_id';
const String CATEGORY_NAME = 'category_name';
const String CATEGORY_DESC = 'category_Desc';
const String CATEGORY_IMAGE = 'category_image';
const String CHILDERN = 'Childern';
const String ALLPARENTS = 'allparents';

//*         MERCHANT
const String MERCHANT = 'Merchant';
const String MERCHANT_ID = 'merchant_id';
const String MERCHANT_FULLNAME = 'merchant_fullName';
const String MERCHANT_COMNAME = 'merchant_comName';
const String MERCHANT_ADDRESS = 'merchant_address';
const String MERCHANT_PHONE1 = 'merchant_phone1';
const String MERCHANT_EMAIL = 'merchant_email';
const String MERCHANT_LOCATION = 'merchant_location';
const String MERCHANTTYPE_ID = 'merchantType_id';
const String MERCHANTTYPE_NAME = 'merchantType_name';

//*         MERCHANTUSER
const String MERCHANTUSER = 'MerchantUser';
const String MERCHANTUSER_ID = 'merchantUser_id';
const String MERCHANTUSER_NAME = 'merchantUser_name';
const String MERCHANTUSER_PHONE1 = 'merchantUser_phone1';
const String MERCHANTUSER_PASSWORD = 'merchantUser_password';
const String MERCHANTUSER_LOCATION = 'merchantUser_location';
const String PARENT_ID = 'parent_id';
const String MERCHANTUSER_ISADMIN = 'merchantUser_isAdmin';
const String MERCHANTUSER_IMAGE = 'merchantUser_image';
const String LATITUDE = 'latitude';
const String LONGITUDE = 'longitude';
const String MERCHANTUSER_PINCODE = 'merchantUser_pincode';

//*         MERCHANTSESSION
const  String SESSION_ID='session_id';
const  String DEVICE_SN='device_SN';
const  String DEVICE_IMEI='device_IMEI';
const  String DEVICE_MODEL='device_model';
const  String DEVICE_BRAND='device_brand';
const  String DEVICE_OS='device_OS';
const  String DEVICE_OSVERSION='device_OSVersion';
const  String SESSION_CLIENTTYPE='session_clientType';
const  String SESSION_CLIENTVERSION='session_clientVersion';
const  String SESSION_LOGINDATE='session_loginDate';
const  String SESSION_LASTACTIVEDATE='session_lastActiveDate';
const  String SESSION_STATUS='session_status';
const  String SESSION_VERIFIED='session_verified';


//*         MERCHANTADDRESS
const String MERCHANTADDRESS_ID = 'merchantAddress_id';
const String MERCHANTADDRESS_NAME = 'merchantAddress_name';
const String MOBILE = 'mobile';
const String ALTERNATE_MOBILE = 'alternate_mobile';
const String MERCHANTADDRESS_ADDRESS = 'merchantAddress_address';
const String IS_DEFAULT = 'is_default';
const String PINCODE = 'pincode';

//*         SLIDER
const String SLIDER_ID = 'slider_id';
const String SLIDERTYPE_ID = 'sliderType_id';
const String SLIDERTYPE_VALUE = 'sliderType_value';
const String SLIDERTYPE_NAME = 'sliderType_name';
const String TYPE_ID = 'type_id';
const String SLIDER_IMAGE = 'slider_image';
const String SLIDER_TITLE = 'slider_tilte';
const String ENDDATE = 'end_date';
const String STORE_ID = 'store_id';
const String SLIDERTYPE = 'SliderType';

//*         ORDERS AND ORDERITEMS-----
const String ORDER_ID = 'order_id';
const String ORDER_PHONENUMBER = 'order_phoneNumber';
const String ORDERITEM_QTY = 'orderItem_qty';
const String ORDERITEM_ID='orderItem_id';
const String ORDERITEM_PRICE='orderItem_price';
const String ORDERITEM_NOTES='orderItem_notes';
const String ORDER_TOTAL='order_total';
const String WAREHOUSE_ID='warehouse_id';
const String ORDER_REF='order_ref';
const String ORDER_SHIPPINGADDRESS='order_shippingAddress';
const String ORDER_LOCATION='order_location';
const String ORDER_SHIPPINGLOCATION='order_shippingLocation';

//*         CARTS AND CARTITEMS-----
const String CART_ID = 'cart_id';
const String CARTITEMS_COUNT = 'total';
const String CARTITEMS = 'CartItems';
const String CURRENCY_ID = 'currency_id';
const String CART_TOTAL = 'cart_total';
const String CART_STATUE = 'cart_status';
const String CART_REF = 'cart_ref';
const String CART_LOCATION = 'cart_location';
const String CARTITEM_ID = 'cartItem_id';
const String CARTITEM_QTY = 'cartItem_qty';
const String CARTITEM_PRICE = 'cartItem_price';
const String CARTITEM_NOTES = 'cartItem_notes';

//?================================================================

//*         GLOBAL Values----

String? SUPPORTED_LOCALES = '';

String? RETURN_DAYS = '10';
String? MAX_ITEMS = '';
String? REFER_CODE = '';
String? MIN_AMT = '';
String? MAX_AMT = '';
String? CUR_DEL_CHR = '';
String? MIN_ALLOW_CART_AMT = '';
String? CUR_MERCHANTID;
String? CUR_MERCHANTUSERID;
String? CUR_TOKEN;
String? CUR_PINCODE;
bool IS_LOGGINED = false;

//?================================================================
//?================================================================

const String ID = 'id';
const String TYPE = 'type';
const String IMAGE = 'image';
const String IMGS = 'images[]';
const String ATTACH = 'attachments[]';
const String DOCUMENT = 'documents[]';
const String NAME = 'name';
const String SUBTITLE = 'subtitle';
const String TAX = 'tax';
const String SLUG = 'slug';
const String PRODUCT_DETAIL = 'product_details';
const String DESC = 'description';
const String SUB = 'subject';
const String CATID = 'category_id';
const String CAT_NAME = 'category_name';
const String OTHER_IMAGE = 'other_images_md';
const String PRODUCT_VARIENT = 'variants';
// const String PRODUCT_ID = 'product_id';
const String VARIANT_ID = 'variant_id';

const String ZIPCODE = 'zipcode';
const String PRICE = 'price';
const String MEASUREMENT = 'measurement';
const String MEAS_UNIT_ID = 'measurement_unit_id';
const String SERVE_FOR = 'serve_for';
const String SHORT_CODE = 'short_code';
const String STOCK = 'stock';
const String STOCK_UNIT_ID = 'stock_unit_id';
const String DIS_PRICE = 'special_price';
const String SUB_ID = 'subcategory_id';

const String PSORT = 'p_sort';
const String PORDER = 'p_order';
const String DEL_CHARGES = 'delivery_charges';
const String FREE_AMT = 'minimum_free_delivery_order_amount';
const String ISFROMBACK = "isfrombackground$appName";

const String LIMIT = 'limit';
const String OFFSET = 'offset';
const String BANNER = 'banner';
const String CAT_FILTER = 'has_child_or_item';
const String PRODUCT_FILTER = 'has_empty_products';
const String RATING = 'rating';
const String IDS = 'ids';
const String VALUE = 'value';
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
const String USERDATA = 'user_data';
const String DATE_ADDED = 'date_added';
const String ORDER_ITEMS = 'order_items';
const String TOP_RETAED = 'top_rated_product';
const String WALLET = 'wallet';
const String CREDIT = 'credit';
const String REV_IMG = 'review_images';

const String USER_NAME = 'user_name';
const String USERNAME = 'username';
const String ADDRESS = 'address';
const String EMAIL = 'email';
// const String MOBILE = 'mobile';

const String DOB = 'dob';
const String AREA = 'area';
const String PASSWORD = 'password';
const String STREET = 'street';
const String FCM_ID = 'fcm_id';

const String SUPPORT_NUM = 'support_number';
const String USER_ID = 'user_id';
const String FAV = 'is_favorite';
const String ISRETURNABLE = 'is_returnable';
const String ISCANCLEABLE = 'is_cancelable';
const String ISPURCHASED = 'is_purchased';
const String ISOUTOFSTOCK = 'out_of_stock';
const String PRODUCT_VARIENT_ID1 = 'product_variant_id';
const String QTY = 'qty';
const String CART_COUNT = 'cart_count';
const String DEL_CHARGE = 'delivery_charge';
const String SUB_TOTAL = 'sub_total';
const String TAX_AMT = 'tax_amount';
const String TAX_PER = 'tax_percentage';
const String CANCLE_TILL = 'cancelable_till';
const String ALT_MOBNO = 'alternate_mobile';
const String STATE = 'state';
const String ISDEFAULT = 'is_default';
const String LANDMARK = 'landmark';

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
const String ATTR_VALUE = 'attr_value_ids';
const String MSG = 'message';
// const String ORDER_ID = 'order_id';
const String IS_SIMILAR = 'is_similar_products';
const String ALL = 'all';
const String PLACED = 'received';

const String SHIPED = 'shipped';
const String READY_TO_PICKUP = 'ready_to_pickup';
const String PROCESSED = 'processed';
const String DELIVERD = 'delivered';
const String CANCLED = 'cancelled';
const String RETURNED = 'returned';
const String awaitingPayment = 'Awaiting Payment';
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
const String TRACKING_ID = "tracking_id";
const String TRACKING_URL = "url";
const String COURIER_AGENCY = "courier_agency";
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
const String NOTES = "notes";
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
const String TAG = 'tags';
const String CITYNAME = "cityName";
const String AREANAME = "areaName";
const String LAGUAGE_CODE = 'languageCode';
// const String MINORDERQTY = 'minimum_order_quantity';
const String QTYSTEP = 'quantity_step_size';
const String DEL_DATE = 'delivery_date';
const String DEL_TIME = 'delivery_time';
const String TOTALIMG = 'total_images';
const String TOTALIMGREVIEW = 'total_reviews_with_images';
const String PRODUCTRATING = 'product_rating';
const String TICKET_TYPE = 'ticket_type_id';
const String DATE_CREATED = 'date_created';
const String DEFAULT_SYSTEM = "System default";
const String LIGHT = "Light";
const String DARK = "Dark";
const String TIC_TYPE = 'ticket_type';
const String TICKET_ID = 'ticket_id';
const String USER_TYPE = 'user_type';
const String USER = 'user';
const String MEDIA = 'media';
const String ICON = 'type';
const String STYPE = 'swatche_type';
const String SVALUE = 'swatche_value';
const String USER_RATING = 'user_rating';
const String USER_RATING_IMGS = 'user_rating_images';
const String USER_RATING_COMMENT = 'user_rating_comment';
const String NET_AMOUNT = 'net_amount';

const String ZIPCODEID = 'zipcode_id';
const String PROMO_CODE = 'promo_code';
const String REMAIN_DAY = 'remaining_day';
const String PROMO_CODES = 'promo_codes';
const String DISCOUNT = 'discount';
const String ORDER_NOTE = 'order_note';
const String ATTACHMENTS = 'attachments';
const String orderAttachments = 'order_attachments';

const String MIN_ORDER_AMOUNT = 'min_order_amt';
const String NO_OF_USERS = 'no_of_users';
const String DISCOUNT_TYPE = 'discount_type';
const String NO_OF_REPEAT_USAGE = 'no_of_repeat_usage';
const String REMAINING_DAYS = 'remaining_days';
const String MAX_DISCOUNT_AMOUNT = 'max_discount_amt';
const String START_DATE = 'start_date';
const String END_DATE = 'end_date';
const String REPEAT_USAGE = 'repeat_usage';

const String ATTACHMENT = 'attachment';
const String BANK_STATUS = 'banktransfer_status';
const String MIN_CART_AMT = 'minimum_cart_amt';
const String CAL_DIS_PER = 'cal_discount_percentage';
const String COD_ALLOWED = 'cod_allowed';
const String ALLOW_ATTACH = 'allow_order_attachments';
const String UPLOAD_LIMIT = 'upload_limit';
const String IS_ATTACH_REQ = 'is_attachment_required';
const String MAINTAINANCE_MODE = 'is_customer_app_under_maintenance';
const String MAINTAINANCE_MESSAGE = 'message_for_customer_app';
const String RECIPIENT_CONTACT = 'recipient_contact';
const String TOTAL_TAX_PERCENTAGE = 'total_tax_percent';
const String TOTAL_TAX_AMOUNT = 'total_tax_amount';

const String LOCAL_PICKUP = 'local_pickup';
const String ISLOCALPICKUP = 'is_local_pickup';
const String SELLET_NOTES = 'seller_notes';
const String PICKUP_TIME = 'pickup_time';
const String ANSWERED_BY = 'answered_by_name';
const String PAYMENT_ADD = 'payment_address';

String ISDARK = "";
const String PAYPAL_RESPONSE_URL = "$baseUrl" "app_payment_status";
const String FLUTTERWAVE_RES_URL = "${baseUrl}flutterwave-payment-response";

String? CUR_CURRENCY = '';
String? ALLOW_ATT_MEDIA = '';
String UP_MEDIA_LIMIT = '';
String? Is_APP_IN_MAINTANCE = '';
String? IS_APP_MAINTENANCE_MESSAGE = '';
String? CUR_TICK_ID = '';
String IS_LOCAL_PICKUP = '';
String ADMIN_ADDRESS = '';
String ADMIN_LAT = '';
String ADMIN_LONG = '';
String ADMIN_MOB = '';

bool ISFLAT_DEL = true;
bool extendImg = true;
bool cartBtnList = true;
bool refer = true;
//bool isCheck=false;

double? deviceHeight;
double? deviceWidth;
