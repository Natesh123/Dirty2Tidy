import 'dart:async';
import 'package:get/get.dart';
import 'package:demandium/utils/core_export.dart';

class CompletePage extends StatefulWidget {
  final String? token;

  const CompletePage({super.key, this.token}) ;

  @override
  State<CompletePage> createState() => _CompletePageState();
}

class _CompletePageState extends State<CompletePage> {

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Get.find<CheckOutController>().showPendingCredentialsDialog();
      if (Get.find<CheckOutController>().isPlacedOrderSuccessfully) {
        Timer(const Duration(seconds: 3), () {
          if (mounted) {
            Get.find<CheckOutController>().updateState(PageState.orderDetails);
            Get.offAllNamed(RouteHelper.getMainRoute('booking'));
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            GetBuilder<CheckOutController>(builder: (controller) {
              return Column(children: [
                const SizedBox(height: Dimensions.paddingSizeExtraMoreLarge,),
                 Image.asset(Images.orderComplete,scale: 4.5,),
                const SizedBox(height: Dimensions.paddingSizeExtraMoreLarge,),
                  Text(controller.isPlacedOrderSuccessfully ? 'Your booking is successful' : 'your_bookings_is_failed_to_place'.tr,
                    textAlign: TextAlign.center,
                    style: robotoBold.copyWith(fontSize: Dimensions.fontSizeExtraLarge,
                        color: controller.isPlacedOrderSuccessfully ? null : Theme.of(context).colorScheme.error) ,
                  ),

                  if(controller.isPlacedOrderSuccessfully)
                    Padding(
                      padding: const EdgeInsets.only(top: Dimensions.paddingSizeSmall),
                      child: Text("Thank you for your booking",
                        style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge, color: Theme.of(context).hintColor),
                      ),
                    ),

                  if(controller.bookingReadableId.isNotEmpty) Padding(padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeDefault),
                    child: Text("${'booking_id'.tr} ${controller.bookingReadableId}",
                      style: robotoBold.copyWith(
                        fontSize: Dimensions.fontSizeExtraLarge,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                const SizedBox(height: Dimensions.paddingSizeExtraMoreLarge,),

                CustomButton(
                  buttonText: "My Bookings",
                  width: 280, backgroundColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                  textStyle: robotoRegular.copyWith(
                    fontSize: Dimensions.fontSizeDefault,
                    color: Theme.of(context).textTheme.bodyLarge?.color?.withValues(alpha: 0.8)
                  ),
                  onPressed: (){
                    Get.find<CheckOutController>().updateState(PageState.orderDetails);
                    Get.offAllNamed(RouteHelper.getMainRoute('booking'));
                  },
                )

              ]);
            }),
          ],
        ),
      ),
    );
  }
}
