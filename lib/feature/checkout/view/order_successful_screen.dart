import 'dart:async';
import 'package:get/get.dart';
import 'package:demandium/utils/core_export.dart';

class OrderSuccessfulScreen extends StatefulWidget {
  final int? status;
  const OrderSuccessfulScreen({super.key, this.status});

  @override
  State<OrderSuccessfulScreen> createState() => _OrderSuccessfulScreenState();
}

class _OrderSuccessfulScreenState extends State<OrderSuccessfulScreen> {

  @override
  void initState() {
    super.initState();
    if (widget.status == 1) {
      Timer(const Duration(seconds: 3), () {
        if (mounted) {
          Get.offAllNamed(RouteHelper.getMainRoute("booking"));
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomPopScopeWidget(
      child: Scaffold(
        appBar: ResponsiveHelper.isDesktop(context) ? const WebMenuBar() : null,
        endDrawer:ResponsiveHelper.isDesktop(context) ? const MenuDrawer():null,
        body: FooterBaseView(
          isCenter: true,
          child: WebShadowWrap(
            child: Center(child: SizedBox(width: Dimensions.webMaxWidth, child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [

              Image.asset(widget.status == 1 ? Images.successIcon : Images.warning, width: 100, height: 100),
              const SizedBox(height: Dimensions.paddingSizeLarge),

              Text(
                widget.status == 1 ? 'Your booking is successful' : 'your_bookings_is_failed_to_place'.tr, 
                style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge),
              ),
              const SizedBox(height: Dimensions.paddingSizeSmall),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge, vertical: Dimensions.paddingSizeSmall),
                child: Text(
                  widget.status == 1 ? 'Thank you for your booking' : 'you_can_try_again_later'.tr,
                  style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).disabledColor),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 30),
              Padding(
                padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                child: CustomButton(
                  buttonText: widget.status == 1 ? 'My Bookings' : 'back_to_home'.tr, 
                  width: Dimensions.webMaxWidth/5, 
                  onPressed: () {
                    if (widget.status == 1) {
                      Get.offAllNamed(RouteHelper.getMainRoute("booking"));
                    } else {
                      Get.offAllNamed(RouteHelper.getMainRoute("home"));
                    }
                  }
                ),
              ),
            ]))),
          ),
        ),
      ),
    );
  }
}
