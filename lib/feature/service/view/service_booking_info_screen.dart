import 'package:demandium/utils/core_export.dart';
import 'package:demandium/common/widgets/custom_text_field.dart';
import 'package:get/get.dart';

class ServiceBookingInfoScreen extends StatefulWidget {
  const ServiceBookingInfoScreen({super.key});

  @override
  State<ServiceBookingInfoScreen> createState() => _ServiceBookingInfoScreenState();
}

class _ServiceBookingInfoScreenState extends State<ServiceBookingInfoScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _zipController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Pre-filling removed as per request
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'booking_details'.tr),
      body: GetBuilder<CartController>(builder: (cartController) {
        
        var cartItem = cartController.cartList.isNotEmpty ? cartController.cartList.first : null;
        String serviceName = cartItem?.service?.name ?? "Service";
        String variantName = cartItem?.variantKey ?? "";
        double price = cartController.totalPrice;

        return Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
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
                        "Get A Instant Quote or Book Online Now",
                        style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeLarge, color: Theme.of(context).textTheme.bodyLarge!.color!.withValues(alpha: 0.5)),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: Dimensions.paddingSizeLarge),

                    // Summary Text
                    RichText(
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
                      text: TextSpan(
                        style: robotoRegular.copyWith(color: Theme.of(context).textTheme.bodyLarge!.color, fontSize: Dimensions.fontSizeDefault),
                        children: [
                          const TextSpan(text: "Your price for the service after addons is "),
                          TextSpan(text: PriceConverter.convertPrice(price), style: robotoBold.copyWith(color: Theme.of(context).primaryColor)),
                          const TextSpan(text: " including GST."),
                        ],
                      ),
                    ),

                    const SizedBox(height: Dimensions.paddingSizeLarge),
                    Text(
                      "Use your coupon code next step to see how much you can save please type your details to claim your deal.",
                       style: robotoRegular.copyWith(color: Theme.of(context).textTheme.bodyLarge!.color!.withValues(alpha: 0.6)),
                    ),
                    const SizedBox(height: Dimensions.paddingSizeLarge),

                    // Customer Details Form
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabeledTextField(
                            title: "Name",
                            hintText: "Enter Name",
                            controller: _nameController,
                          ),
                        const SizedBox(height: Dimensions.paddingSizeDefault),
                         _buildLabeledTextField(
                            title: "Phone",
                            hintText: "Enter Phone",
                            controller: _phoneController,
                             inputType: TextInputType.phone,
                          ),
                         const SizedBox(height: Dimensions.paddingSizeDefault),
                         _buildLabeledTextField(
                            title: "Email",
                            hintText: "Enter Email",
                            controller: _emailController,
                             inputType: TextInputType.emailAddress,
                          ),
                      ],
                    ),
                    const SizedBox(height: Dimensions.paddingSizeLarge),

                    _buildLabeledTextField(
                      title: "Is there anything else you'd like us to know?",
                      hintText: "Write here...",
                      controller: _noteController,
                      maxLines: 4,
                    ),
                    const SizedBox(height: Dimensions.paddingSizeLarge),
                  ],
                ),
              ),
            ),
            
            // Bottom Buttons
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
                      buttonText: 'BACK',
                      onPressed: () => Get.back(),
                    ),
                  ),
                  const SizedBox(width: Dimensions.paddingSizeSmall),
                  Expanded(
                    child: CustomButton(
                      buttonText: 'NEXT',
                      onPressed: () {
                         _saveAndProceed(cartController);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildLabeledTextField({
    required String title,
    required String hintText,
    required TextEditingController controller,
    TextInputType inputType = TextInputType.text,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: robotoBold.copyWith(
            fontSize: Dimensions.fontSizeDefault,
            color: Theme.of(context).primaryColor,
          ),
        ),
        const SizedBox(height: Dimensions.paddingSizeExtraSmall),
        CustomTextField(
          hintText: hintText,
          controller: controller,
          isShowBorder: true,
          inputType: inputType,
          maxLines: maxLines,
        ),
      ],
    );
  }
  
  void _saveAndProceed(CartController cartController) async {
       // Collect Data
       var cartItem = cartController.cartList.first;
       var scheduleController = Get.find<ScheduleController>();
       var locationController = Get.find<LocationController>();
       
       String scheduleTime = "";
       if(scheduleController.selectedServiceType == ServiceType.regular) {
         scheduleTime = scheduleController.scheduleTime ?? "";
       } else {
         // Handle repeat/other types if needed, for now regular
          scheduleTime = "${scheduleController.selectedTime}"; 
       }

       AddressModel? selectedAddress = locationController.selectedAddress;
       String addressString = selectedAddress?.address ?? "";
       
       Map<String, dynamic> bookingData = {
         "service_id": cartItem.service!.id,
         "variant_key": cartItem.variantKey,
         "schedule_time": scheduleTime,
         "customer_name": _nameController.text,
         "customer_phone": _phoneController.text,
         "customer_email": _emailController.text,
         "note": _noteController.text,
         "total_amount": cartController.totalPrice,
         "address": addressString,
       };

       print("ANTIGRAVITY_DEBUG: Sending Data to DB: $bookingData");
       // Call API and Wait for Success
       bool isStored = await Get.find<CheckOutController>().submitServiceRequest(bookingData);

       if(isStored) {
          // For flow continuity, proceeding to checkout or success
          // Update AddressModel even if empty for safety in next screens
          AddressModel addressModel = AddressModel(
              address: "",
              city: "",
              zipCode: "",
              country: "",
              street: "",
              house: "", 
              contactPersonName: _nameController.text,
              contactPersonNumber: _phoneController.text,
              addressLabel: "Home", 
              addressType: "Home",
              userId: Get.find<AuthController>().isLoggedIn() ? Get.find<UserController>().userInfoModel?.id : Get.find<SplashController>().getGuestId(),
          );
          
          Get.find<LocationController>().updateSelectedAddress(addressModel);
          Get.find<CheckOutController>().serviceNoteController.text = _noteController.text;
          Get.find<CheckOutController>().totalAmount = cartController.totalPrice;

          Get.toNamed(RouteHelper.getCheckoutRoute(
            'cart', 'payment', 'null', 
          ));
       }
  }
}
