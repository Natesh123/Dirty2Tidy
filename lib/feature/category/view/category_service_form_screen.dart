import 'package:demandium/feature/checkout/widget/order_details_section/choose_service_location_widget.dart';
import 'package:demandium/feature/checkout/widget/order_details_section/inline_add_address_form.dart';
import 'package:demandium/feature/checkout/widget/order_details_section/provider_location_info.dart';
import 'package:demandium/feature/checkout/widget/order_details_section/customer_location_info.dart';
import 'package:demandium/feature/checkout/widget/order_details_section/create_account_widget.dart';
import 'package:demandium/feature/checkout/widget/order_details_section/service_schedule.dart';
import 'package:demandium/feature/lead/controller/lead_controller.dart';
import 'package:demandium/feature/service/widget/service_overview.dart';
import 'package:get/get.dart';
import 'package:demandium/utils/core_export.dart';

/// Unified single-page booking flow:
/// Step 1: Select Service (dropdown)
/// Step 2: Addons (service variants/extras)
/// Step 3: Schedule Time
/// Step 4: Customer Details & Address → Payment page
class CategoryServiceFormScreen extends StatefulWidget {
  final String categoryId;
  final String categoryName;
  final String? categoryImage;

  const CategoryServiceFormScreen({
    Key? key,
    required this.categoryId,
    required this.categoryName,
    this.categoryImage,
  }) : super(key: key);

  @override
  State<CategoryServiceFormScreen> createState() => _CategoryServiceFormScreenState();
}

enum _FlowStep { selectService, addons, schedule, customerDetails }

class _CategoryServiceFormScreenState extends State<CategoryServiceFormScreen> {
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _serviceSelectKey = GlobalKey();
  final GlobalKey _addonsKey = GlobalKey();
  final GlobalKey _scheduleKey = GlobalKey();
  final GlobalKey _customerDetailsKey = GlobalKey();
  final GlobalKey<InlineAddAddressFormState> _addressFormKey = GlobalKey<InlineAddAddressFormState>();

  _FlowStep _currentStep = _FlowStep.selectService;
  String? _selectedServiceId;
  String? _selectedZoneId;
  bool _isEditingAddress = false;
  bool _basicInfoFilled = false;
  bool _isProceedingToCheckout = false;
  bool _cartReady = false;

  @override
  void initState() {
    super.initState();
    Get.find<LeadController>().resetLeadId();
    Get.find<ServiceAreaController>().getZoneList();
    // Delay fetching services until a city is selected, or if user already has a zone, fetch it
    String? existingZoneId = Get.find<LocationController>().getUserAddress()?.zoneId;
    if (existingZoneId != null && existingZoneId.isNotEmpty) {
      _selectedZoneId = existingZoneId;
      Get.find<ServiceController>().getAllServiceList(1, true, categoryId: widget.categoryId);
    }

    Get.find<ScheduleController>().resetScheduleData(shouldUpdate: false);
    Get.find<CheckOutController>().resetCreateAccountWithExistingInfo();
    Get.find<CheckOutController>().toggleTerms(value: false, shouldUpdate: false);
    Get.find<ScheduleController>().resetSchedule();
    Get.find<LocationController>().updateSelectedServiceLocationType();
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

  Widget _buildStepHeader(BuildContext context, String number, String title, bool active) {
    return Row(
      children: [
        CircleAvatar(
          radius: 14,
          backgroundColor: active ? Theme.of(context).primaryColor : Theme.of(context).hintColor,
          child: Text(number, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
        ),
        const SizedBox(width: 10),
        Expanded(child: Text(title, style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge))),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: widget.categoryName),
      body: GetBuilder<ServiceController>(builder: (serviceController) {
        return GetBuilder<ServiceDetailsController>(builder: (serviceDetailsController) {
          return GetBuilder<CartController>(builder: (cartController) {
            return GetBuilder<LocationController>(builder: (locationController) {
              return GetBuilder<ScheduleController>(builder: (scheduleController) {
                return GetBuilder<CheckOutController>(builder: (checkoutController) {

                  final services = serviceController.allService;
                  Service? selectedService = serviceDetailsController.service;

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

                  // Price (Manual calculation as requested: Service + Addons)
                  double manualAddonTotal = 0;
                  for (var cart in cartController.initialCartList) {
                    if (cart.variantKey != 'base_service') {
                      manualAddonTotal += (cart.serviceCost * cart.quantity);
                    }
                  }
                  double grandTotal = (selectedService?.minBiddingPrice ?? 0) + manualAddonTotal - cartController.referralAmount;
                  if (grandTotal < 0) grandTotal = 0;

                  // Update CheckoutController with the manual total for the next page
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    Get.find<CheckOutController>().totalAmount = grandTotal;
                  });

                  return Column(
                    children: [
                      // ===== SCROLLABLE CONTENT =====
                      Expanded(
                        child: serviceController.isLoading
                            ? const Center(child: CircularProgressIndicator())
                            : SingleChildScrollView(
                                controller: _scrollController,
                                padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [

                                    // Header image
                                    if (widget.categoryImage != null && widget.categoryImage!.isNotEmpty)
                                      Container(
                                        margin: const EdgeInsets.only(bottom: Dimensions.paddingSizeLarge),
                                        width: double.infinity,
                                        height: ResponsiveHelper.isDesktop(context) ? 300 : 200,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                                          color: Theme.of(context).cardColor,
                                        ),
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                                          child: CustomImage(
                                            image: widget.categoryImage!,
                                            fit: BoxFit.cover,
                                            height: 300,
                                            width: double.infinity,
                                          ),
                                        ),
                                      ),

                                    // ===== STEP 1: SELECT SERVICE =====
                                    Container(
                                      key: _serviceSelectKey,
                                      decoration: BoxDecoration(
                                        color: Theme.of(context).cardColor,
                                        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                                        border: Border.all(color: Theme.of(context).hintColor.withValues(alpha: 0.2)),
                                      ),
                                      padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          _buildStepHeader(context, "1", "Select City & Category in ${widget.categoryName}", true),
                                          const SizedBox(height: Dimensions.paddingSizeDefault),
                                          
                                          // ===== SELECT CITY DROPDOWN =====
                                          GetBuilder<ServiceAreaController>(builder: (serviceAreaController) {
                                            bool isZoneLoading = serviceAreaController.zoneList == null;
                                            return Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Padding(
                                                  padding: const EdgeInsets.only(left: 4.0),
                                                  child: Text("Select City", style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge)),
                                                ),
                                                const SizedBox(height: Dimensions.paddingSizeSmall),
                                                Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
                                                  decoration: BoxDecoration(
                                                    borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                                                    border: Border.all(color: Theme.of(context).primaryColor.withValues(alpha: 0.3)),
                                                  ),
                                                  child: isZoneLoading 
                                                    ? const Center(child: Padding(padding: EdgeInsets.all(8.0), child: CircularProgressIndicator()))
                                                    : DropdownButtonHideUnderline(
                                                      child: DropdownButton<String>(
                                                        isExpanded: true,
                                                        hint: const Text("Select your city"),
                                                        value: _selectedZoneId != null && serviceAreaController.zoneList!.any((z) => z.id == _selectedZoneId) ? _selectedZoneId : null,
                                                        items: serviceAreaController.zoneList?.map((zone) {
                                                          return DropdownMenuItem<String>(
                                                            value: zone.id,
                                                            child: Text(zone.name ?? "Unknown City"),
                                                          );
                                                        }).toList() ?? [],
                                                        onChanged: (val) {
                                                          if(val != null) {
                                                            setState(() {
                                                              _selectedZoneId = val;
                                                              _selectedServiceId = null;
                                                              _currentStep = _FlowStep.selectService;
                                                              _cartReady = false;
                                                            });
                                                            Get.find<LocationController>().setTemporaryZone(val);
                                                            Get.find<ServiceController>().getAllServiceList(1, true, categoryId: widget.categoryId);
                                                            Get.find<CartController>().clearCartData();
                                                          }
                                                        },
                                                      ),
                                                    ),
                                                ),
                                              ],
                                            );
                                          }),
                                          const SizedBox(height: Dimensions.paddingSizeLarge),

                                          // ===== SELECT SERVICE DROPDOWN =====
                                          Padding(
                                            padding: const EdgeInsets.only(left: 4.0),
                                            child: Text("Select Category", style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge)),
                                          ),
                                          const SizedBox(height: Dimensions.paddingSizeSmall),
                                          if (_selectedZoneId == null)
                                            Container(
                                              width: double.infinity,
                                              padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                                              decoration: BoxDecoration(
                                                color: Theme.of(context).disabledColor.withValues(alpha: 0.1),
                                                borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                                                border: Border.all(color: Theme.of(context).disabledColor.withValues(alpha: 0.2)),
                                              ),
                                              child: const Text("Please select a city first", style: TextStyle(color: Colors.grey)),
                                            )
                                          else if (services == null || services.isEmpty)
                                            Center(child: Text('no_services_found'.tr))
                                          else
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
                                              decoration: BoxDecoration(
                                                borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                                                border: Border.all(color: Theme.of(context).primaryColor.withValues(alpha: 0.3)),
                                              ),
                                              child: DropdownButtonHideUnderline(
                                                child: DropdownButton<String>(
                                                  isExpanded: true,
                                                  menuMaxHeight: 300,
                                                  hint: const Text("Select a Category"),
                                                  value: _selectedServiceId,
                                                  items: services.map((service) {
                                                    return DropdownMenuItem<String>(
                                                      value: service.id,
                                                      child: Row(
                                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                        children: [
                                                          Expanded(child: Text(service.name ?? "Unknown Service", overflow: TextOverflow.ellipsis)),
                                                          const SizedBox(width: Dimensions.paddingSizeSmall),
                                                          ClipRRect(
                                                            borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                                                            child: CustomImage(
                                                              image: service.thumbnailFullPath ?? "",
                                                              height: 30, width: 30, fit: BoxFit.cover,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    );
                                                  }).toList(),
                                                  onChanged: (newValue) {
                                                    if (newValue != null) {
                                                      setState(() {
                                                        _selectedServiceId = newValue;
                                                        _currentStep = _FlowStep.selectService;
                                                        _cartReady = false;
                                                      });
                                                      // Load service details → addons visible
                                                      Get.find<ServiceDetailsController>().getServiceDetails(newValue);
                                                      Get.find<CartController>().clearCartData();
                                                      // Show addons section after details load
                                                      Future.delayed(const Duration(milliseconds: 600), () {
                                                        setState(() { _currentStep = _FlowStep.addons; });
                                                        _scrollToKey(_addonsKey);
                                                      });
                                                    }
                                                  },
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),

                                    const SizedBox(height: Dimensions.paddingSizeLarge),

                                    // ===== STEP 2: ADDONS =====
                                    if (_currentStep.index >= _FlowStep.addons.index && selectedService != null) ...[
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
                                            Padding(
                                              padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                                              child: _buildStepHeader(context, "2", "Select Your Addons", true),
                                            ),
                                            const SizedBox(height: Dimensions.paddingSizeSmall),
                                            serviceDetailsController.isLoading
                                                ? const Center(child: Padding(padding: EdgeInsets.all(32), child: CircularProgressIndicator()))
                                                : ServiceOverview(service: selectedService),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: Dimensions.paddingSizeLarge),
                                    ],

                                    // ===== STEP 3: SCHEDULE =====
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
                                            _buildStepHeader(context, "3", "Schedule Your Service", true),
                                            const SizedBox(height: Dimensions.paddingSizeDefault),
                                            const ServiceSchedule(),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: Dimensions.paddingSizeLarge),
                                    ],

                                    // ===== STEP 4: CUSTOMER DETAILS + ADDRESS =====
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
                                            _buildStepHeader(context, "4", "Your Details & Address", true),
                                            const SizedBox(height: Dimensions.paddingSizeDefault),

                                            if ((locationController.selectedAddress == null || _isEditingAddress) ? _basicInfoFilled : (isLoggedIn || (addressModel != null && addressModel.contactPersonNumber != null && addressModel.email != null && addressModel.email!.isNotEmpty)))
                                            Padding(
                                              padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall, vertical: Dimensions.paddingSizeDefault),
                                              child: Container(
                                                width: double.infinity,
                                                padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                                                decoration: BoxDecoration(
                                                  color: Theme.of(context).primaryColor.withValues(alpha: 0.05),
                                                  borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                                                  border: Border.all(color: Theme.of(context).primaryColor.withValues(alpha: 0.1)),
                                                ),
                                                child: RichText(
                                                  textAlign: TextAlign.center,
                                                  text: TextSpan(
                                                    style: robotoRegular.copyWith(color: Theme.of(context).textTheme.bodyLarge!.color, fontSize: Dimensions.fontSizeDefault),
                                                    children: [
                                                      TextSpan(text: "Total Payable: ", style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge)),
                                                      TextSpan(text: PriceConverter.convertPrice(grandTotal), style: robotoBold.copyWith(color: Theme.of(context).primaryColor, fontSize: 24)),
                                                      const TextSpan(text: "\n(Final Price including GST)"),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(height: Dimensions.paddingSizeDefault),
                                            allowChooseLocation ? const ChooseServiceLocationWidget() : const SizedBox(),
                                            if (locationController.selectedServiceLocationType == ServiceLocationType.customer)
                                              if (locationController.selectedAddress == null || _isEditingAddress)
                                                InlineAddAddressForm(
                                                  key: _addressFormKey,
                                                  address: locationController.selectedAddress,
                                                  grandTotal: grandTotal,
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
                                                CustomerLocationInfo(provider: provider, onEdit: () { setState(() { _isEditingAddress = true; }); })
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

                      // ===== BOTTOM BAR ====
                      if (_currentStep.index >= _FlowStep.addons.index)
                        Container(
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
                                    if (_currentStep == _FlowStep.customerDetails) {
                                      setState(() { _currentStep = _FlowStep.schedule; });
                                      _scrollToKey(_scheduleKey);
                                    } else if (_currentStep == _FlowStep.schedule) {
                                      setState(() { _currentStep = _FlowStep.addons; _cartReady = false; });
                                      _scrollToKey(_addonsKey);
                                    } else if (_currentStep == _FlowStep.addons) {
                                      setState(() { _currentStep = _FlowStep.selectService; _selectedServiceId = null; });
                                      _scrollToKey(_serviceSelectKey);
                                    } else {
                                      Get.back();
                                    }
                                  },
                                ),
                              ),
                              const SizedBox(width: Dimensions.paddingSizeSmall),
                              Expanded(
                                child: CustomButton(
                                  buttonText: _currentStep == _FlowStep.customerDetails ? 'Next'.tr : 'Next'.tr,
                                  isLoading: checkoutController.isLoading || locationController.isLoading,
                                  onPressed: () {
                                    if (_currentStep == _FlowStep.addons) {
                                      _onAddonsNext(cartController, selectedService!);
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
                        ),
                    ],
                  );
                });
              });
            });
          });
        });
      }),
    );
  }

  // Step 2 Next: add cart → show schedule
  // Step 2 Next: next step
  void _onAddonsNext(CartController cartController, Service service) async {
    var selectedItems = cartController.initialCartList.where((e) => e.quantity > 0).toList();

    if (selectedItems.isEmpty && cartController.initialCartList.isNotEmpty) {
      int baseServiceIndex = cartController.initialCartList.indexWhere((item) => item.serviceCost == 0);
      
      if (baseServiceIndex != -1) {
        cartController.initialCartList[baseServiceIndex].quantity = 1;
        selectedItems = [cartController.initialCartList[baseServiceIndex]];
      } else {
        var firstItem = cartController.initialCartList.first;
        var baseService = CartModel(
          firstItem.serviceId!,
          firstItem.serviceId!,
          firstItem.categoryId!,
          firstItem.subCategoryId ?? "",
          'base_service',
          0,
          1,
          0, 0, 0, 0, "", 0, 0, 0,
          firstItem.service!,
        );
        cartController.initialCartList.add(baseService);
        selectedItems = [baseService];
      }
    }

    if (selectedItems.isNotEmpty) {
      await cartController.addMultipleCartToServer(providerId: cartController.selectedProvider?.id ?? "", onlyAddCurrentService: true, fromServiceCenterDialog: false);
      await cartController.getCartListFromServer(shouldUpdate: true);
    }
    Get.find<ScheduleController>().resetSchedule();
    setState(() { _currentStep = _FlowStep.schedule; _cartReady = true; });
    _scrollToKey(_scheduleKey);
  }



  // Step 3 Next: validate schedule → show customer details
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

  // Step 4 Next: validate details → payment
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
    var serviceDetailsController = Get.find<ServiceDetailsController>();

    // Manual total calculation (Service base price + sum of chosen addons)
    double manualAddonTotal = 0;
    for (var cart in cartController.initialCartList) {
      if (cart.variantKey != 'base_service') {
        manualAddonTotal += (cart.serviceCost * cart.quantity);
      }
    }
    double totalAmount = (serviceDetailsController.service?.minBiddingPrice ?? 0) + manualAddonTotal - cartController.referralAmount;
    if (totalAmount < 0) totalAmount = 0;

    String? serviceName = serviceDetailsController.service?.name;
    int? quantity = 1;
    String scheduleTime = scheduleController.selectedServiceType == ServiceType.regular ? (scheduleController.scheduleTime ?? "") : "${scheduleController.selectedTime}";

    String? variantKey;
    var listToUse = cartController.initialCartList;
    if (listToUse.isNotEmpty) {
      List<String> variants = [];
      for (int i = 0; i < listToUse.length; i++) {
        var item = listToUse[i];
        if (item.quantity > 0) {
          if (item.variantKey != null && item.variantKey!.isNotEmpty) {
            variants.add("${item.variantKey} x${item.quantity}");
          } else if (item.service?.name != null) {
             // Fallback if variantKey is empty but it's an addon service
            variants.add("${item.service!.name} x${item.quantity}");
          }
        }
      }
      variantKey = variants.join(',');
    }

    Get.find<LeadController>().saveLeadAddress(
      addressModel, 
      serviceName: serviceName, 
      scheduleTime: scheduleTime, 
      totalAmount: totalAmount, 
      quantity: quantity,
      variantKey: variantKey,
    );
    Get.find<CheckOutController>().totalAmount = totalAmount;

    Get.dialog(const Center(child: CircularProgressIndicator()), barrierDismissible: false);
    if (cartController.cartList.isEmpty && cartController.initialCartList.isNotEmpty) {
       // Re-sync cart from server if empty
       await cartController.getCartListFromServer(shouldUpdate: true);
    }
    Get.back();

    Get.find<LocationController>().updateSelectedAddress(addressModel);
    await Get.find<LocationController>().saveUserAddress(addressModel);
    Get.toNamed(RouteHelper.getCheckoutRoute('cart', 'payment', addressModel.id != null ? addressModel.id.toString() : 'null', amount: totalAmount.toStringAsFixed(2)));
  }
}
