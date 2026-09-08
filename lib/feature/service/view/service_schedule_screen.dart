import 'package:demandium/feature/checkout/widget/order_details_section/choose_service_location_widget.dart';
import 'package:demandium/feature/checkout/widget/order_details_section/inline_add_address_form.dart';
import 'package:demandium/feature/checkout/widget/order_details_section/provider_location_info.dart';
import 'package:demandium/feature/checkout/widget/order_details_section/customer_location_info.dart';
import 'package:demandium/feature/checkout/widget/order_details_section/create_account_widget.dart';
import 'package:demandium/feature/lead/controller/lead_controller.dart';
import 'package:demandium/utils/core_export.dart';
import 'package:get/get.dart';
import 'package:demandium/feature/checkout/widget/order_details_section/service_schedule.dart';

/// Unified single-page checkout: Schedule → Customer Details → Address
/// Each section reveals on "Next" with auto-scroll animation.
class ServiceScheduleScreen extends StatefulWidget {
  final String? serviceName;
  final String? variantName;
  final double? totalPrice;

  const ServiceScheduleScreen({super.key, this.serviceName, this.variantName, this.totalPrice});

  @override
  State<ServiceScheduleScreen> createState() => _ServiceScheduleScreenState();
}

enum _CheckoutStep { schedule, customerDetails }

class _ServiceScheduleScreenState extends State<ServiceScheduleScreen> {
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _scheduleKey = GlobalKey();
  final GlobalKey _customerDetailsKey = GlobalKey();
  final GlobalKey<InlineAddAddressFormState> _addressFormKey = GlobalKey<InlineAddAddressFormState>();

  _CheckoutStep _currentStep = _CheckoutStep.schedule;
  bool _isEditingAddress = false;
  bool _basicInfoFilled = false;
  bool _isProceedingToCheckout = false;

  @override
  void initState() {
    super.initState();
    Get.find<LeadController>().resetLeadId();
    Get.find<ScheduleController>().resetScheduleData(shouldUpdate: false);
    Get.find<CheckOutController>().resetCreateAccountWithExistingInfo();
    Get.find<CheckOutController>().toggleTerms(value: false, shouldUpdate: false);
    Get.find<ScheduleController>().resetSchedule();
    Get.find<LocationController>().updateSelectedServiceLocationType();
    Get.find<CartController>().getCartListFromServer();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToKey(GlobalKey key) {
    Future.delayed(const Duration(milliseconds: 300), () {
      final context = key.currentContext;
      if (context != null) {
        Scrollable.ensureVisible(
          context,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
          alignment: 0.0,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'booking_details'.tr),
      body: GetBuilder<LocationController>(builder: (locationController) {
        return GetBuilder<CartController>(builder: (cartController) {
          return GetBuilder<ScheduleController>(builder: (scheduleController) {

            bool isLoggedIn = Get.find<AuthController>().isLoggedIn();
            bool createGuestAccount = Get.find<SplashController>().configModel.content?.createGuestUserAccount == 1;
            var configModel = Get.find<SplashController>().configModel.content;
            AddressModel? addressModel = CheckoutHelper.selectedAddressModel(
                selectedAddress: locationController.selectedAddress, pickedAddress: locationController.getUserAddress());
            bool contactPersonInfoAvailable = addressModel != null && addressModel.contactPersonNumber != null && addressModel.contactPersonNumber != "";
            ProviderData? provider = cartController.cartList.isNotEmpty ? cartController.cartList.first.provider : null;

            bool allowChooseLocation = configModel?.serviceAtProviderLocation == 1
                ? (provider == null ? true : (provider.serviceLocation?.length ?? 0) > 1)
                : false;

            if (!allowChooseLocation && provider != null && !(provider.serviceLocation?.contains("customer") ?? true)) {
              locationController.updateSelectedServiceLocationType(type: ServiceLocationType.provider, shouldUpdate: false);
            }

            // Get price from Grand Total calculation
            double grandTotal = CheckoutHelper.calculateGrandTotal(
              cartList: cartController.cartList, 
              referralDiscount: cartController.referralAmount,
            );

            var cartItem = cartController.cartList.isNotEmpty ? cartController.cartList.first : null;
            String serviceName = widget.serviceName ?? cartItem?.service?.name ?? "Service";
            String variantName = widget.variantName ?? cartItem?.variantKey ?? "";

            return Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                        // ===== HEADER =====
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

                        // Service Info
                        if(serviceName.isNotEmpty) ...[
                          RichText(
                            textAlign: TextAlign.center,
                            text: TextSpan(
                              style: robotoRegular.copyWith(color: Theme.of(context).textTheme.bodyLarge!.color, fontSize: Dimensions.fontSizeDefault),
                              children: [
                                const TextSpan(text: "You selected a "),
                                TextSpan(text: serviceName, style: robotoBold.copyWith(color: Theme.of(context).primaryColor)),
                                const TextSpan(text: " service for "),
                                TextSpan(text: variantName, style: robotoBold),
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
                                TextSpan(text: PriceConverter.convertPrice(grandTotal), style: robotoBold.copyWith(color: Theme.of(context).primaryColor)),
                                const TextSpan(text: " including GST."),
                              ],
                            ),
                          ),
                          const SizedBox(height: Dimensions.paddingSizeLarge),
                        ],

                        // ===== SECTION 1: SCHEDULE =====
                        Container(
                          key: _scheduleKey,
                          decoration: BoxDecoration(
                            color: Theme.of(context).cardColor,
                            borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                            border: Border.all(color: Theme.of(context).hintColor.withValues(alpha: 0.3)),
                          ),
                          padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(
                                    radius: 14,
                                    backgroundColor: Theme.of(context).primaryColor,
                                    child: const Text("1", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                                  ),
                                  const SizedBox(width: 10),
                                  Text("Schedule Your Service", style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge)),
                                ],
                              ),
                              const SizedBox(height: Dimensions.paddingSizeDefault),
                              const ServiceSchedule(),
                            ],
                          ),
                        ),

                        const SizedBox(height: Dimensions.paddingSizeLarge),

                        // ===== SECTION 2: CUSTOMER DETAILS + ADDRESS =====
                        if (_currentStep.index >= _CheckoutStep.customerDetails.index) ...[
                          Container(
                            key: _customerDetailsKey,
                            decoration: BoxDecoration(
                              color: Theme.of(context).cardColor,
                              borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                              border: Border.all(color: Theme.of(context).hintColor.withValues(alpha: 0.3)),
                            ),
                            padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 14,
                                      backgroundColor: Theme.of(context).primaryColor,
                                      child: const Text("2", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                                    ),
                                    const SizedBox(width: 10),
                                    Text("Your Details & Address", style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge)),
                                  ],
                                ),
                                const SizedBox(height: Dimensions.paddingSizeDefault),

                                // Address Section
                                allowChooseLocation ? const ChooseServiceLocationWidget() : const SizedBox(),
                                if (locationController.selectedServiceLocationType == ServiceLocationType.customer)
                                  if (locationController.selectedAddress == null || _isEditingAddress)
                                    InlineAddAddressForm(
                                      key: _addressFormKey,
                                      address: locationController.selectedAddress,
                                      onSaveSuccess: () {
                                        if (_isProceedingToCheckout) {
                                          _isProceedingToCheckout = false;
                                          _proceedToPayment(locationController.selectedAddress!);
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

                                // Create Account option
                                if (!isLoggedIn && createGuestAccount && contactPersonInfoAvailable)
                                  const CreateAccountWidget(),
                              ],
                            ),
                          ),
                          const SizedBox(height: Dimensions.paddingSizeLarge),
                        ],

                        const SizedBox(height: 80), // Space for bottom bar
                      ],
                    ),
                  ),
                ),

                // ===== BOTTOM BAR =====
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
                            onPressed: () {
                              if (_currentStep == _CheckoutStep.customerDetails) {
                                setState(() {
                                  _currentStep = _CheckoutStep.schedule;
                                });
                                _scrollToKey(_scheduleKey);
                              } else {
                                Get.back();
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: Dimensions.paddingSizeSmall),
                        Expanded(
                          child: CustomButton(
                            buttonText: _currentStep == _CheckoutStep.customerDetails ? 'Next'.tr : 'Next'.tr,
                            isLoading: checkoutController.isLoading || locationController.isLoading,
                            onPressed: () {
                              if (_currentStep == _CheckoutStep.schedule) {
                                _validateScheduleAndProceed(
                                  scheduleController: scheduleController,
                                  configModel: configModel!,
                                );
                              } else if (_currentStep == _CheckoutStep.customerDetails) {
                                _validateDetailsAndProceed(
                                  checkoutController: checkoutController,
                                  addressModel: addressModel,
                                );
                              }
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
        });
      }),
    );
  }

  // Step 1: Validate Schedule → show Customer Details
  void _validateScheduleAndProceed({
    required ScheduleController scheduleController,
    required ConfigContent configModel,
  }) {
    String? schedule = scheduleController.scheduleTime;

    if (schedule == null && scheduleController.selectedScheduleType != ScheduleType.asap && scheduleController.selectedServiceType == ServiceType.regular) {
      customSnackBar("select_your_preferable_booking_time".tr, type: ToasterMessageType.info);
    } else if (scheduleController.selectedScheduleType == ScheduleType.schedule
        && configModel.scheduleBookingTimeRestriction == 1
        && scheduleController.checkValidityOfTimeRestriction(configModel.advanceBooking!) != null
        && scheduleController.selectedServiceType == ServiceType.regular) {
      customSnackBar(scheduleController.checkValidityOfTimeRestriction(configModel.advanceBooking!));
    } else {
      setState(() {
        _currentStep = _CheckoutStep.customerDetails;
      });
      _scrollToKey(_customerDetailsKey);
    }
  }

  // Step 2: Validate Customer Details → Proceed to Payment
  void _validateDetailsAndProceed({
    required CheckOutController checkoutController,
    required AddressModel? addressModel,
  }) {
    bool isLoggedIn = Get.find<AuthController>().isLoggedIn();
    bool createGuestAccount = Get.find<SplashController>().configModel.content?.createGuestUserAccount == 1;
    var locationController = Get.find<LocationController>();

    if (_isEditingAddress || locationController.selectedAddress == null) {
      if (!_basicInfoFilled) {
        customSnackBar('please_enter_valid_basic_info'.tr, type: ToasterMessageType.info);
        return;
      }
      _isProceedingToCheckout = true;
      _addressFormKey.currentState?.saveAddress(locationController);
      return;
    }

    if (addressModel == null) {
      customSnackBar("add_address_first".tr, type: ToasterMessageType.info);
    } else if ((addressModel.contactPersonName == "null" || addressModel.contactPersonName == null || addressModel.contactPersonName!.isEmpty) ||
        (addressModel.contactPersonNumber == "null" || addressModel.contactPersonNumber == null || addressModel.contactPersonNumber!.isEmpty)) {
      customSnackBar("please_input_contact_person_name_and_phone_number".tr, type: ToasterMessageType.info);
    } else if (checkoutController.isCheckedCreateAccount && checkoutController.passwordController.text.isEmpty) {
      customSnackBar("please_input_new_account_password".tr, type: ToasterMessageType.info);
    } else if (checkoutController.isCheckedCreateAccount && checkoutController.confirmPasswordController.text.isEmpty) {
      customSnackBar("please_input_confirm_password".tr, type: ToasterMessageType.info);
    } else if (checkoutController.isCheckedCreateAccount && checkoutController.confirmPasswordController.text != checkoutController.passwordController.text) {
      customSnackBar("confirm_password_does_not_matched".tr, type: ToasterMessageType.info);
    } else {
      if (checkoutController.isCheckedCreateAccount && !isLoggedIn && createGuestAccount) {
        checkoutController.checkExistingUser(phone: "${addressModel.contactPersonNumber}").then((value) {
          if (!value) {
            customSnackBar('phone_already_taken'.tr, type: ToasterMessageType.info);
          } else {
            _proceedToPayment(addressModel);
          }
        });
      } else {
        _proceedToPayment(addressModel);
      }
    }
  }

  void _proceedToPayment(AddressModel addressModel) async {
    var cartController = Get.find<CartController>();
    var scheduleController = Get.find<ScheduleController>();

    double totalAmount = CheckoutHelper.calculateGrandTotal(
      cartList: cartController.cartList,
      referralDiscount: cartController.referralAmount,
    );

    String? serviceName = widget.serviceName;
    int? quantity;
    String scheduleTime = "";

    if (scheduleController.selectedServiceType == ServiceType.regular) {
      scheduleTime = scheduleController.scheduleTime ?? "";
    } else {
      scheduleTime = "${scheduleController.selectedTime}";
    }

    if ((serviceName == null || serviceName.isEmpty) && cartController.cartList.isNotEmpty) {
      serviceName = cartController.cartList.first.service?.name;
      quantity = cartController.cartList.first.quantity;
    }

    Get.find<LeadController>().saveLeadAddress(
      addressModel,
      serviceName: serviceName,
      scheduleTime: scheduleTime,
      totalAmount: totalAmount,
      quantity: quantity,
    );

    Get.find<CheckOutController>().totalAmount = totalAmount;

    Get.dialog(const Center(child: CircularProgressIndicator()), barrierDismissible: false);

    if (cartController.cartList.isEmpty) {
      Get.back();
      return;
    }

    Get.back();

    Get.find<LocationController>().updateSelectedAddress(addressModel);
    await Get.find<LocationController>().saveUserAddress(addressModel);
    Get.toNamed(RouteHelper.getCheckoutRoute('cart', 'payment', addressModel.id != null ? addressModel.id.toString() : 'null'));
  }
}
