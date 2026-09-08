import 'package:demandium/feature/checkout/widget/order_details_section/choose_service_location_widget.dart';
import 'package:demandium/feature/checkout/widget/order_details_section/create_account_widget.dart';
import 'package:demandium/feature/checkout/widget/order_details_section/provider_location_info.dart';
import 'package:demandium/feature/checkout/widget/order_details_section/inline_add_address_form.dart';
import 'package:demandium/feature/lead/controller/lead_controller.dart';
import 'package:demandium/utils/core_export.dart';
import 'package:get/get.dart';

class CustomerDetailsScreen extends StatefulWidget {
  final String? serviceName;
  final String? variantName;
  final double? totalPrice;

  const CustomerDetailsScreen({super.key, this.serviceName, this.variantName, this.totalPrice});

  @override
  State<CustomerDetailsScreen> createState() => _CustomerDetailsScreenState();
}

class _CustomerDetailsScreenState extends State<CustomerDetailsScreen> {
  final GlobalKey<InlineAddAddressFormState> _addressFormKey = GlobalKey<InlineAddAddressFormState>();
  bool _isEditingAddress = false;
  bool _basicInfoFilled = false;
  bool _isProceedingToCheckout = false;

  @override
  void initState() {
    super.initState();
    Get.find<LeadController>().resetLeadId();
    Get.find<LocationController>().updateSelectedServiceLocationType();
    Get.find<CartController>().getCartListFromServer();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'customer_details'.tr),
      body: GetBuilder<LocationController>(builder: (locationController) {
        return GetBuilder<CartController>(builder: (cartController) {
          bool isLoggedIn = Get.find<AuthController>().isLoggedIn();
          bool createGuestAccount = Get.find<SplashController>().configModel.content?.createGuestUserAccount == 1;
          AddressModel? addressModel = CheckoutHelper.selectedAddressModel(
              selectedAddress: locationController.selectedAddress, pickedAddress: locationController.getUserAddress());
          bool contactPersonInfoAvailable = addressModel != null && addressModel.contactPersonNumber != null && addressModel.contactPersonNumber != "";
          ProviderData? provider = cartController.cartList.isNotEmpty ? cartController.cartList.first.provider : null;

          bool allowChooseLocation = Get.find<SplashController>().configModel.content?.serviceAtProviderLocation == 1
              ? (provider == null ? true : (provider.serviceLocation?.length ?? 0) > 1)
              : false;

          if (!allowChooseLocation && provider != null && !(provider.serviceLocation?.contains("customer") ?? true)) {
            locationController.updateSelectedServiceLocationType(type: ServiceLocationType.provider, shouldUpdate: false);
          }

          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                  child: Column(
                    children: [
                      
                      // Booking Summary Header (Optional, for consistency)
                      Center(
                        child: Text(
                          "${Get.find<SplashController>().configModel.content?.businessName ?? "App"}'s Professional Cleaning Services",
                          style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeOverLarge, color: Theme.of(context).textTheme.bodyLarge!.color!.withValues(alpha: 0.7)),
                          textAlign: TextAlign.center,
                        ),
                      ),
                       const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                      Center(
                        child: Text(
                          "Get, Set, Clean – Your Spotless Space Awaits!",
                          style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeLarge, color: Theme.of(context).textTheme.bodyLarge!.color!.withValues(alpha: 0.5)),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: Dimensions.paddingSizeLarge),

                      Visibility(
                        visible: (locationController.selectedAddress != null && !_isEditingAddress) || _basicInfoFilled,
                        child: Column(
                          children: [
                            if(widget.serviceName != null && widget.serviceName!.isNotEmpty) ...[
                                   Column(
                                    children: [
                                      RichText(
                                        textAlign: TextAlign.center,
                                        text: TextSpan(
                                          style: robotoRegular.copyWith(color: Theme.of(context).textTheme.bodyLarge!.color, fontSize: Dimensions.fontSizeDefault),
                                          children: [
                                            const TextSpan(text: "You selected a "),
                                            TextSpan(text: widget.serviceName ?? "", style: robotoBold.copyWith(color: Theme.of(context).primaryColor)),
                                            const TextSpan(text: " service for "),
                                            TextSpan(text: widget.variantName ?? "", style: robotoBold),
                                            const TextSpan(text: "."),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: Dimensions.paddingSizeSmall),
                                      RichText(
                                         textAlign: TextAlign.center,
                                        text: TextSpan(
                                          style: robotoRegular.copyWith(color: Theme.of(context).textTheme.bodyLarge!.color, fontSize: Dimensions.fontSizeDefault),
                                          children: [
                                            const TextSpan(text: "Your price for the service after addons is "),
                                            TextSpan(text: PriceConverter.convertPrice(CheckoutHelper.calculateGrandTotal(cartList: cartController.cartList, referralDiscount: cartController.referralAmount)), style: robotoBold.copyWith(color: Theme.of(context).primaryColor)),
                                            const TextSpan(text: " including GST."),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                const SizedBox(height: Dimensions.paddingSizeLarge),
                            ] else if(cartController.cartList.isNotEmpty) ...[
                                (() {
                                  var cartItem = cartController.cartList.last;
                                  return Column(
                                    children: [
                                      RichText(
                                        textAlign: TextAlign.center,
                                        text: TextSpan(
                                          style: robotoRegular.copyWith(color: Theme.of(context).textTheme.bodyLarge!.color, fontSize: Dimensions.fontSizeDefault),
                                          children: [
                                            const TextSpan(text: "You selected a "),
                                            TextSpan(text: cartItem.service?.name ?? "", style: robotoBold.copyWith(color: Theme.of(context).primaryColor)),
                                            const TextSpan(text: " service for "),
                                            TextSpan(text: cartItem.variantKey ?? "", style: robotoBold),
                                            const TextSpan(text: "."),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: Dimensions.paddingSizeSmall),
                                      RichText(
                                         textAlign: TextAlign.center,
                                        text: TextSpan(
                                          style: robotoRegular.copyWith(color: Theme.of(context).textTheme.bodyLarge!.color, fontSize: Dimensions.fontSizeDefault),
                                          children: [
                                            const TextSpan(text: "Your price for the service after addons is "),
                                            TextSpan(text: PriceConverter.convertPrice(CheckoutHelper.calculateGrandTotal(cartList: cartController.cartList, referralDiscount: cartController.referralAmount)), style: robotoBold.copyWith(color: Theme.of(context).primaryColor)),
                                            const TextSpan(text: " including GST."),
                                          ],
                                        ),
                                      ),
                                    ],
                                  );
                                }()),
                                const SizedBox(height: Dimensions.paddingSizeLarge),
                            ],
                          ],
                        ),
                      ),

                       // Address / Location ("Take the service")
                       Column(
                          children: [
                            allowChooseLocation ? const ChooseServiceLocationWidget() : const SizedBox(),
                             if (locationController.selectedServiceLocationType == ServiceLocationType.customer)
                                 if (locationController.selectedAddress == null || _isEditingAddress)
                                   InlineAddAddressForm(
                                     key: _addressFormKey,
                                     address: locationController.selectedAddress,
                                   onSaveSuccess: () {
                                     if (_isProceedingToCheckout) {
                                       _isProceedingToCheckout = false;
                                       _proceedToCheckout(locationController.selectedAddress!);
                                     } else {
                                       setState(() {
                                         _isEditingAddress = false;
                                       });
                                     }
                                   },
                                   onBasicInfoValidityChanged: (valid) {
                                      setState(() {
                                        _basicInfoFilled = valid;
                                      });
                                   },
                                 )
                               else
                                 CustomerLocationInfo(
                                   provider: provider,
                                   onEdit: () {
                                     setState(() {
                                       _isEditingAddress = true;
                                     });
                                   },
                                 )
                             else
                               ProviderLocationInfo(provider: provider),
                            const SizedBox(height: Dimensions.paddingSizeDefault),
                            if (locationController.selectedServiceLocationType == ServiceLocationType.provider)
                              CustomerLocationInfo(provider: provider),
                          ],
                        ),

                      const SizedBox(height: Dimensions.paddingSizeDefault),
                      
                      // Customer Details / Create Account
                      if (!isLoggedIn && createGuestAccount && contactPersonInfoAvailable)
                        const CreateAccountWidget(),
                        
                      const SizedBox(height: Dimensions.paddingSizeLarge),  
                    ],
                  ),
                ),
              ),
              
              // Bottom Bar
             GetBuilder<CheckOutController>(builder: (checkoutController) {
               return Container(
                height: 70,
                padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  boxShadow: [BoxShadow(color: Colors.grey.withValues(alpha: 0.2), spreadRadius: 1, blurRadius: 10, offset: const Offset(0, 1))],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: CustomButton(
                        buttonText: 'Back'.tr,
                        onPressed: () => Get.back(),
                      ),
                    ),
                    const SizedBox(width: Dimensions.paddingSizeSmall), 
                    Expanded(
                      child: CustomButton(
                        buttonText: 'Next'.tr, 
                        isLoading: checkoutController.isLoading || locationController.isLoading,
                        onPressed: () {
                           _validateAndProceed(
                             checkoutController: checkoutController,
                             addressModel: addressModel,
                           );
                        },
                      ),
                    ),
                  ],
                ),
              );
             }),
            ],
          );
        });
      }),
    );
  }

  void _validateAndProceed({
    required CheckOutController checkoutController,
    required AddressModel? addressModel,
  }) {
    bool isLoggedIn = Get.find<AuthController>().isLoggedIn();
    bool createGuestAccount = Get.find<SplashController>().configModel.content?.createGuestUserAccount == 1;
    var locationController = Get.find<LocationController>();

    if(_isEditingAddress || locationController.selectedAddress == null){
      if(!_basicInfoFilled){
        customSnackBar('please_enter_valid_basic_info'.tr, type: ToasterMessageType.info);
        return;
      }
      _isProceedingToCheckout = true;
      _addressFormKey.currentState?.saveAddress(locationController);
      return;
    }

    if(addressModel == null){
      customSnackBar("add_address_first".tr, type: ToasterMessageType.info);
    }
    else if((addressModel.contactPersonName == "null" || addressModel.contactPersonName == null || addressModel.contactPersonName!.isEmpty) || (addressModel.contactPersonNumber=="null" || addressModel.contactPersonNumber == null || addressModel.contactPersonNumber!.isEmpty)){
      customSnackBar("please_input_contact_person_name_and_phone_number".tr, type: ToasterMessageType.info);
    } else if(checkoutController.isCheckedCreateAccount && checkoutController.passwordController.text.isEmpty){
      customSnackBar("please_input_new_account_password".tr, type: ToasterMessageType.info);
    }
    else if(checkoutController.isCheckedCreateAccount && checkoutController.confirmPasswordController.text.isEmpty){
      customSnackBar("please_input_confirm_password".tr, type: ToasterMessageType.info);
    }
    else if(checkoutController.isCheckedCreateAccount && checkoutController.confirmPasswordController.text != checkoutController.passwordController.text ){
      customSnackBar("confirm_password_does_not_matched".tr, type: ToasterMessageType.info);
    }
    else{
       // Additional check if creating account
       if(checkoutController.isCheckedCreateAccount && !isLoggedIn && createGuestAccount){
          checkoutController.checkExistingUser(phone: "${addressModel.contactPersonNumber}").then((value){
            if(!value){
              customSnackBar('phone_already_taken'.tr,type : ToasterMessageType.info);
            }else{
               _proceedToCheckout(addressModel);
            }
          });
        }else{
           _proceedToCheckout(addressModel);
        }
    }
  }

  void _proceedToCheckout(AddressModel addressModel) async {
       var cartController = Get.find<CartController>();
       var scheduleController = Get.find<ScheduleController>();

       String? serviceName = widget.serviceName;
       double totalAmount = cartController.totalPrice > 0 ? cartController.totalPrice : (widget.totalPrice ?? 0);
       int? quantity;
       String scheduleTime = "";

       if(scheduleController.selectedServiceType == ServiceType.regular) {
         scheduleTime = scheduleController.scheduleTime ?? "";
       } else {
         scheduleTime = "${scheduleController.selectedTime}"; 
       }

       String? categoryId;
       String? serviceId;
       String? variantKey;
       String? subCategoryId;
       String? zoneId = Get.find<LocationController>().getUserAddress()?.zoneId;

       var listToUse = (widget.serviceName != null && widget.serviceName!.isNotEmpty) ? cartController.initialCartList : (cartController.cartList.isNotEmpty ? cartController.cartList : cartController.initialCartList);
       if(listToUse.isNotEmpty){
         List<String> variants = [];
         
         for (int i = 0; i < listToUse.length; i++) {
           var item = listToUse[i];
           if (item.quantity > 0) {
             if (item.variantKey != null && item.variantKey!.isNotEmpty) {
               variants.add("${item.variantKey} x${item.quantity}");
             } else if (item.service?.name != null) {
               variants.add("${item.service!.name} x${item.quantity}");
             }
           }
         }
         
         variantKey = variants.join(',');
         serviceName = listToUse.first.service?.name;
         quantity = 1;
         
         categoryId = listToUse.first.categoryId;
         serviceId = listToUse.first.serviceId;
         subCategoryId = listToUse.first.subCategoryId;
         
         // Manually calculate total to be 100% sure
         double manualTotal = 0;
         for (var item in listToUse) {
           manualTotal += (item.serviceCost ?? 0) * (item.quantity ?? 1);
           manualTotal += (item.taxAmount ?? 0);
         }
         
         totalAmount = manualTotal > 0 ? manualTotal : cartController.totalPrice;

         print("--- LEAD DEBUG ---");
         print("Cart Count: ${cartController.cartList.length}");
         print("Service: $serviceName");
         print("Total: $totalAmount");
         print("Manual Total: $manualTotal");
         print("-----------------");
       }
       
       // Update basic info first to ensure IDs are there even if address fails
       Get.find<LeadController>().saveLeadBasicInfo(
         addressModel.contactPersonName ?? "", 
         addressModel.contactPersonNumber ?? "", 
         addressModel.email ?? "",
         serviceName: serviceName,
         scheduleTime: scheduleTime,
         totalAmount: totalAmount,
         quantity: quantity,
         categoryId: categoryId,
         serviceId: serviceId,
         variantKey: variantKey,
         zoneId: addressModel.zoneId ?? zoneId
       );

       // Then update address info
       Get.find<LeadController>().saveLeadAddress(
         addressModel, 
         serviceName: serviceName, 
         scheduleTime: scheduleTime, 
         totalAmount: totalAmount,
         quantity: quantity,
         categoryId: categoryId,
         serviceId: serviceId,
         variantKey: variantKey,
         subCategoryId: subCategoryId,
         zoneId: zoneId
       );
       
       Get.find<CheckOutController>().totalAmount = totalAmount;

       Get.dialog(const Center(child: CircularProgressIndicator()), barrierDismissible: false);
       
       if(cartController.cartList.isEmpty){
         Get.back();
         return;
       }

       Get.back();
       
       Get.find<LocationController>().updateSelectedAddress(addressModel);
       await Get.find<LocationController>().saveUserAddress(addressModel);
       Get.toNamed(RouteHelper.getCheckoutRoute('cart', 'payment', addressModel.id != null ? addressModel.id.toString() : 'null'));
  }
}
