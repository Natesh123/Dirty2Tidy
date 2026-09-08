
import 'package:demandium/api/local/cache_response.dart';
import 'package:demandium/helper/data_sync_helper.dart';
import 'package:get/get.dart';
import 'package:demandium/utils/core_export.dart';



class CartController extends GetxController implements GetxService {
  final CartRepo cartRepo;
  CartController({required this.cartRepo});

  List<CartModel> _cartList = [];
  List<CartModel> _initialCartList = [];
  bool _isLoading = false;
  bool _isCartLoading = false;
  double _amount = 0.0;
  final bool _isOthersInfoValid = false;
  bool _isButton = false;

  List<CartModel> get cartList => _cartList;
  List<CartModel> get initialCartList => _initialCartList;
  double get amount => _amount;
  bool get isLoading => _isLoading;
  bool get isCartLoading  => _isCartLoading ;
  bool get isOthersInfoValid => _isOthersInfoValid;

  bool get isButton => _isButton;


  List<ProviderData>? _providerList;
  List<ProviderData>? get  providerList=> _providerList;

  double _totalPrice = 0;
  double get totalPrice => _totalPrice;
  set updateTotalPrice(double price) => _totalPrice = price;

  double _walletBalance = 0.0;
  double get walletBalance => _walletBalance;


  double _referralAmount = 0.0;
  double get referralAmount => _referralAmount;

  double _bookingAmountWithoutCoupon = 0.0;
  double _couponAmount = 0.0;


  bool _walletPaymentStatus = false;
  bool get walletPaymentStatus => _walletPaymentStatus;

  ProviderData? _selectedProvider;
  ProviderData? get selectedProvider => _selectedProvider;


  String subcategoryId ='';

  int selectedProviderIndex = -1;


  Future<void> getCartListFromServer({bool shouldUpdate = true}) async{

    DataSyncHelper.fetchAndSyncData(
      fetchFromLocal: ()=>  cartRepo.getCartListFromServer<CacheResponseData>( source: DataSourceEnum.local),
      fetchFromClient: ()=> cartRepo.getCartListFromServer(source: DataSourceEnum.client),
      onResponse: (data, source) {
        if (kDebugMode) {
           print("CartController Raw Data ($source): $data");
        }
        try {
          _cartList = [];
          if (data['content'] != null && data['content']['cart'] != null && data['content']['cart']['data'] != null) {
             data['content']['cart']['data'].forEach((cart){
                _cartList.add(CartModel.fromJson(cart));
             });
          } else {
             if (kDebugMode) {
               print("CartController parsing warning: data['content']['cart']['data'] is null/missing");
             }
          }

          if( data['content'] != null){
             if( data['content']['wallet_balance']!=null){
               _walletBalance = double.tryParse( data['content']['wallet_balance'].toString())!;
             }
             if( data['content']['total_cost']!=null){
               _totalPrice = double.tryParse( data['content']['total_cost'].toString())!;
             }
             if( data['content']['referral_amount']!=null){
               _referralAmount = double.tryParse( data['content']['referral_amount'].toString())!;
             }
          }

          if(_cartList.isNotEmpty){
            if(_cartList[0].provider!=null){
              _selectedProvider = _cartList[0].provider;
            }
            subcategoryId = _cartList[0].subCategoryId;
          }
        } catch (e, stack) {
          if (kDebugMode) {
            print("CartController Parsing Error: $e\n$stack");
          }
        }
        update();
      },
    );
  }

  Future<void> removeCartFromServer(CartModel cart)async{
    _isLoading = true;
    Response response = await cartRepo.removeCartFromServer(cart.id);
    if(response.statusCode == 200){
      _cartList.remove(cart);
    }

    await getCartListFromServer(shouldUpdate: false);
    _isLoading = false;
    update();
  }


  Future<void> removeAllCartItem()async{
    Response response = await cartRepo.removeAllCartFromServer();
    if(response.statusCode == 200){
      _isLoading = false;
      getCartListFromServer(shouldUpdate: false);
    }
  }

  Future<void> clearCartData() async {
    _cartList = [];
    _initialCartList = [];
    _totalPrice = 0;
    _selectedProvider = null;
    subcategoryId = '';
    selectedProviderIndex = -1;
    update();
    await cartRepo.removeAllCartFromServer();
  }

  Future<void> removeServiceWithVariantsFromServer(String serviceId) async {
    _isLoading = true;
    update();

    List<CartModel> itemsToRemove = _cartList.where((item) => item.serviceId == serviceId).toList();

    for (var item in itemsToRemove) {
      Response response = await cartRepo.removeCartFromServer(item.id);
      if(response.statusCode == 200){
        _cartList.remove(item);
      }
    }

    await getCartListFromServer(shouldUpdate: false);
    _isLoading = false;
    update();
  }

  Future<void> updateCartQuantityToApi(String cartID, int quantity)async{
    _isCartLoading = true;
    update();


    Response response = await cartRepo.updateCartQuantity(cartID, quantity);
    if(response.statusCode == 200){
      _cartList = [];
      response.body['content']['cart']['data'].forEach((cart){
        _cartList.add(CartModel.fromJson(cart));

      });

      if(response.body['content']['wallet_balance']!=null){
        _walletBalance = double.tryParse(response.body['content']['wallet_balance'].toString())!;
      }

      if(response.body['content']['total_cost']!=null){
        _totalPrice = double.tryParse(response.body['content']['total_cost'].toString())!;
      }

      if(response.body['content']['referral_amount']!=null){
        _referralAmount = double.tryParse(response.body['content']['referral_amount'].toString())!;
      }

      if(_cartList.isNotEmpty){
        if(_cartList[0].provider!=null){
         _selectedProvider = _cartList[0].provider;
        }
        subcategoryId = _cartList[0].subCategoryId;
      }
    }

    _isCartLoading = false;
    update();
  }

  Future<void> updateProvider(ProviderData? providerData)async{

    _isCartLoading = true;
    update();
    _selectedProvider = providerData;

    Response response = await cartRepo.updateProvider(providerData?.id ?? "");
    if(response.statusCode == 200){
      await getCartListFromServer();
      Get.find<ScheduleController>().buildSchedule(scheduleType: ScheduleType.asap);
    }else{

    }
    _isCartLoading = false;
    update();
  }


  void removeFromCartVariation(CartModel? cartModel) {
    if(cartModel == null) {
      _initialCartList = [];
    }else{
      _initialCartList.remove(cartModel);
      update();
    }
  }

  void removeFromCartList(int cartIndex) {
    _cartList[cartIndex].quantity = _cartList[cartIndex].quantity - 1;
    update();
  }

  void updateQuantity(int index, bool isIncrement) {
    if(isIncrement){
      _initialCartList[index].quantity += 1;
    }else{
      if(_initialCartList[index].quantity > 0) {
        _initialCartList[index].quantity -= 1;
      }
    }
    // Recalculate tax for this item
    _initialCartList[index].taxAmount = (_initialCartList[index].serviceCost * _initialCartList[index].quantity * (_initialCartList[index].service?.tax ?? 0) / 100);
    
    _calculateTotalPrice();
    _isButton = _isQuantity();
    update();
  }

 bool _isQuantity( ) {
    int count = 0;
    for (var cart in _initialCartList) {
      count += cart.quantity;
    }
    return count > 0;
  }



  void addDataToCart(){
    if(_cartList.isNotEmpty && _initialCartList.first.subCategoryId != _cartList.first.subCategoryId) {
      Get.back();
      Get.dialog(ConfirmationDialog(
        icon: Images.warning,
        title: "are_you_sure_to_reset".tr,
        description: 'you_have_service_from_other_sub_category'.tr,
        onYesPressed: () async {
          _initialCartList.removeWhere((cart) => cart.quantity < 1);
          _cartList = _initialCartList;

          update();
          onDemandToast("successfully_added_to_cart".tr,Colors.green);
          Get.back();
        },
      ));
    }else{
      update();
      onDemandToast("successfully_added_to_cart".tr,Colors.green);
      Get.back();
    }

  }

  Future<void> addMultipleCartToServer({bool fromServiceCenterDialog = true, required String providerId, bool onlyAddCurrentService = false}) async {
    _isLoading = true;
    update();

    if (_initialCartList.isNotEmpty) {
      // Intentionally removed broken auto-select logic. 
      // We only want to book what the user actually selected.
    }

    if(onlyAddCurrentService){
      _cartList = _initialCartList.where((element) => element.quantity > 0).toList();
    } else {
      _replaceCartList();
    }

    if(_initialCartList.isNotEmpty && _cartList.isNotEmpty && _initialCartList.first.subCategoryId != _cartList.first.subCategoryId && !onlyAddCurrentService){
      Get.back();
      Get.dialog(ConfirmationDialog(
        icon: Images.warning,
        title: "are_you_sure_to_reset".tr,
        description: 'you_have_service_from_other_sub_category'.tr,
        onNoPressed: (){
          Get.back();
        },
        onYesPressed: () async {
          Get.back();
          Get.dialog(const CustomLoader(), barrierDismissible: false,);
          await cartRepo.removeAllCartFromServer();
          bool isSuccess = true;
          if(_initialCartList.isNotEmpty){
            for (int index=0; index<_initialCartList.length;index++){
              if(_initialCartList[index].quantity > 0){
                bool success = await addToCartApi(_initialCartList[index], providerId: providerId);
                if(!success) isSuccess = false;
              }
            }
          }
         await getCartListFromServer();
          _isLoading = false;
          Get.back();
          if(fromServiceCenterDialog && isSuccess){
            customSnackBar("successfully_added_to_cart".tr,type : ToasterMessageType.success);
          } else if (fromServiceCenterDialog && !isSuccess) {
            customSnackBar("failed_to_add_to_cart".tr, type: ToasterMessageType.error);
          }
        },
      ));
    }
    else{
      await cartRepo.removeAllCartFromServer();
      bool isSuccess = true;
      if(_cartList.isNotEmpty){
        for (int index=0; index<_cartList.length;index++){
          if(_cartList[index].quantity > 0){
            bool success = await addToCartApi(_cartList[index], providerId: providerId);
            if(!success) isSuccess = false;
          }
        }
      }
      await getCartListFromServer();

      if(fromServiceCenterDialog && isSuccess){
        Get.back();
        customSnackBar("successfully_added_to_cart".tr,type : ToasterMessageType.success);
      } else if (fromServiceCenterDialog && !isSuccess) {
         Get.back(); // ensuring dialog closes
         customSnackBar("failed_to_add_to_cart".tr, type: ToasterMessageType.error);
      }
    }
    _isLoading = false;
    update();
  }

  Future<bool> addToCartApi(CartModel cartModel, {required String providerId})async{
    Response response;
    if( providerId!= ""){
     response = await cartRepo.addToCartListToServer(CartModelBody(
        serviceId:cartModel.service!.id,
        categoryId: cartModel.categoryId,
        variantKey: cartModel.variantKey,
        quantity: cartModel.quantity.toString(),
        subCategoryId: cartModel.subCategoryId.isEmpty ? null : cartModel.subCategoryId,
        providerId: providerId,
        guestId: Get.find<SplashController>().getGuestId(),
      ));
    }else{
       response = await cartRepo.addToCartListToServer(CartModelBody(
        serviceId:cartModel.service!.id,
        categoryId: cartModel.categoryId,
        variantKey: cartModel.variantKey,
        quantity: cartModel.quantity.toString(),
        subCategoryId: cartModel.subCategoryId.isEmpty ? null : cartModel.subCategoryId,
        guestId: Get.find<SplashController>().getGuestId(),
      ));
    }
    if (kDebugMode) {
      print("AddToCart Response: ${response.statusCode} - ${response.body}");
    }
    if(response.statusCode == 200){
      return true;
    }else{
      return false;
    }
  }

  void removeAllAndAddToCart(CartModel cartModel) {
    _cartList = [];
    _cartList.add(cartModel);
    _amount = cartModel.discountedPrice.toDouble() * cartModel.quantity;
    update();
  }

  int isAvailableInCart(CartModel cartModel, Service service) {
    int index = -1;
    for (var cart in _cartList) {
      if(cart.service != null){
        if(cart.service!.id!.contains(service.id!)) {
          service.variationsAppFormat?.zoneWiseVariations?.forEach((variation) {
            if(variation.variantKey == cart.variantKey && variation.price == cart.serviceCost) {

              if(cart.variantKey == cartModel.variantKey) {
                index = _cartList.indexOf(cart);
              }
            }
          });

        }
      }
    }
    return index;
  }

  setInitialCartList(Service service) {
    _totalPrice = 0;
    _initialCartList = [];
    
    List<ZoneWiseVariations>? variations = service.variationsAppFormat?.zoneWiseVariations;
    if (variations != null) {
      for (int i = 0; i < variations.length; i++) {
        ZoneWiseVariations variation = variations[i];
        
        int initialQty = 0;

        CartModel cartModel = CartModel(
            service.id!,
            service.id!,
            service.categoryId!,
            service.subCategoryId ?? "",
            variation.variantKey!,
            variation.price!,
            initialQty,
            0, 0, 0, 0,
            "",
            0,
            0, // tax
            0, // total
            service,
            variantImage: variation.image);
            
        // Do not preload from old cart as requested by user
        // int index = isAvailableInCart(cartModel, service);
        // if (index != -1) {
        //   cartModel.quantity = _cartList[index].quantity;
        // }

        double currentTotal = (cartModel.serviceCost * cartModel.quantity).toDouble();
        double currentTax = (service.tax ?? 0) > 0 ? (currentTotal * service.tax! / 100) : 0;
        
        cartModel.taxAmount = currentTax;

        cartModel = CartModel(
            service.id!,
            service.id!,
            service.categoryId!,
            service.subCategoryId ?? "",
            variation.variantKey!,
            variation.price!,
            cartModel.quantity,
            0, 0, 0, 0,
            "",
            0,
            currentTax,
            currentTotal + currentTax,
            service,
            variantImage: variation.image);

        _initialCartList.add(cartModel);
      }
    }

    _calculateTotalPrice();
    _isButton = _isQuantity(); // Re-evaluate button state
  }

  void _calculateTotalPrice() {
    _totalPrice = CheckoutHelper.calculateGrandTotal(
      cartList: _initialCartList,
      referralDiscount: referralAmount,
    );
  }

  List<CartModel> _replaceCartList() {
    _initialCartList.removeWhere((cart) => cart.quantity < 0);

    for (var initCart in _initialCartList) {
      _cartList.removeWhere((cart) => cart.id.contains(initCart.id) && cart.variantKey.contains(initCart.variantKey));
    }
    _cartList.addAll(_initialCartList);
    _cartList.removeWhere((element) => element.quantity == 0);

    return _cartList;
  }

  Future<void> getProviderBasedOnSubcategory(String subcategoryId,bool reload) async {

    if(reload || _providerList == null){
      _providerList = null;
    }
    Response response = await cartRepo.getProviderBasedOnSubcategory(subcategoryId);
    if (response.statusCode == 200) {
      _providerList = [];
      List<dynamic> list =  response.body['content'];

      for (var element in list) {
        providerList!.add(ProviderData.fromJson(element));
      }

      if(_selectedProvider != null && _providerList != null && _providerList!.isNotEmpty){
        for(int i = 0 ; i <_providerList!.length ; i ++ ){
          if(_selectedProvider?.id == _providerList![i].id){
            selectedProviderIndex =i;
          }
        }
      }else{
        selectedProviderIndex = -1;
      }
    } else {
      _providerList = [];
    }
    update();
  }

  void updateProviderSelectedIndex(int index){
    selectedProviderIndex = index;
    update();
  }

  void updatePreselectedProvider(ProviderData? providerData, {bool shouldUpdate = true}){
   _selectedProvider = providerData;

   if(shouldUpdate){
     update();
   }

  }


  void updateWalletPaymentStatus(bool status, {bool shouldUpdate = true}){
    _walletPaymentStatus = status;

    if(shouldUpdate){
      update();
    }
  }

  updateBookingAmountWithoutCoupon(){
    _couponAmount = CheckoutHelper.calculateDiscount(cartList: _cartList, discountType: DiscountType.coupon);
    _bookingAmountWithoutCoupon =CheckoutHelper.calculateTotalAmountWithoutCoupon(cartList: _cartList);
  }


  bool isOpenPartialPaymentPopup = true;




  Future<void> openWalletPaymentConfirmDialog() async {
    bool initialCheck;
    bool checkAfterUsingCoupon;

    if(_bookingAmountWithoutCoupon > walletBalance){
      initialCheck = true;
    }else{
      initialCheck = false;
    }
    if(_bookingAmountWithoutCoupon > (walletBalance + _couponAmount)){
      checkAfterUsingCoupon =  true;
    }else{
      checkAfterUsingCoupon = false;
    }

    if(initialCheck != checkAfterUsingCoupon && walletPaymentStatus && isOpenPartialPaymentPopup){
      showGeneralDialog(barrierColor: Colors.black.withValues(alpha: 0.5),
        transitionBuilder: (context, a1, a2, widget) {
          return Transform.scale(
            scale: a1.value,
            child: Opacity(
              opacity: a1.value,
              child: Center(
                child: Padding( padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
                  child: Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                        color: Theme.of(context).cardColor
                    ),

                    child: Stack(
                      alignment: Alignment.topRight,
                      clipBehavior: Clip.none,
                      children: [
                        const WalletPaymentConfirmDialog(),
                        IconButton(
                          padding: const EdgeInsets.all(0),
                          onPressed: (){
                            Get.back();
                            updateWalletPaymentStatus(false);
                          },
                          icon :  const Icon(Icons.cancel),color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.6),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
        transitionDuration: const Duration(milliseconds: 200),
        barrierDismissible: false,
        barrierLabel: '',
        context: Get.context!,
        pageBuilder: (context, animation1, animation2){
          return Container();
        },
      );
    }
  }


  void showMinimumAndMaximumOrderValueToaster() {
    ConfigModel configModel = Get.find<SplashController>().configModel;

    Get.closeAllSnackbars();

    if(configModel.content!.minBookingAmount !=0 && configModel.content!.minBookingAmount! > _totalPrice && _cartList.isNotEmpty){
      customSnackBar("message",
        customWidget: Row(children: [
          Icon(Icons.circle, color: Colors.white.withValues(alpha: 0.8),size: 16,),
          Text("  ${'minimum_booking_amount'.tr} ${PriceConverter.convertPrice(Get.find<SplashController>().configModel.content!.minBookingAmount!)}",
            style: robotoRegular.copyWith(color: Colors.white),
          ),
        ],),
      );
    }else{
      if(configModel.content!.maxBookingAmount !=0 && configModel.content!.maxBookingAmount! < _totalPrice &&  _cartList.isNotEmpty){
        customSnackBar("message",
          customWidget: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(crossAxisAlignment: CrossAxisAlignment.start,children: [
                Icon(Icons.warning_outlined, color: Theme.of(Get.context!).cardColor.withValues(alpha: 0.6),size: 16,),
                const SizedBox(width: Dimensions.paddingSizeExtraSmall,),
                Flexible(child: Text(" ${'maximum_order_amount_exceed'.tr} ""(${'${'maximum_order_amount'.tr}'
                    ' ${PriceConverter.convertPrice(Get.find<SplashController>().configModel.content!.maxBookingAmount!)}'}) ${"admin_will_verify_this_order".tr}",
                  style: robotoRegular.copyWith(color: Colors.white),
                )),
              ],),
            ],
          ),
        );
      }
    }
  }

  Future<void> rebook(String bookingId) async{
    cartRepo.addRebookToServer(bookingId);
  }

  String maskNumberWithoutCountryCode(String phoneNumber) {
    if (phoneNumber.length <= 6) {
      return phoneNumber;
    }
    String maskedNumber = phoneNumber.substring(0, phoneNumber.length - 6); // Keep initial digits

    maskedNumber += '***';
    maskedNumber += phoneNumber.substring(phoneNumber.length - 3);
    return maskedNumber;
  }

  bool checkProviderUnavailability(){
    return _cartList.isNotEmpty &&  _cartList[0].provider !=null &&
        (_cartList[0].provider?.serviceAvailability == 0 || _cartList[0].provider?.isActive== 0 || _cartList[0].provider?.nextBookingEligibility == false);
  }

  String? checkScheduleBookingAvailability(){

    if(Get.find<SplashController>().configModel.content?.scheduleBooking == 0){
      return 'schedule_booking_currently_unavailable'.tr ;
    }else if(_cartList.isNotEmpty &&  _cartList[0].provider != null && ( _cartList[0].provider?.scheduleBookingEligibility == false)){
      return 'schedule_booking_currently_unavailable_for_this_provider'.tr ;
    }else{
      return null;
    }
  }


}
