import 'package:demandium/feature/checkout/widget/order_details_section/choose_service_location_widget.dart';
import 'package:demandium/feature/checkout/widget/order_details_section/inline_add_address_form.dart';
import 'package:demandium/feature/checkout/widget/order_details_section/provider_location_info.dart';
import 'package:demandium/feature/checkout/widget/order_details_section/customer_location_info.dart';
import 'package:demandium/feature/checkout/widget/order_details_section/create_account_widget.dart';
import 'package:demandium/feature/checkout/widget/order_details_section/service_schedule.dart';
import 'package:demandium/feature/lead/controller/lead_controller.dart';
import 'package:get/get.dart';
import 'package:demandium/utils/core_export.dart';

/// Unified single-page flow:
/// 1) Addons → Next → auto-scroll
/// 2) Schedule Time → Next → auto-scroll
/// 3) Customer Details & Address → Proceed to Payment
class ServiceDetailsScreen extends StatefulWidget {
  final String? serviceID;
  final String? fromPage;
  const ServiceDetailsScreen({super.key, this.serviceID, this.fromPage = "others"});

  @override
  State<ServiceDetailsScreen> createState() => _ServiceDetailsScreenState();
}

enum _FlowStep { addons, schedule, customerDetails }

class _ServiceDetailsScreenState extends State<ServiceDetailsScreen> {
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _addonsKey = GlobalKey();
  final GlobalKey _scheduleKey = GlobalKey();
  final GlobalKey _customerDetailsKey = GlobalKey();
  final GlobalKey<InlineAddAddressFormState> _addressFormKey = GlobalKey<InlineAddAddressFormState>();

  _FlowStep _currentStep = _FlowStep.addons;
  bool _isEditingAddress = false;
  bool _basicInfoFilled = false;
  bool _isProceedingToCheckout = false;
  bool _cartReady = false;

  @override
  void initState() {
    super.initState();
    Get.find<LeadController>().resetLeadId();
    if (widget.serviceID != null) {
      Get.find<ServiceDetailsController>().getServiceDetails(widget.serviceID!, fromPage: widget.fromPage == "search_page" ? "search_page" : "");
      if (Get.find<AuthController>().isLoggedIn()) {
        Get.find<ServiceController>().getRecentlyViewedServiceList(1, true);
      }
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToKey(GlobalKey key) {
    Future.delayed(const Duration(milliseconds: 300), () {
      final ctx = key.currentContext;
      if (ctx != null) {
        Scrollable.ensureVisible(
          ctx,
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
      appBar: CustomAppBar(centerTitle: false, title: 'service_details'.tr, showCart: true),
      body: GetBuilder<ServiceDetailsController>(builder: (serviceController) {
        if (serviceController.service == null && widget.serviceID != null) {
          return const ServiceDetailsShimmerWidget();
        }
        if (serviceController.service == null || serviceController.service!.id == null) {
          return NoDataScreen(text: 'no_service_available'.tr, type: NoDataType.service);
        }

        Service service = serviceController.service!;

        return GetBuilder<CartController>(builder: (cartController) {
          return GetBuilder<LocationController>(builder: (locationController) {
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

              // Price calculation
              double basePrice = service.minBiddingPrice ?? 0;
              double baseTax = (service.tax ?? 0) > 0 ? (basePrice * service.tax! / 100) : 0;
              double addonsPrice = cartController.initialCartList.fold(0, (sum, item) => sum + (item.variantKey == 'base_service' ? 0 : (item.serviceCost * item.quantity)));
              double addonsTax = cartController.initialCartList.fold(0, (sum, item) => sum + (item.variantKey == 'base_service' ? 0 : item.taxAmount));
              double currentTotalPrice = basePrice + baseTax + addonsPrice + addonsTax;

              // Use grand total if cart is ready
              double grandTotal = _cartReady
                  ? CheckoutHelper.calculateGrandTotal(cartList: cartController.cartList, referralDiscount: cartController.referralAmount)
                  : currentTotalPrice;

              return Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      controller: _scrollController,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: Dimensions.paddingSizeDefault),

                            // ===== STEP 1: ADDONS (ServiceOverview) =====
                            Container(
                              key: _addonsKey,
                              decoration: BoxDecoration(
                                color: Theme.of(context).cardColor,
                                borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                                border: Border.all(color: Theme.of(context).hintColor.withValues(alpha: 0.2)),
                              ),
                              padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildStepHeader(context, "1", "Select Your Addons", _currentStep.index >= _FlowStep.addons.index),
                                  const SizedBox(height: Dimensions.paddingSizeDefault),
                                  ServiceOverview(service: service),
                                ],
                              ),
                            ),

                            const SizedBox(height: Dimensions.paddingSizeLarge),

                            // ===== STEP 2: SCHEDULE =====
                            if (_currentStep.index >= _FlowStep.schedule.index) ...[
                              Container(
                                key: _scheduleKey,
                                decoration: BoxDecoration(
                                  color: Theme.of(context).cardColor,
                                  borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                                  border: Border.all(color: Theme.of(context).hintColor.withValues(alpha: 0.2)),
                                ),
                                padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildStepHeader(context, "2", "Schedule Your Service", true),
                                    const SizedBox(height: Dimensions.paddingSizeDefault),
                                    // Price info
                                    RichText(
                                      text: TextSpan(
                                        style: robotoRegular.copyWith(color: Theme.of(context).textTheme.bodyLarge!.color, fontSize: Dimensions.fontSizeDefault),
                                        children: [
                                          const TextSpan(text: "Your price: "),
                                          TextSpan(text: PriceConverter.convertPrice(grandTotal), style: robotoBold.copyWith(color: Theme.of(context).primaryColor)),
                                          const TextSpan(text: " including GST."),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: Dimensions.paddingSizeDefault),
                                    const ServiceSchedule(),
                                  ],
                                ),
                              ),
                              const SizedBox(height: Dimensions.paddingSizeLarge),
                            ],

                            // ===== STEP 3: CUSTOMER DETAILS + ADDRESS =====
                            if (_currentStep.index >= _FlowStep.customerDetails.index) ...[
                              Container(
                                key: _customerDetailsKey,
                                decoration: BoxDecoration(
                                  color: Theme.of(context).cardColor,
                                  borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                                  border: Border.all(color: Theme.of(context).hintColor.withValues(alpha: 0.2)),
                                ),
                                padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildStepHeader(context, "3", "Your Details & Address", true),
                                    const SizedBox(height: Dimensions.paddingSizeDefault),

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
                                              setState(() { _isEditingAddress = false; });
                                            }
                                          },
                                          onBasicInfoValidityChanged: (valid) {
                                            setState(() { _basicInfoFilled = valid; });
                                          },
                                        )
                                      else
                                        CustomerLocationInfo(
                                          provider: provider,
                                          onEdit: () { setState(() { _isEditingAddress = true; }); },
                                        )
                                    else
                                      ProviderLocationInfo(provider: provider),

                                    const SizedBox(height: Dimensions.paddingSizeDefault),
                                    if (locationController.selectedServiceLocationType == ServiceLocationType.provider)
                                      CustomerLocationInfo(provider: provider),

                                    if (!isLoggedIn && createGuestAccount && contactPersonInfoAvailable)
                                      const CreateAccountWidget(),
                                  ],
                                ),
                              ),
                              const SizedBox(height: Dimensions.paddingSizeLarge),
                            ],

                            const SizedBox(height: 80),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // ===== BOTTOM BAR =====
                  GetBuilder<CheckOutController>(builder: (checkoutController) {
                    return Container(
                      height: 80,
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
                                if (_currentStep == _FlowStep.customerDetails) {
                                  setState(() { _currentStep = _FlowStep.schedule; });
                                  _scrollToKey(_scheduleKey);
                                } else if (_currentStep == _FlowStep.schedule) {
                                  setState(() { _currentStep = _FlowStep.addons; _cartReady = false; });
                                  _scrollToKey(_addonsKey);
                                } else {
                                  Get.back();
                                }
                              },
                            ),
                          ),
                          const SizedBox(width: Dimensions.paddingSizeDefault),
                          Expanded(
                            child: CustomButton(
                              buttonText: _currentStep == _FlowStep.customerDetails
                                  ? 'Next'.tr
                                  : 'Next'.tr,
                              isLoading: checkoutController.isLoading || locationController.isLoading,
                              onPressed: () {
                                if (_currentStep == _FlowStep.addons) {
                                  _onAddonsNext(cartController, service);
                                } else if (_currentStep == _FlowStep.schedule) {
                                  _onScheduleNext(scheduleController, configModel!);
                                } else if (_currentStep == _FlowStep.customerDetails) {
                                  _onDetailsNext(checkoutController, addressModel);
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
        });
      }),
    );
  }

  Widget _buildStepHeader(BuildContext context, String number, String title, bool active) {
    return Row(
      children: [
        CircleAvatar(
          radius: 14,
          backgroundColor: active ? Theme.of(context).primaryColor : Theme.of(context).hintColor,
          child: Text(number, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
        ),
        const SizedBox(width: 10),
        Text(title, style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge)),
      ],
    );
  }

  // Step 1: Addons → add to cart → show Schedule
  void _onAddonsNext(CartController cartController, Service service) async {
    var selectedItems = cartController.initialCartList.where((e) => e.quantity > 0).toList();

    if (selectedItems.isEmpty && cartController.initialCartList.isNotEmpty) {
      // Find the base variant which is usually the one with $0 cost
      int baseServiceIndex = cartController.initialCartList.indexWhere((item) => item.serviceCost == 0);
      
      if (baseServiceIndex != -1) {
        cartController.initialCartList[baseServiceIndex].quantity = 1;
        selectedItems = [cartController.initialCartList[baseServiceIndex]];
      } else {
        // Create a dummy base service cart model to satisfy the backend
        var firstItem = cartController.initialCartList.first;
        var baseService = CartModel(
          firstItem.serviceId,
          firstItem.serviceId,
          firstItem.categoryId,
          firstItem.subCategoryId,
          'base_service', // Special key supported by backend
          0, // $0 cost
          1, // Quantity 1
          0, 0, 0, 0, "", 0, 0, 0,
          firstItem.service!,
        );
        cartController.initialCartList.add(baseService);
        selectedItems = [baseService];
      }
    }

    if (selectedItems.isNotEmpty) {
      await cartController.addMultipleCartToServer(providerId: cartController.selectedProvider?.id ?? "", onlyAddCurrentService: true);
      await cartController.getCartListFromServer(shouldUpdate: true);
    }



    // Init schedule controllers
    Get.find<ScheduleController>().resetScheduleData(shouldUpdate: false);
    Get.find<CheckOutController>().resetCreateAccountWithExistingInfo();
    Get.find<CheckOutController>().toggleTerms(value: false, shouldUpdate: false);
    Get.find<ScheduleController>().resetSchedule();
    Get.find<LocationController>().updateSelectedServiceLocationType();

    setState(() {
      _currentStep = _FlowStep.schedule;
      _cartReady = true;
    });
    _scrollToKey(_scheduleKey);
  }

  // Step 2: Schedule → validate → show Customer Details
  void _onScheduleNext(ScheduleController scheduleController, ConfigContent configModel) {
    String? schedule = scheduleController.scheduleTime;

    if (schedule == null && scheduleController.selectedScheduleType != ScheduleType.asap && scheduleController.selectedServiceType == ServiceType.regular) {
      customSnackBar("select_your_preferable_booking_time".tr, type: ToasterMessageType.info);
    } else if (scheduleController.selectedScheduleType == ScheduleType.schedule
        && configModel.scheduleBookingTimeRestriction == 1
        && scheduleController.checkValidityOfTimeRestriction(configModel.advanceBooking!) != null
        && scheduleController.selectedServiceType == ServiceType.regular) {
      customSnackBar(scheduleController.checkValidityOfTimeRestriction(configModel.advanceBooking!));
    } else {
      Get.find<CartController>().getCartListFromServer(shouldUpdate: true);
      setState(() { _currentStep = _FlowStep.customerDetails; });
      _scrollToKey(_customerDetailsKey);
    }
  }

  // Step 3: Customer Details → validate → Payment
  void _onDetailsNext(CheckOutController checkoutController, AddressModel? addressModel) {
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

    String? serviceName = cartController.cartList.isNotEmpty ? cartController.cartList.first.service?.name : null;
    int? quantity = cartController.cartList.isNotEmpty ? cartController.cartList.first.quantity : null;

    String scheduleTime = "";
    if (scheduleController.selectedServiceType == ServiceType.regular) {
      scheduleTime = scheduleController.scheduleTime ?? "";
    } else {
      scheduleTime = "${scheduleController.selectedTime}";
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
